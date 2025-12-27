--!strict
--[[
    Corridor/SceneryGenerator.luau
    Generates scenery outside the glass corridor for each zone

    Performance-focused: Uses minimal geometry + lighting/fog effects
    Version: 1.0.0
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local SceneryGenerator = {}

-- Dependencies
local PlaceConfig: any
local SceneryZones: any

-- Generated scenery container
local sceneryFolder: Folder

-- Scenery configuration
local SCENERY_CONFIG = {
    -- Distance from corridor center to scenery
    offsetFromCorridor = 20,
    -- Height range for floating elements
    minHeight = 5,
    maxHeight = 40,
    -- Density of scenery elements per zone
    elementsPerZone = 15,
    -- Segment length for scenery generation
    segmentLength = 50,
}

function SceneryGenerator:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    SceneryZones = require(script.Parent.SceneryZones)

    print("[SceneryGenerator v" .. VERSION .. "] Initialized")
end

function SceneryGenerator:generate()
    -- Create container
    sceneryFolder = Instance.new("Folder")
    sceneryFolder.Name = "Scenery"
    sceneryFolder.Parent = workspace

    -- Generate scenery for each zone
    for _, zone in PlaceConfig.Zones do
        self:generateZoneScenery(zone)
    end

    -- Create spawn room
    self:createSpawnRoom()

    -- Create end zone area
    self:createEndZone()

    print("[SceneryGenerator v" .. VERSION .. "] Generated scenery for", #PlaceConfig.Zones, "zones")
end

function SceneryGenerator:generateZoneScenery(zone: PlaceConfig.Zone)
    local theme = SceneryZones.getTheme(zone.theme)
    if not theme then return end

    local zoneFolder = Instance.new("Folder")
    zoneFolder.Name = "Zone_" .. zone.theme
    zoneFolder.Parent = sceneryFolder

    local zoneLength = zone.endZ - zone.startZ
    local elementsPerSide = math.floor(SCENERY_CONFIG.elementsPerZone / 2)

    -- Generate elements on both sides of corridor
    for side = -1, 1, 2 do -- -1 = left, 1 = right
        local xOffset = side * SCENERY_CONFIG.offsetFromCorridor

        for i = 1, elementsPerSide do
            local zPos = zone.startZ + (i / elementsPerSide) * zoneLength
            local xVariation = math.random(-5, 5)
            local yPos = math.random(SCENERY_CONFIG.minHeight, SCENERY_CONFIG.maxHeight)

            local element = self:createSceneryElement(theme, zone.difficulty)
            element.Position = Vector3.new(xOffset + xVariation, yPos, zPos)
            element.Parent = zoneFolder
        end
    end

    -- Add ground/floor elements outside corridor
    self:createGroundElements(zoneFolder, zone, theme)
end

function SceneryGenerator:createSceneryElement(theme: SceneryZones.ZoneTheme, difficulty: number): BasePart
    local element: BasePart

    -- Different shapes based on zone theme
    local shapeType = math.random(1, 4)

    if shapeType == 1 then
        -- Sphere/orb
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Ball
        element.Size = Vector3.new(3, 3, 3) * (0.5 + math.random() * 1.5)
    elseif shapeType == 2 then
        -- Block/cube
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Block
        local size = 2 + math.random() * 4
        element.Size = Vector3.new(size, size * (0.5 + math.random()), size)
    elseif shapeType == 3 then
        -- Cylinder/pillar
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Cylinder
        element.Size = Vector3.new(2 + math.random() * 3, 5 + math.random() * 10, 2 + math.random() * 3)
    else
        -- Wedge
        element = Instance.new("WedgePart")
        local size = 2 + math.random() * 4
        element.Size = Vector3.new(size, size, size * 2)
    end

    -- Apply theme colors
    element.Color = if math.random() > 0.5 then theme.primaryColor else theme.secondaryColor
    element.Material = Enum.Material.Neon
    element.Transparency = 0.3 + math.random() * 0.4
    element.Anchored = true
    element.CanCollide = false
    element.CastShadow = false

    -- Random rotation
    element.CFrame = element.CFrame * CFrame.Angles(
        math.rad(math.random(0, 360)),
        math.rad(math.random(0, 360)),
        math.rad(math.random(0, 360))
    )

    -- Add glow for some elements
    if math.random() > 0.7 then
        local light = Instance.new("PointLight")
        light.Color = theme.accentColor
        light.Brightness = 0.5 + math.random() * 0.5
        light.Range = 10 + math.random() * 10
        light.Parent = element
    end

    element.Name = "SceneryElement"
    return element
end

function SceneryGenerator:createGroundElements(zoneFolder: Folder, zone: PlaceConfig.Zone, theme: SceneryZones.ZoneTheme)
    -- Create ground planes on either side of the corridor
    local corridorWidth = PlaceConfig.Corridor.width
    local groundWidth = 100
    local zoneLength = zone.endZ - zone.startZ

    for side = -1, 1, 2 do
        local ground = Instance.new("Part")
        ground.Name = "Ground_" .. (side == -1 and "Left" or "Right")
        ground.Anchored = true
        ground.CanCollide = false
        ground.CastShadow = false
        ground.Size = Vector3.new(groundWidth, 1, zoneLength)
        ground.Position = Vector3.new(
            side * (corridorWidth / 2 + groundWidth / 2 + 2),
            -5,
            zone.startZ + zoneLength / 2
        )
        ground.Color = theme.primaryColor
        ground.Material = Enum.Material.Grass
        ground.Transparency = 0.2
        ground.Parent = zoneFolder
    end
end

function SceneryGenerator:createSpawnRoom()
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnRoom"
    spawnFolder.Parent = sceneryFolder

    local corridorWidth = PlaceConfig.Corridor.width
    local roomDepth = 30
    local roomHeight = PlaceConfig.Corridor.height

    -- Back wall
    local backWall = Instance.new("Part")
    backWall.Name = "BackWall"
    backWall.Anchored = true
    backWall.Size = Vector3.new(corridorWidth + 10, roomHeight, 2)
    backWall.Position = Vector3.new(0, roomHeight / 2, -roomDepth)
    backWall.Color = Color3.fromRGB(40, 40, 50)
    backWall.Material = Enum.Material.SmoothPlastic
    backWall.Parent = spawnFolder

    -- Side walls for spawn room
    for side = -1, 1, 2 do
        local sideWall = Instance.new("Part")
        sideWall.Name = "SideWall_" .. (side == -1 and "Left" or "Right")
        sideWall.Anchored = true
        sideWall.Size = Vector3.new(2, roomHeight, roomDepth)
        sideWall.Position = Vector3.new(side * (corridorWidth / 2 + 5), roomHeight / 2, -roomDepth / 2)
        sideWall.Color = Color3.fromRGB(40, 40, 50)
        sideWall.Material = Enum.Material.SmoothPlastic
        sideWall.Parent = spawnFolder
    end

    -- Spawn room floor
    local floor = Instance.new("Part")
    floor.Name = "SpawnFloor"
    floor.Anchored = true
    floor.Size = Vector3.new(corridorWidth + 10, 1, roomDepth)
    floor.Position = Vector3.new(0, 0, -roomDepth / 2)
    floor.Color = Color3.fromRGB(60, 60, 70)
    floor.Material = Enum.Material.SmoothPlastic
    floor.Parent = spawnFolder

    -- Entrance arch
    local arch = self:createArch()
    arch.Parent = spawnFolder

    -- Welcome text
    local welcomePart = Instance.new("Part")
    welcomePart.Name = "WelcomeSign"
    welcomePart.Anchored = true
    welcomePart.CanCollide = false
    welcomePart.Size = Vector3.new(8, 3, 0.5)
    welcomePart.Position = Vector3.new(0, 12, -roomDepth + 5)
    welcomePart.Color = Color3.fromRGB(80, 200, 255)
    welcomePart.Material = Enum.Material.Neon
    welcomePart.Transparency = 0.3
    welcomePart.Parent = spawnFolder

    local surfaceGui = Instance.new("SurfaceGui")
    surfaceGui.Face = Enum.NormalId.Front
    surfaceGui.Parent = welcomePart

    local textLabel = Instance.new("TextLabel")
    textLabel.Size = UDim2.new(1, 0, 1, 0)
    textLabel.BackgroundTransparency = 1
    textLabel.Text = "GLASSLINE"
    textLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    textLabel.TextScaled = true
    textLabel.Font = Enum.Font.GothamBold
    textLabel.Parent = surfaceGui
end

function SceneryGenerator:createArch(): Model
    local arch = Instance.new("Model")
    arch.Name = "EntranceArch"

    local archColor = Color3.fromRGB(80, 200, 255)
    local archMaterial = Enum.Material.Neon

    -- Left pillar
    local leftPillar = Instance.new("Part")
    leftPillar.Name = "LeftPillar"
    leftPillar.Anchored = true
    leftPillar.Size = Vector3.new(1, 15, 1)
    leftPillar.Position = Vector3.new(-4, 7.5, 0)
    leftPillar.Color = archColor
    leftPillar.Material = archMaterial
    leftPillar.Transparency = 0.3
    leftPillar.Parent = arch

    -- Right pillar
    local rightPillar = leftPillar:Clone()
    rightPillar.Name = "RightPillar"
    rightPillar.Position = Vector3.new(4, 7.5, 0)
    rightPillar.Parent = arch

    -- Top beam
    local topBeam = Instance.new("Part")
    topBeam.Name = "TopBeam"
    topBeam.Anchored = true
    topBeam.Size = Vector3.new(10, 1, 1)
    topBeam.Position = Vector3.new(0, 15, 0)
    topBeam.Color = archColor
    topBeam.Material = archMaterial
    topBeam.Transparency = 0.3
    topBeam.Parent = arch

    -- Add glow
    local light = Instance.new("PointLight")
    light.Color = archColor
    light.Brightness = 1
    light.Range = 20
    light.Parent = topBeam

    arch.PrimaryPart = topBeam
    return arch
end

function SceneryGenerator:createEndZone()
    local endFolder = Instance.new("Folder")
    endFolder.Name = "EndZone"
    endFolder.Parent = sceneryFolder

    local endZ = PlaceConfig.EndZone.startZ
    local corridorWidth = PlaceConfig.Corridor.width

    -- End zone marker
    local endMarker = Instance.new("Part")
    endMarker.Name = "EndMarker"
    endMarker.Anchored = true
    endMarker.CanCollide = false
    endMarker.Size = Vector3.new(corridorWidth, 20, 2)
    endMarker.Position = Vector3.new(0, 10, endZ)
    endMarker.Color = Color3.fromRGB(255, 215, 0)
    endMarker.Material = Enum.Material.Neon
    endMarker.Transparency = 0.5
    endMarker.Parent = endFolder

    -- Celebration lights
    for i = 1, 10 do
        local light = Instance.new("Part")
        light.Name = "CelebrationLight_" .. i
        light.Anchored = true
        light.CanCollide = false
        light.Shape = Enum.PartType.Ball
        light.Size = Vector3.new(2, 2, 2)
        light.Position = Vector3.new(
            math.random(-10, 10),
            math.random(5, 25),
            endZ + math.random(-5, 5)
        )
        light.Color = Color3.fromHSV(math.random(), 0.8, 1)
        light.Material = Enum.Material.Neon
        light.Transparency = 0.2
        light.Parent = endFolder

        local pointLight = Instance.new("PointLight")
        pointLight.Color = light.Color
        pointLight.Brightness = 1
        pointLight.Range = 15
        pointLight.Parent = light
    end
end

function SceneryGenerator:getFolder(): Folder?
    return sceneryFolder
end

function SceneryGenerator:clear()
    if sceneryFolder then
        sceneryFolder:Destroy()
        sceneryFolder = nil
    end
end

return SceneryGenerator
