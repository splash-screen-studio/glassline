--!strict
--[[
    PlaceConfig.luau
    Centralized configuration for Glassline

    All game settings in one place: corridor dimensions, movement, scoring,
    difficulty scaling, and visual zones.
]]

local VERSION = "1.1.0"

export type Zone = {
    startZ: number,
    endZ: number,
    theme: string,
    difficulty: number,
}

export type VehicleSpawn = {
    position: number, -- Z position in corridor
    vehicleType: string,
}

local PlaceConfig = {}

-- Corridor dimensions
PlaceConfig.Corridor = {
    width = 6,                  -- Avatar width + small margin (studs)
    height = 50,                -- Tall glass ceiling (studs)
    length = 10000,             -- Very long corridor (studs)
    wallThickness = 1,          -- Glass wall thickness (studs)
    wallTransparency = 0.3,     -- Glass transparency (0-1)
    wallColor = Color3.fromRGB(200, 220, 255), -- Slight blue tint
    floorMaterial = Enum.Material.SmoothPlastic,
    ceilingMaterial = Enum.Material.Glass,
}

-- Movement settings
PlaceConfig.Movement = {
    baseRunSpeed = 80,          -- Very fast running (studs/s)
    baseJumpPower = 80,         -- Very fast jumping
    vehicleSpeedMultiplier = 1.5,
    -- Roblox character settings
    characterSettings = {
        WalkSpeed = 80,
        JumpPower = 80,
        MaxSlopeAngle = 89,     -- Can run up steep undulations
    },
}

-- Scoring system
PlaceConfig.Scoring = {
    forwardMultiplier = 1,      -- Normal points going forward
    backwardMultiplier = 2,     -- Double points going backward (after reaching end)
    pointsPerStud = 1,          -- 1 point per stud of progress
    -- Direction states
    states = {
        FORWARD = "forward",    -- Default, points for forward movement
        BACKWARD = "backward",  -- After reaching end, 2x for backward
    },
}

-- Progressive difficulty
PlaceConfig.Difficulty = {
    speedIncreasePerZone = 5,       -- +5 speed each zone
    obstacleFrequencyBase = 0.1,    -- Base obstacle spawn rate
    obstacleFrequencyMax = 0.5,     -- Max obstacle density (reached at zone 10)
    timingWindowShrink = 0.95,      -- Moving obstacles 5% faster per zone
    obstacleSpeedBase = 20,         -- Base speed for moving obstacles (studs/s)
}

-- Monetization: Points Multiplier Pass
PlaceConfig.Monetization = {
    multiplierPassId = 0,           -- Replace with real Game Pass ID from Creator Hub
    multiplierPassBonus = 1.5,      -- 1.5x points for pass owners
    -- Stacks: Forward (1x * 1.5 = 1.5x), Backward (2x * 1.5 = 3x)
}

-- Visual zones (radically shifting scenery)
PlaceConfig.Zones = {
    { startZ = 0, endZ = 500, theme = "realistic_forest", difficulty = 1 },
    { startZ = 500, endZ = 1000, theme = "surreal_geometric", difficulty = 2 },
    { startZ = 1000, endZ = 1500, theme = "underwater_depths", difficulty = 3 },
    { startZ = 1500, endZ = 2000, theme = "dreamy_clouds", difficulty = 4 },
    { startZ = 2000, endZ = 2500, theme = "scary_shadows", difficulty = 5 },
    { startZ = 2500, endZ = 3000, theme = "girly_pastel", difficulty = 6 },
    { startZ = 3000, endZ = 3500, theme = "neon_city", difficulty = 7 },
    { startZ = 3500, endZ = 4000, theme = "abstract_art", difficulty = 8 },
    { startZ = 4000, endZ = 4500, theme = "crystal_caves", difficulty = 9 },
    { startZ = 4500, endZ = 5000, theme = "volcanic_fire", difficulty = 10 },
    { startZ = 5000, endZ = 5500, theme = "frozen_tundra", difficulty = 11 },
    { startZ = 5500, endZ = 6000, theme = "candy_land", difficulty = 12 },
    { startZ = 6000, endZ = 6500, theme = "steampunk", difficulty = 13 },
    { startZ = 6500, endZ = 7000, theme = "cosmic_void", difficulty = 14 },
    { startZ = 7000, endZ = 7500, theme = "jungle_temple", difficulty = 15 },
    { startZ = 7500, endZ = 8000, theme = "glitch_digital", difficulty = 16 },
    { startZ = 8000, endZ = 8500, theme = "ancient_ruins", difficulty = 17 },
    { startZ = 8500, endZ = 9000, theme = "rainbow_prism", difficulty = 18 },
    { startZ = 9000, endZ = 9500, theme = "nightmare_realm", difficulty = 19 },
    { startZ = 9500, endZ = 10000, theme = "transcendence", difficulty = 20 },
}

-- Vehicle spawn points
PlaceConfig.VehicleSpawns = {
    { position = 1000, vehicleType = "hoverboard" },
    { position = 2500, vehicleType = "rocket" },
    { position = 4000, vehicleType = "bouncer" },
    { position = 5500, vehicleType = "hoverboard" },
    { position = 7000, vehicleType = "rocket" },
    { position = 8500, vehicleType = "bouncer" },
}

-- End zone configuration
PlaceConfig.EndZone = {
    startZ = 10000,             -- Where corridor ends
    sideAreaWidth = 20,         -- Width of side exploration areas
    sideAreaLength = 50,        -- Length of side areas
    teleportPosition = Vector3.new(0, 5, 0), -- Return to start position
}

-- Spawn configuration
PlaceConfig.Spawn = {
    position = Vector3.new(0, 0.5, -10),
    lookDirection = Vector3.new(0, 0, 1), -- Face forward (positive Z)
}

-- Lighting presets for zones (performance-friendly visuals)
PlaceConfig.ZoneLighting = {
    realistic_forest = {
        Ambient = Color3.fromRGB(80, 100, 80),
        OutdoorAmbient = Color3.fromRGB(100, 120, 100),
        Brightness = 2,
        FogEnd = 1000,
        FogColor = Color3.fromRGB(180, 200, 180),
    },
    surreal_geometric = {
        Ambient = Color3.fromRGB(100, 80, 120),
        OutdoorAmbient = Color3.fromRGB(120, 100, 140),
        Brightness = 2.5,
        FogEnd = 800,
        FogColor = Color3.fromRGB(150, 130, 170),
    },
    underwater_depths = {
        Ambient = Color3.fromRGB(40, 80, 120),
        OutdoorAmbient = Color3.fromRGB(60, 100, 140),
        Brightness = 1.5,
        FogEnd = 400,
        FogColor = Color3.fromRGB(30, 60, 100),
    },
    dreamy_clouds = {
        Ambient = Color3.fromRGB(200, 180, 220),
        OutdoorAmbient = Color3.fromRGB(220, 200, 240),
        Brightness = 3,
        FogEnd = 1200,
        FogColor = Color3.fromRGB(240, 220, 255),
    },
    scary_shadows = {
        Ambient = Color3.fromRGB(30, 20, 40),
        OutdoorAmbient = Color3.fromRGB(40, 30, 50),
        Brightness = 0.5,
        FogEnd = 300,
        FogColor = Color3.fromRGB(20, 10, 30),
    },
    girly_pastel = {
        Ambient = Color3.fromRGB(255, 200, 220),
        OutdoorAmbient = Color3.fromRGB(255, 220, 240),
        Brightness = 3,
        FogEnd = 1000,
        FogColor = Color3.fromRGB(255, 230, 245),
    },
    neon_city = {
        Ambient = Color3.fromRGB(20, 20, 40),
        OutdoorAmbient = Color3.fromRGB(40, 40, 80),
        Brightness = 1,
        FogEnd = 600,
        FogColor = Color3.fromRGB(30, 30, 60),
    },
    abstract_art = {
        Ambient = Color3.fromRGB(150, 100, 50),
        OutdoorAmbient = Color3.fromRGB(180, 120, 70),
        Brightness = 2.5,
        FogEnd = 900,
        FogColor = Color3.fromRGB(200, 150, 100),
    },
    crystal_caves = {
        Ambient = Color3.fromRGB(100, 150, 200),
        OutdoorAmbient = Color3.fromRGB(120, 170, 220),
        Brightness = 2,
        FogEnd = 500,
        FogColor = Color3.fromRGB(150, 200, 250),
    },
    volcanic_fire = {
        Ambient = Color3.fromRGB(150, 50, 20),
        OutdoorAmbient = Color3.fromRGB(180, 70, 30),
        Brightness = 2,
        FogEnd = 400,
        FogColor = Color3.fromRGB(100, 40, 20),
    },
    frozen_tundra = {
        Ambient = Color3.fromRGB(180, 200, 220),
        OutdoorAmbient = Color3.fromRGB(200, 220, 240),
        Brightness = 3,
        FogEnd = 800,
        FogColor = Color3.fromRGB(220, 240, 255),
    },
    candy_land = {
        Ambient = Color3.fromRGB(255, 180, 200),
        OutdoorAmbient = Color3.fromRGB(255, 200, 220),
        Brightness = 3,
        FogEnd = 1000,
        FogColor = Color3.fromRGB(255, 220, 240),
    },
    steampunk = {
        Ambient = Color3.fromRGB(120, 100, 80),
        OutdoorAmbient = Color3.fromRGB(140, 120, 100),
        Brightness = 2,
        FogEnd = 600,
        FogColor = Color3.fromRGB(100, 80, 60),
    },
    cosmic_void = {
        Ambient = Color3.fromRGB(10, 5, 20),
        OutdoorAmbient = Color3.fromRGB(20, 10, 40),
        Brightness = 0.5,
        FogEnd = 2000,
        FogColor = Color3.fromRGB(5, 0, 15),
    },
    jungle_temple = {
        Ambient = Color3.fromRGB(60, 80, 40),
        OutdoorAmbient = Color3.fromRGB(80, 100, 60),
        Brightness = 1.5,
        FogEnd = 500,
        FogColor = Color3.fromRGB(50, 70, 30),
    },
    glitch_digital = {
        Ambient = Color3.fromRGB(0, 255, 100),
        OutdoorAmbient = Color3.fromRGB(50, 255, 150),
        Brightness = 2,
        FogEnd = 700,
        FogColor = Color3.fromRGB(0, 200, 80),
    },
    ancient_ruins = {
        Ambient = Color3.fromRGB(100, 90, 70),
        OutdoorAmbient = Color3.fromRGB(120, 110, 90),
        Brightness = 2,
        FogEnd = 600,
        FogColor = Color3.fromRGB(150, 140, 120),
    },
    rainbow_prism = {
        Ambient = Color3.fromRGB(200, 200, 200),
        OutdoorAmbient = Color3.fromRGB(220, 220, 220),
        Brightness = 3,
        FogEnd = 1500,
        FogColor = Color3.fromRGB(255, 255, 255),
    },
    nightmare_realm = {
        Ambient = Color3.fromRGB(50, 0, 0),
        OutdoorAmbient = Color3.fromRGB(70, 10, 10),
        Brightness = 0.5,
        FogEnd = 250,
        FogColor = Color3.fromRGB(30, 0, 0),
    },
    transcendence = {
        Ambient = Color3.fromRGB(255, 255, 255),
        OutdoorAmbient = Color3.fromRGB(255, 255, 255),
        Brightness = 4,
        FogEnd = 2000,
        FogColor = Color3.fromRGB(255, 255, 255),
    },
}

-- Helper functions

function PlaceConfig.getZoneAtPosition(zPosition: number): Zone?
    for _, zone in PlaceConfig.Zones do
        if zPosition >= zone.startZ and zPosition < zone.endZ then
            return zone
        end
    end
    return nil
end

function PlaceConfig.getDifficultyAtPosition(zPosition: number): number
    local zone = PlaceConfig.getZoneAtPosition(zPosition)
    return if zone then zone.difficulty else 1
end

function PlaceConfig.getSpeedAtPosition(zPosition: number): number
    local difficulty = PlaceConfig.getDifficultyAtPosition(zPosition)
    return PlaceConfig.Movement.baseRunSpeed +
           (difficulty - 1) * PlaceConfig.Difficulty.speedIncreasePerZone
end

function PlaceConfig.getObstacleFrequency(difficulty: number): number
    local base = PlaceConfig.Difficulty.obstacleFrequencyBase
    local max = PlaceConfig.Difficulty.obstacleFrequencyMax
    local t = math.min((difficulty - 1) / 9, 1) -- Ramps up over first 10 zones
    return base + (max - base) * t
end

function PlaceConfig.getObstacleSpeed(difficulty: number): number
    local base = PlaceConfig.Difficulty.obstacleSpeedBase
    local shrink = PlaceConfig.Difficulty.timingWindowShrink
    -- Each zone, obstacles move faster (smaller timing window)
    return base / (shrink ^ (difficulty - 1))
end

function PlaceConfig.getLightingForZone(theme: string): { [string]: any }?
    return PlaceConfig.ZoneLighting[theme]
end

print("[PlaceConfig v" .. VERSION .. "] Loaded")

return PlaceConfig
