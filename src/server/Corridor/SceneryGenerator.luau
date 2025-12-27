--!strict
--[[
    Corridor/SceneryGenerator.luau
    Generates dynamic scenery outside the glass corridor for each zone

    Creates immersive environments with floating elements, ground features,
    and zone-specific structures to make each zone visually distinct.

    Version: 2.0.0
]]

local VERSION = "2.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SceneryGenerator = {}

-- Dependencies
local PlaceConfig: any
local SceneryZones: any

-- Generated scenery container
local sceneryFolder: Folder

-- Scenery configuration
local SCENERY_CONFIG = {
    offsetFromCorridor = 25,
    elementsPerZone = 40,
    minHeight = 3,
    maxHeight = 50,
    groundOffset = -8,
}

function SceneryGenerator:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    SceneryZones = require(script.Parent.SceneryZones)

    print("[SceneryGenerator v" .. VERSION .. "] Initialized")
end

function SceneryGenerator:generate()
    sceneryFolder = Instance.new("Folder")
    sceneryFolder.Name = "Scenery"
    sceneryFolder.Parent = workspace

    for _, zone in PlaceConfig.Zones do
        self:generateZoneScenery(zone)
    end

    self:createSpawnRoom()
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

    -- Ground planes
    self:createGroundPlanes(zoneFolder, zone, theme)

    -- Floating scenery on both sides
    for side = -1, 1, 2 do
        local baseX = side * SCENERY_CONFIG.offsetFromCorridor

        -- Large background structures
        self:createBackgroundStructures(zoneFolder, zone, theme, side)

        -- Medium floating elements
        for i = 1, math.floor(SCENERY_CONFIG.elementsPerZone / 2) do
            local zPos = zone.startZ + (i / (SCENERY_CONFIG.elementsPerZone / 2)) * zoneLength
            local xOffset = baseX + math.random(-8, 8)
            local yPos = math.random(SCENERY_CONFIG.minHeight, SCENERY_CONFIG.maxHeight)

            local element = self:createThemeElement(theme, zone.difficulty)
            element.Position = Vector3.new(xOffset, yPos, zPos + math.random(-20, 20))
            element.Parent = zoneFolder
        end
    end

    -- Zone-specific features
    self:addZoneFeatures(zoneFolder, zone, theme)
end

function SceneryGenerator:createBackgroundStructures(folder: Folder, zone: PlaceConfig.Zone, theme: SceneryZones.ZoneTheme, side: number)
    local zoneLength = zone.endZ - zone.startZ
    local structureCount = 5

    for i = 1, structureCount do
        local zPos = zone.startZ + (i / structureCount) * zoneLength
        local xBase = side * (SCENERY_CONFIG.offsetFromCorridor + 30 + math.random(0, 20))

        -- Create tall column/pillar
        local pillar = Instance.new("Part")
        pillar.Name = "Pillar_" .. i
        pillar.Anchored = true
        pillar.CanCollide = false
        pillar.CastShadow = false

        local height = 30 + math.random() * 50
        pillar.Size = Vector3.new(4 + math.random() * 6, height, 4 + math.random() * 6)
        pillar.Position = Vector3.new(xBase, height / 2 - 5, zPos)
        pillar.Color = theme.primaryColor
        pillar.Material = Enum.Material.Neon
        pillar.Transparency = 0.4

        -- Add glow
        local light = Instance.new("PointLight")
        light.Color = theme.accentColor
        light.Brightness = 0.8
        light.Range = 25
        light.Parent = pillar

        pillar.Parent = folder

        -- Add floating orbs around pillars
        for j = 1, 3 do
            local orb = Instance.new("Part")
            orb.Name = "Orb_" .. i .. "_" .. j
            orb.Shape = Enum.PartType.Ball
            orb.Anchored = true
            orb.CanCollide = false
            orb.CastShadow = false
            orb.Size = Vector3.new(2, 2, 2) * (0.5 + math.random())
            orb.Position = pillar.Position + Vector3.new(
                math.random(-10, 10),
                math.random(-10, 20),
                math.random(-10, 10)
            )
            orb.Color = theme.accentColor
            orb.Material = Enum.Material.Neon
            orb.Transparency = 0.2
            orb.Parent = folder

            local orbLight = Instance.new("PointLight")
            orbLight.Color = theme.accentColor
            orbLight.Brightness = 1.5
            orbLight.Range = 15
            orbLight.Parent = orb
        end
    end
end

function SceneryGenerator:createThemeElement(theme: SceneryZones.ZoneTheme, difficulty: number): BasePart
    local element: BasePart
    local shapeRoll = math.random(1, 5)

    if shapeRoll == 1 then
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Ball
        local size = 1.5 + math.random() * 3
        element.Size = Vector3.new(size, size, size)
    elseif shapeRoll == 2 then
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Block
        element.Size = Vector3.new(
            1 + math.random() * 4,
            1 + math.random() * 4,
            1 + math.random() * 4
        )
    elseif shapeRoll == 3 then
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Cylinder
        element.Size = Vector3.new(2 + math.random() * 4, 1 + math.random() * 8, 2 + math.random() * 4)
    elseif shapeRoll == 4 then
        element = Instance.new("WedgePart")
        local size = 1.5 + math.random() * 3
        element.Size = Vector3.new(size, size, size * 1.5)
    else
        element = Instance.new("Part")
        element.Shape = Enum.PartType.Ball
        local size = 0.8 + math.random() * 1.5
        element.Size = Vector3.new(size, size, size)
    end

    element.Color = if math.random() > 0.4 then theme.primaryColor else theme.secondaryColor
    element.Material = Enum.Material.Neon
    element.Transparency = 0.25 + math.random() * 0.35
    element.Anchored = true
    element.CanCollide = false
    element.CastShadow = false

    element.CFrame = element.CFrame * CFrame.Angles(
        math.rad(math.random(0, 360)),
        math.rad(math.random(0, 360)),
        math.rad(math.random(0, 360))
    )

    if math.random() > 0.6 then
        local light = Instance.new("PointLight")
        light.Color = theme.accentColor
        light.Brightness = 0.6 + math.random() * 0.6
        light.Range = 8 + math.random() * 12
        light.Parent = element
    end

    element.Name = "FloatingElement"
    return element
end

function SceneryGenerator:createGroundPlanes(folder: Folder, zone: PlaceConfig.Zone, theme: SceneryZones.ZoneTheme)
    local corridorWidth = PlaceConfig.Corridor.width
    local groundWidth = 150
    local zoneLength = zone.endZ - zone.startZ

    for side = -1, 1, 2 do
        local ground = Instance.new("Part")
        ground.Name = "Ground_" .. (side == -1 and "Left" or "Right")
        ground.Anchored = true
        ground.CanCollide = false
        ground.CastShadow = false
        ground.Size = Vector3.new(groundWidth, 2, zoneLength + 20)
        ground.Position = Vector3.new(
            side * (corridorWidth / 2 + groundWidth / 2 + 3),
            SCENERY_CONFIG.groundOffset,
            zone.startZ + zoneLength / 2
        )
        ground.Color = theme.primaryColor
        ground.Material = Enum.Material.Neon
        ground.Transparency = 0.5
        ground.Parent = folder

        -- Add subtle ground glow
        local glow = Instance.new("PointLight")
        glow.Color = theme.primaryColor
        glow.Brightness = 0.3
        glow.Range = 50
        glow.Parent = ground
    end
end

function SceneryGenerator:addZoneFeatures(folder: Folder, zone: PlaceConfig.Zone, theme: SceneryZones.ZoneTheme)
    local zoneCenter = (zone.startZ + zone.endZ) / 2

    -- Zone entrance marker
    for side = -1, 1, 2 do
        local marker = Instance.new("Part")
        marker.Name = "ZoneMarker_" .. (side == -1 and "Left" or "Right")
        marker.Anchored = true
        marker.CanCollide = false
        marker.Size = Vector3.new(2, 25, 2)
        marker.Position = Vector3.new(
            side * (PlaceConfig.Corridor.width / 2 + 8),
            12,
            zone.startZ
        )
        marker.Color = theme.accentColor
        marker.Material = Enum.Material.Neon
        marker.Transparency = 0.3
        marker.Parent = folder

        local markerLight = Instance.new("PointLight")
        markerLight.Color = theme.accentColor
        markerLight.Brightness = 2
        markerLight.Range = 30
        markerLight.Parent = marker
    end
end

function SceneryGenerator:createSpawnRoom()
    local spawnFolder = Instance.new("Folder")
    spawnFolder.Name = "SpawnRoom"
    spawnFolder.Parent = sceneryFolder

    local corridorWidth = PlaceConfig.Corridor.width
    local roomDepth = 25
    local roomHeight = PlaceConfig.Corridor.height

    -- Back wall
    local backWall = Instance.new("Part")
    backWall.Name = "BackWall"
    backWall.Anchored = true
    backWall.Size = Vector3.new(corridorWidth + 8, roomHeight, 2)
    backWall.Position = Vector3.new(0, roomHeight / 2, -roomDepth)
    backWall.Color = Color3.fromRGB(30, 30, 40)
    backWall.Material = Enum.Material.SmoothPlastic
    backWall.Parent = spawnFolder

    -- Side walls
    for side = -1, 1, 2 do
        local sideWall = Instance.new("Part")
        sideWall.Name = "SideWall_" .. (side == -1 and "Left" or "Right")
        sideWall.Anchored = true
        sideWall.Size = Vector3.new(2, roomHeight, roomDepth)
        sideWall.Position = Vector3.new(side * (corridorWidth / 2 + 4), roomHeight / 2, -roomDepth / 2)
        sideWall.Color = Color3.fromRGB(30, 30, 40)
        sideWall.Material = Enum.Material.SmoothPlastic
        sideWall.Parent = spawnFolder
    end

    -- Floor
    local floor = Instance.new("Part")
    floor.Name = "SpawnFloor"
    floor.Anchored = true
    floor.Size = Vector3.new(corridorWidth + 8, 1, roomDepth)
    floor.Position = Vector3.new(0, 0, -roomDepth / 2)
    floor.Color = Color3.fromRGB(50, 50, 60)
    floor.Material = Enum.Material.SmoothPlastic
    floor.Parent = spawnFolder

    -- Entrance arch
    local arch = self:createArch()
    arch.Parent = spawnFolder

    -- Welcome sign
    local welcomePart = Instance.new("Part")
    welcomePart.Name = "WelcomeSign"
    welcomePart.Anchored = true
    welcomePart.CanCollide = false
    welcomePart.Size = Vector3.new(10, 3, 0.5)
    welcomePart.Position = Vector3.new(0, 14, -roomDepth + 3)
    welcomePart.Color = Color3.fromRGB(0, 200, 255)
    welcomePart.Material = Enum.Material.Neon
    welcomePart.Transparency = 0.2
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

    local signLight = Instance.new("PointLight")
    signLight.Color = Color3.fromRGB(0, 200, 255)
    signLight.Brightness = 2
    signLight.Range = 25
    signLight.Parent = welcomePart
end

function SceneryGenerator:createArch(): Model
    local arch = Instance.new("Model")
    arch.Name = "EntranceArch"

    local archColor = Color3.fromRGB(0, 200, 255)

    local leftPillar = Instance.new("Part")
    leftPillar.Name = "LeftPillar"
    leftPillar.Anchored = true
    leftPillar.Size = Vector3.new(1.5, 18, 1.5)
    leftPillar.Position = Vector3.new(-5, 9, 0)
    leftPillar.Color = archColor
    leftPillar.Material = Enum.Material.Neon
    leftPillar.Transparency = 0.25
    leftPillar.Parent = arch

    local rightPillar = leftPillar:Clone()
    rightPillar.Name = "RightPillar"
    rightPillar.Position = Vector3.new(5, 9, 0)
    rightPillar.Parent = arch

    local topBeam = Instance.new("Part")
    topBeam.Name = "TopBeam"
    topBeam.Anchored = true
    topBeam.Size = Vector3.new(12, 1.5, 1.5)
    topBeam.Position = Vector3.new(0, 18, 0)
    topBeam.Color = archColor
    topBeam.Material = Enum.Material.Neon
    topBeam.Transparency = 0.25
    topBeam.Parent = arch

    local light = Instance.new("PointLight")
    light.Color = archColor
    light.Brightness = 1.5
    light.Range = 25
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

    -- Victory arch
    local endMarker = Instance.new("Part")
    endMarker.Name = "EndMarker"
    endMarker.Anchored = true
    endMarker.CanCollide = false
    endMarker.Size = Vector3.new(corridorWidth + 4, 25, 3)
    endMarker.Position = Vector3.new(0, 12, endZ)
    endMarker.Color = Color3.fromRGB(255, 215, 0)
    endMarker.Material = Enum.Material.Neon
    endMarker.Transparency = 0.4
    endMarker.Parent = endFolder

    -- Celebration lights
    for i = 1, 15 do
        local light = Instance.new("Part")
        light.Name = "CelebrationLight_" .. i
        light.Anchored = true
        light.CanCollide = false
        light.Shape = Enum.PartType.Ball
        light.Size = Vector3.new(2.5, 2.5, 2.5)
        light.Position = Vector3.new(
            math.random(-15, 15),
            math.random(5, 30),
            endZ + math.random(-8, 8)
        )
        light.Color = Color3.fromHSV(math.random(), 0.9, 1)
        light.Material = Enum.Material.Neon
        light.Transparency = 0.15
        light.Parent = endFolder

        local pointLight = Instance.new("PointLight")
        pointLight.Color = light.Color
        pointLight.Brightness = 1.5
        pointLight.Range = 20
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
