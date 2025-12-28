--!strict
--[[
    Corridor/ObstacleDefinitions.luau
    Obstacle type definitions for the glass corridor
]]

local VERSION = "2.0.0"

local ObstacleDefinitions = {}

-- Movement configuration for moving obstacles
export type MovementConfig = {
    type: string,           -- "swing", "slide", "rise", "rotate"
    speed: number?,         -- Movement speed
    distance: number?,      -- Distance/amplitude of movement
    amplitude: number?,     -- Angle amplitude for swing
}

-- Visual effects configuration
export type VisualConfig = {
    glowColor: Color3?,     -- Color for point light glow
    glowBrightness: number?, -- Light brightness (default 2)
    glowRange: number?,     -- Light range (default 8)
    particles: string?,     -- Particle type: "sparks", "flames", "electric", "smoke"
    pulseSpeed: number?,    -- Speed of pulsing effect (0 = no pulse)
}

-- Obstacle definition
export type ObstacleDefinition = {
    id: string,
    name: string,
    obstacleType: string,   -- For death message
    size: Vector3,
    color: Color3,
    material: Enum.Material?,
    centered: boolean?,     -- If true, always centered in corridor
    minDifficulty: number,  -- Minimum difficulty to appear
    movement: MovementConfig?, -- Movement config for moving obstacles
    visuals: VisualConfig?,  -- Visual effects config
}

-- Danger colors
local DANGER_RED = Color3.fromRGB(255, 30, 30)
local DANGER_ORANGE = Color3.fromRGB(255, 100, 0)
local DANGER_MAGENTA = Color3.fromRGB(255, 0, 150)
local DANGER_YELLOW = Color3.fromRGB(255, 200, 0)
local ELECTRIC_BLUE = Color3.fromRGB(0, 150, 255)
local TOXIC_GREEN = Color3.fromRGB(100, 255, 0)

-- Static obstacles
local StaticObstacles: { ObstacleDefinition } = {
    -- Walls (block entire path, must jump)
    {
        id = "wall_low",
        name = "Low Wall",
        obstacleType = "wall",
        size = Vector3.new(5, 3, 1),
        color = DANGER_RED,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 1,
        visuals = {
            glowColor = DANGER_RED,
            glowBrightness = 3,
            glowRange = 12,
            particles = "sparks",
            pulseSpeed = 2,
        },
    },
    {
        id = "wall_high",
        name = "High Wall",
        obstacleType = "wall",
        size = Vector3.new(5, 6, 1),
        color = DANGER_MAGENTA,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 3,
        visuals = {
            glowColor = DANGER_MAGENTA,
            glowBrightness = 4,
            glowRange = 15,
            particles = "electric",
            pulseSpeed = 3,
        },
    },

    -- Pillars (partial blockage, weave around)
    {
        id = "pillar_left",
        name = "Left Pillar",
        obstacleType = "pillar",
        size = Vector3.new(2, 8, 2),
        color = DANGER_ORANGE,
        material = Enum.Material.Neon,
        minDifficulty = 1,
        visuals = {
            glowColor = DANGER_ORANGE,
            glowBrightness = 2,
            glowRange = 10,
            particles = "flames",
        },
    },
    {
        id = "pillar_center",
        name = "Center Pillar",
        obstacleType = "pillar",
        size = Vector3.new(2, 8, 2),
        color = DANGER_ORANGE,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 2,
        visuals = {
            glowColor = DANGER_ORANGE,
            glowBrightness = 2,
            glowRange = 10,
            particles = "flames",
        },
    },

    -- Spikes (low, must jump)
    {
        id = "spikes",
        name = "Floor Spikes",
        obstacleType = "spike",
        size = Vector3.new(4, 1.5, 2),
        color = DANGER_YELLOW,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 1,
        visuals = {
            glowColor = DANGER_YELLOW,
            glowBrightness = 3,
            glowRange = 8,
            particles = "sparks",
            pulseSpeed = 4,
        },
    },

    -- Low beams (duck/slide under)
    {
        id = "beam_low",
        name = "Low Beam",
        obstacleType = "beam",
        size = Vector3.new(6, 1, 1),
        color = ELECTRIC_BLUE,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 4,
        visuals = {
            glowColor = ELECTRIC_BLUE,
            glowBrightness = 3,
            glowRange = 12,
            particles = "electric",
            pulseSpeed = 5,
        },
    },
}

-- Moving obstacles
local MovingObstacles: { ObstacleDefinition } = {
    -- Swinging pendulum
    {
        id = "pendulum",
        name = "Swinging Pendulum",
        obstacleType = "pendulum",
        size = Vector3.new(1.5, 10, 1.5),
        color = DANGER_MAGENTA,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 3,
        movement = {
            type = "swing",
            speed = 2,
            amplitude = 45,
        },
        visuals = {
            glowColor = DANGER_MAGENTA,
            glowBrightness = 4,
            glowRange = 15,
            particles = "electric",
            pulseSpeed = 2,
        },
    },

    -- Sliding wall
    {
        id = "slider",
        name = "Sliding Wall",
        obstacleType = "sliding",
        size = Vector3.new(3, 5, 1),
        color = DANGER_RED,
        material = Enum.Material.Neon,
        minDifficulty = 4,
        movement = {
            type = "slide",
            speed = 3,
            distance = 2,
        },
        visuals = {
            glowColor = DANGER_RED,
            glowBrightness = 3,
            glowRange = 12,
            particles = "sparks",
            pulseSpeed = 3,
        },
    },

    -- Rising platform
    {
        id = "riser",
        name = "Rising Block",
        obstacleType = "riser",
        size = Vector3.new(4, 2, 2),
        color = TOXIC_GREEN,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 5,
        movement = {
            type = "rise",
            speed = 2,
            distance = 6,
        },
        visuals = {
            glowColor = TOXIC_GREEN,
            glowBrightness = 3,
            glowRange = 10,
            particles = "smoke",
            pulseSpeed = 2,
        },
    },

    -- Rotating bar
    {
        id = "rotator",
        name = "Rotating Bar",
        obstacleType = "rotating",
        size = Vector3.new(5, 1.2, 1.2),
        color = ELECTRIC_BLUE,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 6,
        movement = {
            type = "rotate",
            speed = 3,
        },
        visuals = {
            glowColor = ELECTRIC_BLUE,
            glowBrightness = 4,
            glowRange = 15,
            particles = "electric",
            pulseSpeed = 6,
        },
    },

    -- Fast slider (higher difficulty)
    {
        id = "fast_slider",
        name = "Fast Slider",
        obstacleType = "sliding",
        size = Vector3.new(2, 6, 1),
        color = DANGER_MAGENTA,
        material = Enum.Material.Neon,
        minDifficulty = 8,
        movement = {
            type = "slide",
            speed = 6,
            distance = 2.5,
        },
        visuals = {
            glowColor = DANGER_MAGENTA,
            glowBrightness = 5,
            glowRange = 18,
            particles = "flames",
            pulseSpeed = 8,
        },
    },

    -- Double pendulum (high difficulty)
    {
        id = "double_pendulum",
        name = "Double Pendulum",
        obstacleType = "pendulum",
        size = Vector3.new(1.5, 12, 1.5),
        color = DANGER_YELLOW,
        material = Enum.Material.Neon,
        centered = true,
        minDifficulty = 10,
        movement = {
            type = "swing",
            speed = 4,
            amplitude = 60,
        },
        visuals = {
            glowColor = DANGER_YELLOW,
            glowBrightness = 5,
            glowRange = 20,
            particles = "flames",
            pulseSpeed = 4,
        },
    },
}

-- Combine all obstacles
local AllObstacles: { ObstacleDefinition } = {}
for _, obs in StaticObstacles do
    table.insert(AllObstacles, obs)
end
for _, obs in MovingObstacles do
    table.insert(AllObstacles, obs)
end

-- Get obstacle by ID
function ObstacleDefinitions.get(id: string): ObstacleDefinition?
    for _, obs in AllObstacles do
        if obs.id == id then
            return obs
        end
    end
    return nil
end

-- Get all obstacles available at a difficulty level
function ObstacleDefinitions.getForDifficulty(difficulty: number): { ObstacleDefinition }
    local available = {}
    for _, obs in AllObstacles do
        if obs.minDifficulty <= difficulty then
            table.insert(available, obs)
        end
    end
    return available
end

-- Get random obstacle for difficulty
function ObstacleDefinitions.getRandomForDifficulty(difficulty: number): ObstacleDefinition?
    local available = ObstacleDefinitions.getForDifficulty(difficulty)
    if #available == 0 then return nil end

    -- Weight toward higher difficulty obstacles
    local weighted = {}
    for _, obs in available do
        -- More weight for obstacles closer to current difficulty
        local weight = math.max(1, 3 - (difficulty - obs.minDifficulty))
        for _ = 1, weight do
            table.insert(weighted, obs)
        end
    end

    return weighted[math.random(#weighted)]
end

-- Get all static obstacles
function ObstacleDefinitions.getStatic(): { ObstacleDefinition }
    return StaticObstacles
end

-- Get all moving obstacles
function ObstacleDefinitions.getMoving(): { ObstacleDefinition }
    return MovingObstacles
end

print("[ObstacleDefinitions v" .. VERSION .. "] Loaded",
    #StaticObstacles, "static,", #MovingObstacles, "moving obstacles")

return ObstacleDefinitions
