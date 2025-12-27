--!strict
--[[
    Audio/Types.luau
    Type definitions for audio system
]]

export type MusicTrack = {
    id: string,
    soundId: string,
    name: string,
    volume: number,
    looped: boolean,
    fadeInTime: number?,
    fadeOutTime: number?,
}

export type SoundEffect = {
    id: string,
    soundId: string,
    volume: number,
    pitch: number?,
    pitchVariation: number?,
    spatial: boolean?,
    minDistance: number?,
    maxDistance: number?,
}

export type AudioSettings = {
    masterVolume: number,
    musicVolume: number,
    sfxVolume: number,
    muteAll: boolean,
}

return nil
