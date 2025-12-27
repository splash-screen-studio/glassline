--!strict
--[[
    Audio/MusicService.luau
    Music playback with crossfading
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local SoundService = game:GetService("SoundService")
local TweenService = game:GetService("TweenService")

local MusicService = {}

-- Dependencies
local AudioConfig: any

-- Current music
local currentSound: Sound?
local currentTrackId: string?

-- Music container
local musicFolder: Folder

function MusicService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    AudioConfig = require(Shared.Audio.AudioConfig)

    -- Create music folder
    musicFolder = Instance.new("Folder")
    musicFolder.Name = "Music"
    musicFolder.Parent = SoundService

    print("[MusicService v" .. VERSION .. "] Initialized")
end

function MusicService:play(trackId: string, volume: number?)
    local track = AudioConfig.getMusicTrack(trackId)
    if not track then
        warn("[MusicService] Unknown track:", trackId)
        return
    end

    -- Skip if already playing this track
    if currentTrackId == trackId and currentSound and currentSound.IsPlaying then
        return
    end

    -- Fade out current
    if currentSound then
        self:fadeOut(currentSound, track.fadeOutTime or 1)
    end

    -- Create new sound
    local sound = Instance.new("Sound")
    sound.Name = trackId
    sound.SoundId = track.soundId
    sound.Volume = 0
    sound.Looped = track.looped
    sound.Parent = musicFolder

    currentSound = sound
    currentTrackId = trackId

    -- Play and fade in
    sound:Play()
    self:fadeIn(sound, track.fadeInTime or 1, (volume or 1) * track.volume)
end

function MusicService:stop()
    if currentSound then
        self:fadeOut(currentSound, 1)
        currentSound = nil
        currentTrackId = nil
    end
end

function MusicService:setVolume(volume: number)
    if currentSound then
        local track = AudioConfig.getMusicTrack(currentTrackId or "")
        local trackVolume = if track then track.volume else 1
        currentSound.Volume = volume * trackVolume
    end
end

function MusicService:fadeIn(sound: Sound, duration: number, targetVolume: number)
    local tween = TweenService:Create(
        sound,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
        { Volume = targetVolume }
    )
    tween:Play()
end

function MusicService:fadeOut(sound: Sound, duration: number)
    local tween = TweenService:Create(
        sound,
        TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
        { Volume = 0 }
    )
    tween:Play()

    -- Destroy after fade
    tween.Completed:Connect(function()
        sound:Destroy()
    end)
end

function MusicService:isPlaying(): boolean
    return currentSound ~= nil and currentSound.IsPlaying
end

function MusicService:getCurrentTrack(): string?
    return currentTrackId
end

return MusicService
