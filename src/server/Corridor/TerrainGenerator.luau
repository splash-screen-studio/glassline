--!strict
--[[
    Corridor/TerrainGenerator.luau
    Generates terrain-based world with corridor and themed side environments

    Version: 1.0.0
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local TerrainGenerator = {}

local PlaceConfig: any
local terrain: Terrain

local CORRIDOR_MATERIAL = Enum.Material.Concrete
local RESOLUTION = 4
local SIDE_WIDTH = 80

local ZONE_MATERIALS = {
    { endZ = 500, material = Enum.Material.Grass },
    { endZ = 1000, material = Enum.Material.Rock },
    { endZ = 1500, material = Enum.Material.Sand },
    { endZ = 2000, material = Enum.Material.Snow },
    { endZ = 2500, material = Enum.Material.Slate },
    { endZ = 3000, material = Enum.Material.Grass },
    { endZ = 3500, material = Enum.Material.Asphalt },
    { endZ = 4000, material = Enum.Material.Sandstone },
    { endZ = 4500, material = Enum.Material.Ice },
    { endZ = 5000, material = Enum.Material.CrackedLava },
    { endZ = 5500, material = Enum.Material.Glacier },
    { endZ = 6000, material = Enum.Material.Grass },
    { endZ = 6500, material = Enum.Material.Brick },
    { endZ = 7000, material = Enum.Material.Basalt },
    { endZ = 7500, material = Enum.Material.LeafyGrass },
    { endZ = 8000, material = Enum.Material.Limestone },
    { endZ = 8500, material = Enum.Material.Rock },
    { endZ = 9000, material = Enum.Material.Salt },
    { endZ = 9500, material = Enum.Material.Mud },
    { endZ = 10000, material = Enum.Material.Snow },
}

function TerrainGenerator:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    terrain = workspace.Terrain

    print("[TerrainGenerator v" .. VERSION .. "] Initialized")
end

local function getZoneMaterial(z: number): Enum.Material
    for _, zone in ZONE_MATERIALS do
        if z <= zone.endZ then
            return zone.material
        end
    end
    return Enum.Material.Snow
end

local function getHeight(x: number, z: number): number
    local baseHeight = 0
    baseHeight = baseHeight + math.sin(z * 0.01) * 15
    baseHeight = baseHeight + math.sin(z * 0.023 + x * 0.02) * 7
    baseHeight = baseHeight + math.sin(z * 0.005) * 22
    baseHeight = baseHeight + math.sin(x * 0.1 + z * 0.05) * 5
    return baseHeight
end

function TerrainGenerator:generate()
    terrain:Clear()

    local corridorWidth = PlaceConfig.Corridor.width
    local corridorLength = PlaceConfig.Corridor.length

    print("[TerrainGenerator] Generating terrain...")

    -- Generate terrain in segments
    for z = -50, corridorLength, RESOLUTION do
        -- Corridor floor (perfectly level left-to-right)
        for x = -corridorWidth/2 - 1, corridorWidth/2 + 1, RESOLUTION do
            local region = Region3.new(
                Vector3.new(x - RESOLUTION/2, -3, z - RESOLUTION/2),
                Vector3.new(x + RESOLUTION/2, 0, z + RESOLUTION/2)
            ):ExpandToGrid(RESOLUTION)
            terrain:FillRegion(region, RESOLUTION, CORRIDOR_MATERIAL)
        end

        -- Side terrain (undulating, themed)
        local sideMat = getZoneMaterial(z)

        -- Left side
        for x = -corridorWidth/2 - SIDE_WIDTH, -corridorWidth/2 - 2, RESOLUTION do
            local height = getHeight(x, z)
            local region = Region3.new(
                Vector3.new(x - RESOLUTION/2, math.min(height, -5) - 10, z - RESOLUTION/2),
                Vector3.new(x + RESOLUTION/2, height, z + RESOLUTION/2)
            ):ExpandToGrid(RESOLUTION)
            terrain:FillRegion(region, RESOLUTION, sideMat)
        end

        -- Right side
        for x = corridorWidth/2 + 2, corridorWidth/2 + SIDE_WIDTH, RESOLUTION do
            local height = getHeight(x, z)
            local region = Region3.new(
                Vector3.new(x - RESOLUTION/2, math.min(height, -5) - 10, z - RESOLUTION/2),
                Vector3.new(x + RESOLUTION/2, height, z + RESOLUTION/2)
            ):ExpandToGrid(RESOLUTION)
            terrain:FillRegion(region, RESOLUTION, sideMat)
        end
    end

    -- Add water in valleys
    self:generateWater()

    print("[TerrainGenerator v" .. VERSION .. "] Terrain complete")
end

function TerrainGenerator:generateWater()
    local corridorWidth = PlaceConfig.Corridor.width
    local corridorLength = PlaceConfig.Corridor.length
    local waterLevel = -5

    for z = 0, corridorLength, RESOLUTION * 4 do
        for x = -corridorWidth/2 - SIDE_WIDTH, corridorWidth/2 + SIDE_WIDTH, RESOLUTION * 4 do
            if math.abs(x) > corridorWidth/2 + 1 then
                local region = Region3.new(
                    Vector3.new(x - RESOLUTION * 2, -15, z - RESOLUTION * 2),
                    Vector3.new(x + RESOLUTION * 2, waterLevel, z + RESOLUTION * 2)
                ):ExpandToGrid(RESOLUTION)
                terrain:FillRegion(region, RESOLUTION, Enum.Material.Water)
            end
        end
    end
end

function TerrainGenerator:clear()
    terrain:Clear()
end

return TerrainGenerator
