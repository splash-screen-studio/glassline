--!strict
--[[
    Audio/AudioConfig.luau
    Audio configuration for Glassline

    Music tracks, sound effects, and zone-based audio.
    Placeholder asset IDs (rbxassetid://0) until real audio is uploaded.
]]

local VERSION = "1.0.0"

local AudioConfig = {}

-- Default volume settings
AudioConfig.DefaultSettings = {
    masterVolume = 0.8,
    musicVolume = 0.6,
    sfxVolume = 0.8,
    muteAll = false,
}

-- Music tracks (placeholder IDs - replace with real uploads)
AudioConfig.MusicTracks = {
    main_theme = {
        id = "main_theme",
        soundId = "rbxassetid://0", -- Replace with uploaded music
        name = "Glassline Theme",
        volume = 0.6,
        looped = true,
        fadeInTime = 1,
        fadeOutTime = 1,
    },
    -- Zone-specific music can be added here
    intense = {
        id = "intense",
        soundId = "rbxassetid://0",
        name = "High Speed",
        volume = 0.7,
        looped = true,
        fadeInTime = 0.5,
        fadeOutTime = 0.5,
    },
}

-- Sound effects
AudioConfig.SoundEffects = {
    -- Death sounds
    death_obstacle = {
        id = "death_obstacle",
        soundId = "rbxassetid://0",
        volume = 0.8,
        pitch = 1,
    },
    death_fall = {
        id = "death_fall",
        soundId = "rbxassetid://0",
        volume = 0.8,
        pitch = 1,
    },

    -- Movement sounds
    jump = {
        id = "jump",
        soundId = "rbxassetid://0",
        volume = 0.5,
        pitch = 1,
    },
    land = {
        id = "land",
        soundId = "rbxassetid://0",
        volume = 0.4,
        pitch = 1,
    },
    footstep = {
        id = "footstep",
        soundId = "rbxassetid://0",
        volume = 0.3,
        pitch = 1,
        pitchVariation = 0.1, -- Random pitch variation
    },

    -- Vehicle sounds
    vehicle_mount = {
        id = "vehicle_mount",
        soundId = "rbxassetid://0",
        volume = 0.6,
        pitch = 1,
    },
    vehicle_dismount = {
        id = "vehicle_dismount",
        soundId = "rbxassetid://0",
        volume = 0.5,
        pitch = 1,
    },
    vehicle_boost = {
        id = "vehicle_boost",
        soundId = "rbxassetid://0",
        volume = 0.7,
        pitch = 1,
    },

    -- Score sounds
    points_tick = {
        id = "points_tick",
        soundId = "rbxassetid://0",
        volume = 0.2,
        pitch = 1,
    },
    milestone = {
        id = "milestone",
        soundId = "rbxassetid://0",
        volume = 0.7,
        pitch = 1,
    },

    -- Zone transition
    zone_change = {
        id = "zone_change",
        soundId = "rbxassetid://0",
        volume = 0.5,
        pitch = 1,
    },

    -- End zone
    reached_end = {
        id = "reached_end",
        soundId = "rbxassetid://0",
        volume = 0.8,
        pitch = 1,
    },
    teleport = {
        id = "teleport",
        soundId = "rbxassetid://0",
        volume = 0.6,
        pitch = 1,
    },

    -- UI sounds
    ui_click = {
        id = "ui_click",
        soundId = "rbxassetid://0",
        volume = 0.4,
        pitch = 1,
    },
    ui_hover = {
        id = "ui_hover",
        soundId = "rbxassetid://0",
        volume = 0.2,
        pitch = 1.1,
    },
}

-- Obstacle-specific hit sounds
AudioConfig.ObstacleSounds = {
    wall = "death_obstacle",
    spike = "death_obstacle",
    pendulum = "death_obstacle",
    sliding = "death_obstacle",
    rotating = "death_obstacle",
}

-- Helper functions

function AudioConfig.getMusicTrack(id: string): typeof(AudioConfig.MusicTracks.main_theme)?
    return AudioConfig.MusicTracks[id]
end

function AudioConfig.getSoundEffect(id: string): typeof(AudioConfig.SoundEffects.jump)?
    return AudioConfig.SoundEffects[id]
end

function AudioConfig.getObstacleSound(obstacleType: string): string
    return AudioConfig.ObstacleSounds[obstacleType] or "death_obstacle"
end

print("[AudioConfig v" .. VERSION .. "] Loaded")

return AudioConfig
