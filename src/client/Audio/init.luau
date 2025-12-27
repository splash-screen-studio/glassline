--!strict
--[[
    Audio/init.luau
    Main audio controller for Glassline
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local AudioController = {}

-- Dependencies
local MusicService: any
local SFXService: any
local AudioConfig: any

-- Settings
local settings = {
    masterVolume = 0.8,
    musicVolume = 0.6,
    sfxVolume = 0.8,
    muteAll = false,
}

function AudioController:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    AudioConfig = require(Shared.Audio.AudioConfig)

    MusicService = require(script.MusicService)
    MusicService:init()

    SFXService = require(script.SFXService)
    SFXService:init()

    -- Apply default settings
    settings = AudioConfig.DefaultSettings

    print("[AudioController v" .. VERSION .. "] Initialized")
end

-- Music controls
function AudioController:playMusic(trackId: string)
    if settings.muteAll then return end
    MusicService:play(trackId, settings.masterVolume * settings.musicVolume)
end

function AudioController:stopMusic()
    MusicService:stop()
end

function AudioController:setMusicVolume(volume: number)
    settings.musicVolume = math.clamp(volume, 0, 1)
    MusicService:setVolume(settings.masterVolume * settings.musicVolume)
end

-- SFX controls
function AudioController:playSFX(sfxId: string, position: Vector3?)
    if settings.muteAll then return end
    SFXService:play(sfxId, settings.masterVolume * settings.sfxVolume, position)
end

function AudioController:setSFXVolume(volume: number)
    settings.sfxVolume = math.clamp(volume, 0, 1)
end

-- Master controls
function AudioController:setMasterVolume(volume: number)
    settings.masterVolume = math.clamp(volume, 0, 1)
    MusicService:setVolume(settings.masterVolume * settings.musicVolume)
end

function AudioController:setMuteAll(muted: boolean)
    settings.muteAll = muted
    if muted then
        MusicService:stop()
    end
end

function AudioController:getSettings(): typeof(settings)
    return settings
end

return AudioController
