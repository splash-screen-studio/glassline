--!strict
--[[
    Network/Types.luau
    Type definitions for all network messages in Glassline
]]

local PlaceConfig = require(script.Parent.Parent.PlaceConfig)

export type Result<T> = {
    success: boolean,
    data: T?,
    error: string?,
}

-- Score & Progress
export type ScoreUpdateData = {
    runPoints: number,          -- Points this run
    lifetimePoints: number,     -- Total lifetime points
    multiplier: number,         -- Current multiplier (1 or 2)
}

export type ProgressUpdateData = {
    position: number,           -- Z position in corridor
    speed: number,              -- Current speed
    direction: string,          -- "forward" or "backward"
}

export type DirectionStateData = {
    state: string,              -- "forward" or "backward"
    multiplier: number,         -- Points multiplier
}

-- Death & Respawn
export type DeathData = {
    position: Vector3,          -- Where player died
    cause: string,              -- What killed them (obstacle type)
    runPoints: number,          -- Points earned this run
}

export type RespawnData = {
    position: Vector3,          -- Spawn position
    resetRun: boolean,          -- Whether run points reset
}

-- Vehicles
export type VehicleMountData = {
    vehicleType: string,        -- "hoverboard", "rocket", "bouncer"
    speedMultiplier: number,
    jumpMultiplier: number,
}

-- Zones
export type ZoneChangeData = {
    zone: PlaceConfig.Zone,
    theme: string,
    difficulty: number,
}

-- End Zone
export type ReachedEndData = {
    runPoints: number,
    totalDistance: number,
    newState: string,           -- "backward"
}

-- Ghost (Multiplayer)
export type GhostData = {
    playerId: number,
    position: Vector3,
    velocity: Vector3,
    state: string,              -- "running", "jumping", "vehicle"
}

export type GhostUpdateData = {
    ghosts: { GhostData },
}

-- Player Data
export type PlayerData = {
    lifetimePoints: number,
    highestDistance: number,
    totalRuns: number,
    totalDeaths: number,
}

export type GetPlayerDataResponse = Result<PlayerData>

return nil
