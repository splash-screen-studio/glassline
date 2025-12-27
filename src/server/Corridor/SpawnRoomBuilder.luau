--!strict
--[[
    Corridor/SpawnRoomBuilder.luau
    Builds the spawn room at the start of the corridor

    Version: 1.0.0
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SpawnRoomBuilder = {}

local PlaceConfig: any

function SpawnRoomBuilder:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)

    print("[SpawnRoomBuilder v" .. VERSION .. "] Initialized")
end

function SpawnRoomBuilder:build()
    local existing = workspace:FindFirstChild("SpawnRoom")
    if existing then existing:Destroy() end

    local spawnRoom = Instance.new("Folder")
    spawnRoom.Name = "SpawnRoom"
    spawnRoom.Parent = workspace

    local corridorWidth = PlaceConfig.Corridor.width
    local roomDepth = PlaceConfig.SpawnRoom.depth
    local roomWidth = PlaceConfig.SpawnRoom.width
    local roomHeight = PlaceConfig.SpawnRoom.height

    -- Floor
    local floor = Instance.new("Part")
    floor.Name = "SpawnFloor"
    floor.Anchored = true
    floor.Size = Vector3.new(roomWidth, 1, roomDepth)
    floor.Position = Vector3.new(0, 0, -roomDepth/2)
    floor.Material = Enum.Material.SmoothPlastic
    floor.Color = Color3.fromRGB(60, 60, 70)
    floor.Parent = spawnRoom

    -- Back wall
    local backWall = Instance.new("Part")
    backWall.Name = "BackWall"
    backWall.Anchored = true
    backWall.Size = Vector3.new(roomWidth, roomHeight, 1)
    backWall.Position = Vector3.new(0, roomHeight/2, -roomDepth)
    backWall.Material = Enum.Material.SmoothPlastic
    backWall.Color = Color3.fromRGB(40, 40, 50)
    backWall.Parent = spawnRoom

    -- Left wall
    local leftWall = Instance.new("Part")
    leftWall.Name = "LeftWall"
    leftWall.Anchored = true
    leftWall.Size = Vector3.new(1, roomHeight, roomDepth)
    leftWall.Position = Vector3.new(-roomWidth/2, roomHeight/2, -roomDepth/2)
    leftWall.Material = Enum.Material.SmoothPlastic
    leftWall.Color = Color3.fromRGB(40, 40, 50)
    leftWall.Parent = spawnRoom

    -- Right wall
    local rightWall = Instance.new("Part")
    rightWall.Name = "RightWall"
    rightWall.Anchored = true
    rightWall.Size = Vector3.new(1, roomHeight, roomDepth)
    rightWall.Position = Vector3.new(roomWidth/2, roomHeight/2, -roomDepth/2)
    rightWall.Material = Enum.Material.SmoothPlastic
    rightWall.Color = Color3.fromRGB(40, 40, 50)
    rightWall.Parent = spawnRoom

    -- Ceiling
    local ceiling = Instance.new("Part")
    ceiling.Name = "Ceiling"
    ceiling.Anchored = true
    ceiling.Size = Vector3.new(roomWidth, 1, roomDepth)
    ceiling.Position = Vector3.new(0, roomHeight, -roomDepth/2)
    ceiling.Material = Enum.Material.SmoothPlastic
    ceiling.Color = Color3.fromRGB(40, 40, 50)
    ceiling.Parent = spawnRoom

    -- Entry arch
    local archColor = Color3.fromRGB(0, 200, 255)

    local leftPillar = Instance.new("Part")
    leftPillar.Name = "LeftPillar"
    leftPillar.Anchored = true
    leftPillar.Size = Vector3.new(1, roomHeight, 1)
    leftPillar.Position = Vector3.new(-corridorWidth/2 - 0.5, roomHeight/2, 0)
    leftPillar.Material = Enum.Material.Neon
    leftPillar.Color = archColor
    leftPillar.Transparency = 0.3
    leftPillar.Parent = spawnRoom

    local rightPillar = leftPillar:Clone()
    rightPillar.Name = "RightPillar"
    rightPillar.Position = Vector3.new(corridorWidth/2 + 0.5, roomHeight/2, 0)
    rightPillar.Parent = spawnRoom

    local topBeam = Instance.new("Part")
    topBeam.Name = "TopBeam"
    topBeam.Anchored = true
    topBeam.Size = Vector3.new(corridorWidth + 2, 1, 1)
    topBeam.Position = Vector3.new(0, roomHeight, 0)
    topBeam.Material = Enum.Material.Neon
    topBeam.Color = archColor
    topBeam.Transparency = 0.3
    topBeam.Parent = spawnRoom

    local light = Instance.new("PointLight")
    light.Color = archColor
    light.Brightness = 1.5
    light.Range = 30
    light.Parent = topBeam

    -- SpawnLocation
    local spawn = workspace:FindFirstChild("SpawnLocation")
    if not spawn then
        spawn = Instance.new("SpawnLocation")
        spawn.Name = "SpawnLocation"
        spawn.Parent = workspace
    end
    spawn.Anchored = true
    spawn.Size = Vector3.new(6, 1, 6)
    spawn.Position = PlaceConfig.Spawn.position - Vector3.new(0, 2, 0)
    spawn.Transparency = 1
    spawn.CanCollide = false

    print("[SpawnRoomBuilder v" .. VERSION .. "] Spawn room built")
end

return SpawnRoomBuilder
