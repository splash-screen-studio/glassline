--!strict
--[[
    Corridor/ObstacleDefinitions.luau
    Obstacle type definitions for the glass corridor
]]

local VERSION = "1.0.0"

local ObstacleDefinitions = {}

-- Movement configuration for moving obstacles
export type MovementConfig = {
    type: string,           -- "swing", "slide", "rise", "rotate"
    speed: number?,         -- Movement speed
    distance: number?,      -- Distance/amplitude of movement
    amplitude: number?,     -- Angle amplitude for swing
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
}

-- Static obstacles
local StaticObstacles: { ObstacleDefinition } = {
    -- Walls (block entire path, must jump)
    {
        id = "wall_low",
        name = "Low Wall",
        obstacleType = "wall",
        size = Vector3.new(5, 3, 1),
        color = Color3.fromRGB(150, 50, 50),
        centered = true,
        minDifficulty = 1,
    },
    {
        id = "wall_high",
        name = "High Wall",
        obstacleType = "wall",
        size = Vector3.new(5, 6, 1),
        color = Color3.fromRGB(180, 50, 50),
        centered = true,
        minDifficulty = 3,
    },

    -- Pillars (partial blockage, weave around)
    {
        id = "pillar_left",
        name = "Left Pillar",
        obstacleType = "pillar",
        size = Vector3.new(2, 8, 2),
        color = Color3.fromRGB(100, 100, 100),
        minDifficulty = 1,
    },
    {
        id = "pillar_center",
        name = "Center Pillar",
        obstacleType = "pillar",
        size = Vector3.new(2, 8, 2),
        color = Color3.fromRGB(100, 100, 100),
        centered = true,
        minDifficulty = 2,
    },

    -- Spikes (low, must jump)
    {
        id = "spikes",
        name = "Floor Spikes",
        obstacleType = "spike",
        size = Vector3.new(4, 1, 2),
        color = Color3.fromRGB(200, 100, 50),
        material = Enum.Material.Metal,
        centered = true,
        minDifficulty = 1,
    },

    -- Low beams (duck/slide under)
    {
        id = "beam_low",
        name = "Low Beam",
        obstacleType = "beam",
        size = Vector3.new(6, 1, 1),
        color = Color3.fromRGB(80, 80, 80),
        centered = true,
        minDifficulty = 4,
    },
}

-- Moving obstacles
local MovingObstacles: { ObstacleDefinition } = {
    -- Swinging pendulum
    {
        id = "pendulum",
        name = "Swinging Pendulum",
        obstacleType = "pendulum",
        size = Vector3.new(1, 10, 1),
        color = Color3.fromRGB(150, 150, 200),
        material = Enum.Material.Metal,
        centered = true,
        minDifficulty = 3,
        movement = {
            type = "swing",
            speed = 2,
            amplitude = 45,
        },
    },

    -- Sliding wall
    {
        id = "slider",
        name = "Sliding Wall",
        obstacleType = "sliding",
        size = Vector3.new(3, 5, 1),
        color = Color3.fromRGB(200, 150, 100),
        minDifficulty = 4,
        movement = {
            type = "slide",
            speed = 3,
            distance = 2,
        },
    },

    -- Rising platform
    {
        id = "riser",
        name = "Rising Block",
        obstacleType = "riser",
        size = Vector3.new(4, 2, 2),
        color = Color3.fromRGB(100, 150, 200),
        centered = true,
        minDifficulty = 5,
        movement = {
            type = "rise",
            speed = 2,
            distance = 6,
        },
    },

    -- Rotating bar
    {
        id = "rotator",
        name = "Rotating Bar",
        obstacleType = "rotating",
        size = Vector3.new(5, 1, 1),
        color = Color3.fromRGB(200, 100, 150),
        material = Enum.Material.Metal,
        centered = true,
        minDifficulty = 6,
        movement = {
            type = "rotate",
            speed = 3,
        },
    },

    -- Fast slider (higher difficulty)
    {
        id = "fast_slider",
        name = "Fast Slider",
        obstacleType = "sliding",
        size = Vector3.new(2, 6, 1),
        color = Color3.fromRGB(255, 100, 100),
        minDifficulty = 8,
        movement = {
            type = "slide",
            speed = 6,
            distance = 2.5,
        },
    },

    -- Double pendulum (high difficulty)
    {
        id = "double_pendulum",
        name = "Double Pendulum",
        obstacleType = "pendulum",
        size = Vector3.new(1, 12, 1),
        color = Color3.fromRGB(200, 50, 200),
        material = Enum.Material.Metal,
        centered = true,
        minDifficulty = 10,
        movement = {
            type = "swing",
            speed = 4,
            amplitude = 60,
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
