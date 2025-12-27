--!strict
--[[
    Audio/SFXService.luau
    Sound effect playback with pooling
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")

local SFXService = {}

-- Dependencies
local AudioConfig: any

-- Sound pools
local soundPool: { Sound } = {}
local MAX_POOL_SIZE = 20

-- SFX container
local sfxFolder: Folder

function SFXService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    AudioConfig = require(Shared.Audio.AudioConfig)

    -- Create SFX folder
    sfxFolder = Instance.new("Folder")
    sfxFolder.Name = "SFX"
    sfxFolder.Parent = SoundService

    -- Pre-warm pool
    for _ = 1, 5 do
        local sound = Instance.new("Sound")
        sound.Parent = sfxFolder
        table.insert(soundPool, sound)
    end

    print("[SFXService v" .. VERSION .. "] Initialized")
end

function SFXService:play(sfxId: string, volume: number?, position: Vector3?)
    local sfx = AudioConfig.getSoundEffect(sfxId)
    if not sfx then
        -- Don't warn for placeholder sounds
        return
    end

    -- Skip placeholder sounds
    if sfx.soundId == "rbxassetid://0" then
        return
    end

    -- Get sound from pool
    local sound = self:getFromPool()
    if not sound then return end -- Pool exhausted

    -- Configure sound
    sound.SoundId = sfx.soundId
    sound.Volume = (volume or 1) * sfx.volume

    -- Apply pitch variation
    if sfx.pitchVariation then
        sound.PlaybackSpeed = sfx.pitch + (math.random() * 2 - 1) * sfx.pitchVariation
    else
        sound.PlaybackSpeed = sfx.pitch or 1
    end

    -- Spatial audio
    if position then
        -- Create attachment for 3D sound
        local attachment = Instance.new("Attachment")
        attachment.WorldPosition = position
        attachment.Parent = workspace.Terrain

        sound.Parent = attachment
        sound.RollOffMinDistance = 10
        sound.RollOffMaxDistance = 100

        -- Cleanup after play
        sound.Ended:Once(function()
            self:returnToPool(sound)
            attachment:Destroy()
        end)
    else
        sound.Parent = sfxFolder

        -- Cleanup after play
        sound.Ended:Once(function()
            self:returnToPool(sound)
        end)
    end

    sound:Play()
end

function SFXService:playAtPart(sfxId: string, part: BasePart, volume: number?)
    self:play(sfxId, volume, part.Position)
end

function SFXService:getFromPool(): Sound?
    if #soundPool > 0 then
        return table.remove(soundPool)
    end

    -- Create new if under limit
    if #soundPool < MAX_POOL_SIZE then
        local sound = Instance.new("Sound")
        return sound
    end

    return nil
end

function SFXService:returnToPool(sound: Sound)
    if #soundPool >= MAX_POOL_SIZE then
        sound:Destroy()
        return
    end

    -- Reset sound
    sound:Stop()
    sound.SoundId = ""
    sound.Volume = 1
    sound.PlaybackSpeed = 1
    sound.Parent = sfxFolder

    table.insert(soundPool, sound)
end

return SFXService
