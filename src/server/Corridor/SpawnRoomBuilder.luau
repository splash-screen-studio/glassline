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

    -- Front walls (seal the sides, leaving only corridor-width opening)
    local sideWallWidth = (roomWidth - corridorWidth) / 2

    local frontLeftWall = Instance.new("Part")
    frontLeftWall.Name = "FrontLeftWall"
    frontLeftWall.Anchored = true
    frontLeftWall.Size = Vector3.new(sideWallWidth, roomHeight, 1)
    frontLeftWall.Position = Vector3.new(-roomWidth/2 + sideWallWidth/2, roomHeight/2, 0)
    frontLeftWall.Material = Enum.Material.SmoothPlastic
    frontLeftWall.Color = Color3.fromRGB(40, 40, 50)
    frontLeftWall.Parent = spawnRoom

    local frontRightWall = Instance.new("Part")
    frontRightWall.Name = "FrontRightWall"
    frontRightWall.Anchored = true
    frontRightWall.Size = Vector3.new(sideWallWidth, roomHeight, 1)
    frontRightWall.Position = Vector3.new(roomWidth/2 - sideWallWidth/2, roomHeight/2, 0)
    frontRightWall.Material = Enum.Material.SmoothPlastic
    frontRightWall.Color = Color3.fromRGB(40, 40, 50)
    frontRightWall.Parent = spawnRoom

    -- Entry arch (at the corridor opening)
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

    -- ========== DRAMATIC EXIT EFFECTS ==========
    -- NOTE: Ground fog removed - was fogging up the corridor glass

    -- Rising smoke columns (left side)
    local smokeLeftEmitter = Instance.new("Part")
    smokeLeftEmitter.Name = "SmokeLeftEmitter"
    smokeLeftEmitter.Anchored = true
    smokeLeftEmitter.CanCollide = false
    smokeLeftEmitter.Transparency = 1
    smokeLeftEmitter.Size = Vector3.new(2, 1, 4)
    smokeLeftEmitter.Position = Vector3.new(-corridorWidth/2 - 1, 0.5, 3)
    smokeLeftEmitter.Parent = spawnRoom

    local smokeLeft = Instance.new("ParticleEmitter")
    smokeLeft.Name = "RisingSmoke"
    smokeLeft.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(0, 200, 255)),
        ColorSequenceKeypoint.new(0.5, Color3.fromRGB(100, 180, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(200, 220, 255)),
    })
    smokeLeft.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.5, 3),
        NumberSequenceKeypoint.new(1, 5)
    })
    smokeLeft.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.5, 0.5),
        NumberSequenceKeypoint.new(1, 1)
    })
    smokeLeft.Lifetime = NumberRange.new(3, 5)
    smokeLeft.Rate = 12
    smokeLeft.Speed = NumberRange.new(4, 8)
    smokeLeft.SpreadAngle = Vector2.new(15, 15)
    smokeLeft.Acceleration = Vector3.new(0, 2, 2)
    smokeLeft.RotSpeed = NumberRange.new(-40, 40)
    smokeLeft.Rotation = NumberRange.new(0, 360)
    smokeLeft.LightEmission = 0.5
    smokeLeft.LightInfluence = 0.3
    smokeLeft.Parent = smokeLeftEmitter

    -- Rising smoke columns (right side)
    local smokeRightEmitter = smokeLeftEmitter:Clone()
    smokeRightEmitter.Name = "SmokeRightEmitter"
    smokeRightEmitter.Position = Vector3.new(corridorWidth/2 + 1, 0.5, 3)
    smokeRightEmitter.Parent = spawnRoom

    -- Sparkle/dust particles floating in the air
    local sparkleEmitter = Instance.new("Part")
    sparkleEmitter.Name = "SparkleEmitter"
    sparkleEmitter.Anchored = true
    sparkleEmitter.CanCollide = false
    sparkleEmitter.Transparency = 1
    sparkleEmitter.Size = Vector3.new(corridorWidth, roomHeight/2, 10)
    sparkleEmitter.Position = Vector3.new(0, roomHeight/3, 5)
    sparkleEmitter.Parent = spawnRoom

    local sparkles = Instance.new("ParticleEmitter")
    sparkles.Name = "Sparkles"
    sparkles.Color = ColorSequence.new(Color3.fromRGB(200, 240, 255))
    sparkles.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0),
        NumberSequenceKeypoint.new(0.2, 0.3),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 0)
    })
    sparkles.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 1),
        NumberSequenceKeypoint.new(0.2, 0.3),
        NumberSequenceKeypoint.new(0.8, 0.3),
        NumberSequenceKeypoint.new(1, 1)
    })
    sparkles.Lifetime = NumberRange.new(2, 4)
    sparkles.Rate = 30
    sparkles.Speed = NumberRange.new(0.5, 2)
    sparkles.SpreadAngle = Vector2.new(180, 180)
    sparkles.LightEmission = 1
    sparkles.LightInfluence = 0
    sparkles.Parent = sparkleEmitter

    -- Central dramatic smoke burst
    local centralSmokeEmitter = Instance.new("Part")
    centralSmokeEmitter.Name = "CentralSmokeEmitter"
    centralSmokeEmitter.Anchored = true
    centralSmokeEmitter.CanCollide = false
    centralSmokeEmitter.Transparency = 1
    centralSmokeEmitter.Size = Vector3.new(corridorWidth, 1, 3)
    centralSmokeEmitter.Position = Vector3.new(0, 0.5, 2)
    centralSmokeEmitter.Parent = spawnRoom

    local centralSmoke = Instance.new("ParticleEmitter")
    centralSmoke.Name = "CentralSmoke"
    centralSmoke.Color = ColorSequence.new({
        ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
        ColorSequenceKeypoint.new(0.3, Color3.fromRGB(150, 200, 255)),
        ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 150, 255)),
    })
    centralSmoke.Size = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 2),
        NumberSequenceKeypoint.new(0.3, 5),
        NumberSequenceKeypoint.new(0.6, 8),
        NumberSequenceKeypoint.new(1, 10)
    })
    centralSmoke.Transparency = NumberSequence.new({
        NumberSequenceKeypoint.new(0, 0.2),
        NumberSequenceKeypoint.new(0.4, 0.4),
        NumberSequenceKeypoint.new(0.7, 0.7),
        NumberSequenceKeypoint.new(1, 1)
    })
    centralSmoke.Lifetime = NumberRange.new(3, 5)
    centralSmoke.Rate = 20
    centralSmoke.Speed = NumberRange.new(3, 7)
    centralSmoke.SpreadAngle = Vector2.new(40, 20)
    centralSmoke.Acceleration = Vector3.new(0, 1, 3)
    centralSmoke.RotSpeed = NumberRange.new(-30, 30)
    centralSmoke.Rotation = NumberRange.new(0, 360)
    centralSmoke.LightEmission = 0.4
    centralSmoke.LightInfluence = 0.4
    centralSmoke.Parent = centralSmokeEmitter

    -- ========== FLOOR GLOW EFFECTS ==========

    -- Main floor glow strip at exit
    local glowStrip = Instance.new("Part")
    glowStrip.Name = "ExitGlow"
    glowStrip.Anchored = true
    glowStrip.CanCollide = false
    glowStrip.Size = Vector3.new(corridorWidth, 0.3, 4)
    glowStrip.Position = Vector3.new(0, 0.65, 4)
    glowStrip.Material = Enum.Material.Neon
    glowStrip.Color = archColor
    glowStrip.Transparency = 0.2
    glowStrip.Parent = spawnRoom

    local glowLight = Instance.new("PointLight")
    glowLight.Color = archColor
    glowLight.Brightness = 4
    glowLight.Range = 20
    glowLight.Parent = glowStrip

    -- Secondary glow strips (staggered)
    for i = 1, 3 do
        local strip = Instance.new("Part")
        strip.Name = "GlowStrip" .. i
        strip.Anchored = true
        strip.CanCollide = false
        strip.Size = Vector3.new(corridorWidth - i, 0.2, 0.5)
        strip.Position = Vector3.new(0, 0.6, 4 + i * 3)
        strip.Material = Enum.Material.Neon
        strip.Color = archColor
        strip.Transparency = 0.3 + i * 0.1
        strip.Parent = spawnRoom

        local light = Instance.new("PointLight")
        light.Color = archColor
        light.Brightness = 2 - i * 0.3
        light.Range = 12 - i * 2
        light.Parent = strip
    end

    -- Pulsing effect for the glow strips
    task.spawn(function()
        local strips = {glowStrip}
        for i = 1, 3 do
            local s = spawnRoom:FindFirstChild("GlowStrip" .. i)
            if s then table.insert(strips, s) end
        end

        local time = 0
        while glowStrip.Parent do
            time = time + task.wait(0.03)
            for idx, strip in strips do
                local phase = time * 3 + idx * 0.5
                strip.Transparency = 0.15 + math.sin(phase) * 0.2
            end
        end
    end)

    -- ========== LIGHT BEAMS ==========

    -- Volumetric-style light beams (left)
    local beamLeft = Instance.new("Part")
    beamLeft.Name = "LightBeamLeft"
    beamLeft.Anchored = true
    beamLeft.CanCollide = false
    beamLeft.Size = Vector3.new(0.5, roomHeight, 0.5)
    beamLeft.Position = Vector3.new(-corridorWidth/2 + 0.5, roomHeight/2, 1)
    beamLeft.Material = Enum.Material.Neon
    beamLeft.Color = archColor
    beamLeft.Transparency = 0.6
    beamLeft.Parent = spawnRoom

    local beamLeftLight = Instance.new("PointLight")
    beamLeftLight.Color = archColor
    beamLeftLight.Brightness = 2
    beamLeftLight.Range = 10
    beamLeftLight.Parent = beamLeft

    -- Volumetric-style light beams (right)
    local beamRight = beamLeft:Clone()
    beamRight.Name = "LightBeamRight"
    beamRight.Position = Vector3.new(corridorWidth/2 - 0.5, roomHeight/2, 1)
    beamRight.Parent = spawnRoom

    -- Animated color-cycling for beams
    task.spawn(function()
        local time = 0
        while beamLeft.Parent do
            time = time + task.wait(0.05)
            local hue = (time * 0.1) % 1
            local color = Color3.fromHSV(hue, 0.5, 1)
            beamLeft.Color = color
            beamRight.Color = color
            beamLeftLight.Color = color
            local rightLight = beamRight:FindFirstChildOfClass("PointLight")
            if rightLight then rightLight.Color = color end
        end
    end)

    -- ========== SPOTLIGHTS ==========

    -- Main spotlight beam pointing down the corridor
    local spotlightPart = Instance.new("Part")
    spotlightPart.Name = "SpotlightMount"
    spotlightPart.Anchored = true
    spotlightPart.CanCollide = false
    spotlightPart.Transparency = 1
    spotlightPart.Size = Vector3.new(1, 1, 1)
    spotlightPart.Position = Vector3.new(0, roomHeight - 2, 0)
    spotlightPart.Parent = spawnRoom

    local spotlight = Instance.new("SpotLight")
    spotlight.Brightness = 5
    spotlight.Range = 80
    spotlight.Angle = 50
    spotlight.Color = archColor
    spotlight.Face = Enum.NormalId.Front
    spotlight.Parent = spotlightPart

    -- Side spotlights (dramatic cross-lighting)
    local spotLeft = Instance.new("Part")
    spotLeft.Name = "SpotlightLeft"
    spotLeft.Anchored = true
    spotLeft.CanCollide = false
    spotLeft.Transparency = 1
    spotLeft.Size = Vector3.new(1, 1, 1)
    spotLeft.Position = Vector3.new(-corridorWidth/2, roomHeight - 3, -2)
    spotLeft.CFrame = CFrame.new(spotLeft.Position, Vector3.new(corridorWidth/2, 0, 10))
    spotLeft.Parent = spawnRoom

    local spotLeftLight = Instance.new("SpotLight")
    spotLeftLight.Brightness = 3
    spotLeftLight.Range = 50
    spotLeftLight.Angle = 35
    spotLeftLight.Color = Color3.fromRGB(255, 100, 150)
    spotLeftLight.Face = Enum.NormalId.Front
    spotLeftLight.Parent = spotLeft

    local spotRight = spotLeft:Clone()
    spotRight.Name = "SpotlightRight"
    spotRight.Position = Vector3.new(corridorWidth/2, roomHeight - 3, -2)
    spotRight.CFrame = CFrame.new(spotRight.Position, Vector3.new(-corridorWidth/2, 0, 10))
    local spotRightLight = spotRight:FindFirstChildOfClass("SpotLight")
    if spotRightLight then spotRightLight.Color = Color3.fromRGB(100, 150, 255) end
    spotRight.Parent = spawnRoom

    -- Animated spotlight sweep
    task.spawn(function()
        local time = 0
        while spotLeft.Parent do
            time = time + task.wait(0.03)
            local angle = math.sin(time * 0.8) * 20
            spotLeft.CFrame = CFrame.new(spotLeft.Position) * CFrame.Angles(0, math.rad(angle), 0) * CFrame.Angles(math.rad(30), 0, 0)
            spotRight.CFrame = CFrame.new(spotRight.Position) * CFrame.Angles(0, math.rad(-angle), 0) * CFrame.Angles(math.rad(30), 0, 0)
        end
    end)

    -- ========== CEILING EFFECTS ==========

    -- Ceiling glow panels
    for i = 0, 2 do
        local ceilingGlow = Instance.new("Part")
        ceilingGlow.Name = "CeilingGlow" .. i
        ceilingGlow.Anchored = true
        ceilingGlow.CanCollide = false
        ceilingGlow.Size = Vector3.new(2, 0.3, 2)
        ceilingGlow.Position = Vector3.new((i - 1) * 2.5, roomHeight - 0.5, 2)
        ceilingGlow.Material = Enum.Material.Neon
        ceilingGlow.Color = archColor
        ceilingGlow.Transparency = 0.4
        ceilingGlow.Parent = spawnRoom

        local cLight = Instance.new("PointLight")
        cLight.Color = archColor
        cLight.Brightness = 3
        cLight.Range = 15
        cLight.Parent = ceilingGlow
    end

    -- Corridor walls extending from spawn room to main corridor
    -- These seal the sides so player can only go through the corridor
    local corridorWallLength = 100  -- Extend walls into the corridor area

    local corridorLeftWall = Instance.new("Part")
    corridorLeftWall.Name = "CorridorLeftWall"
    corridorLeftWall.Anchored = true
    corridorLeftWall.Size = Vector3.new(1, roomHeight, corridorWallLength)
    corridorLeftWall.Position = Vector3.new(-corridorWidth/2 - 0.5, roomHeight/2, corridorWallLength/2)
    corridorLeftWall.Material = Enum.Material.Glass
    corridorLeftWall.Color = Color3.fromRGB(200, 220, 255)
    corridorLeftWall.Transparency = 0.5
    corridorLeftWall.Parent = spawnRoom

    local corridorRightWall = Instance.new("Part")
    corridorRightWall.Name = "CorridorRightWall"
    corridorRightWall.Anchored = true
    corridorRightWall.Size = Vector3.new(1, roomHeight, corridorWallLength)
    corridorRightWall.Position = Vector3.new(corridorWidth/2 + 0.5, roomHeight/2, corridorWallLength/2)
    corridorRightWall.Material = Enum.Material.Glass
    corridorRightWall.Color = Color3.fromRGB(200, 220, 255)
    corridorRightWall.Transparency = 0.5
    corridorRightWall.Parent = spawnRoom

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
