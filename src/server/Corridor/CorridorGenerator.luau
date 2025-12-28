--!strict
--[[
    Corridor/CorridorGenerator.luau
    Procedural generation of the glass corridor, floor, and obstacles
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")

local CorridorGenerator = {}

-- Dependencies
local PlaceConfig: any
local ObstacleDefinitions: any
local SceneryZones: any
local DeathService: any

-- Generated parts container
local corridorFolder: Folder

function CorridorGenerator:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    ObstacleDefinitions = require(script.Parent.ObstacleDefinitions)
    SceneryZones = require(script.Parent.SceneryZones)

    local Server = script.Parent.Parent
    DeathService = require(Server.Death.DeathService)

    print("[CorridorGenerator v" .. VERSION .. "] Initialized")
end

function CorridorGenerator:generate()
    -- Create container folder
    corridorFolder = Instance.new("Folder")
    corridorFolder.Name = "GlasslineCorridor"
    corridorFolder.Parent = workspace

    -- Generate corridor segments
    self:generateFloor()
    self:generateWalls()
    self:generateCeiling()
    self:generateObstacles()

    -- Apply initial lighting
    self:applyZoneLighting("realistic_forest")

    print("[CorridorGenerator v" .. VERSION .. "] Generated corridor:",
        PlaceConfig.Corridor.length, "studs long")
end

function CorridorGenerator:generateFloor()
    local floorFolder = Instance.new("Folder")
    floorFolder.Name = "Floor"
    floorFolder.Parent = corridorFolder

    local config = PlaceConfig.Corridor
    local segmentLength = 500 -- Generate in segments for performance

    for z = 0, config.length, segmentLength do
        local length = math.min(segmentLength, config.length - z)

        local floor = Instance.new("Part")
        floor.Name = "FloorSegment_" .. z
        floor.Anchored = true
        floor.Size = Vector3.new(config.width, 1, length)
        floor.Position = Vector3.new(0, 0, z + length / 2)
        floor.Material = config.floorMaterial
        floor.Color = Color3.fromRGB(200, 200, 200)
        floor.TopSurface = Enum.SurfaceType.Smooth
        floor.BottomSurface = Enum.SurfaceType.Smooth
        floor.Parent = floorFolder
    end
end

function CorridorGenerator:generateWalls()
    local wallsFolder = Instance.new("Folder")
    wallsFolder.Name = "Walls"
    wallsFolder.Parent = corridorFolder

    local config = PlaceConfig.Corridor
    local segmentLength = 500

    for z = 0, config.length, segmentLength do
        local length = math.min(segmentLength, config.length - z)

        -- Left wall
        local leftWall = Instance.new("Part")
        leftWall.Name = "LeftWall_" .. z
        leftWall.Anchored = true
        leftWall.Size = Vector3.new(config.wallThickness, config.height, length)
        leftWall.Position = Vector3.new(-config.width / 2 - config.wallThickness / 2, config.height / 2, z + length / 2)
        leftWall.Material = config.wallMaterial or Enum.Material.SmoothPlastic
        leftWall.Color = config.wallColor
        leftWall.Transparency = config.wallTransparency
        leftWall.CanCollide = true
        leftWall.Parent = wallsFolder

        -- Right wall
        local rightWall = Instance.new("Part")
        rightWall.Name = "RightWall_" .. z
        rightWall.Anchored = true
        rightWall.Size = Vector3.new(config.wallThickness, config.height, length)
        rightWall.Position = Vector3.new(config.width / 2 + config.wallThickness / 2, config.height / 2, z + length / 2)
        rightWall.Material = config.wallMaterial or Enum.Material.SmoothPlastic
        rightWall.Color = config.wallColor
        rightWall.Transparency = config.wallTransparency
        rightWall.CanCollide = true
        rightWall.Parent = wallsFolder
    end
end

function CorridorGenerator:generateCeiling()
    local ceilingFolder = Instance.new("Folder")
    ceilingFolder.Name = "Ceiling"
    ceilingFolder.Parent = corridorFolder

    local config = PlaceConfig.Corridor
    local segmentLength = 500

    for z = 0, config.length, segmentLength do
        local length = math.min(segmentLength, config.length - z)

        local ceiling = Instance.new("Part")
        ceiling.Name = "CeilingSegment_" .. z
        ceiling.Anchored = true
        ceiling.Size = Vector3.new(config.width + config.wallThickness * 2, config.wallThickness, length)
        ceiling.Position = Vector3.new(0, config.height, z + length / 2)
        ceiling.Material = config.ceilingMaterial
        ceiling.Color = config.wallColor
        ceiling.Transparency = config.wallTransparency
        ceiling.CanCollide = true
        ceiling.Parent = ceilingFolder
    end
end

function CorridorGenerator:generateObstacles()
    local obstaclesFolder = Instance.new("Folder")
    obstaclesFolder.Name = "Obstacles"
    obstaclesFolder.Parent = corridorFolder

    -- No obstacles in the first 200 studs (safe zone after spawn)
    local SAFE_ZONE_END = 200

    -- Generate obstacles for each zone
    for _, zone in PlaceConfig.Zones do
        local frequency = PlaceConfig.getObstacleFrequency(zone.difficulty)
        local zoneLength = zone.endZ - zone.startZ

        -- Number of obstacles based on frequency
        local numObstacles = math.floor(zoneLength * frequency / 10)

        for i = 1, numObstacles do
            -- Random position within zone
            local z = zone.startZ + math.random() * zoneLength

            -- Skip if in safe zone
            if z < SAFE_ZONE_END then
                continue
            end

            -- Pick random obstacle type based on difficulty
            local obstacleDef = ObstacleDefinitions.getRandomForDifficulty(zone.difficulty)
            if obstacleDef then
                local obstacle = self:createObstacle(obstacleDef, z, zone.difficulty)
                obstacle.Parent = obstaclesFolder
            end
        end
    end

    print("[CorridorGenerator] Generated obstacles for", #PlaceConfig.Zones, "zones (safe zone: 0-" .. SAFE_ZONE_END .. ")")
end

function CorridorGenerator:createObstacle(definition: ObstacleDefinitions.ObstacleDefinition, zPosition: number, difficulty: number): Instance
    local config = PlaceConfig.Corridor

    -- Create obstacle part
    local obstacle = Instance.new("Part")
    obstacle.Name = definition.id
    obstacle.Anchored = true
    obstacle.Size = definition.size
    obstacle.Color = definition.color
    obstacle.Material = definition.material or Enum.Material.SmoothPlastic

    -- Position (random X within corridor width, adjusted for obstacle width)
    local maxX = (config.width / 2) - (definition.size.X / 2) - 0.5
    local x = if definition.centered then 0 else (math.random() * 2 - 1) * maxX
    local y = definition.size.Y / 2 + 0.5 -- Slightly above floor

    obstacle.Position = Vector3.new(x, y, zPosition)

    -- Tag for death detection
    DeathService:tagObstacle(obstacle, definition.obstacleType)

    -- Add visual effects
    if definition.visuals then
        self:addObstacleVisuals(obstacle, definition.visuals)
    end

    -- Add movement for moving obstacles
    if definition.movement then
        self:addObstacleMovement(obstacle, definition.movement, difficulty)
    end

    return obstacle
end

function CorridorGenerator:addObstacleVisuals(obstacle: BasePart, visuals: ObstacleDefinitions.VisualConfig)
    -- Add glow light
    if visuals.glowColor then
        local light = Instance.new("PointLight")
        light.Color = visuals.glowColor
        light.Brightness = visuals.glowBrightness or 2
        light.Range = visuals.glowRange or 8
        light.Shadows = false
        light.Parent = obstacle
    end

    -- Add particle effects
    if visuals.particles then
        local emitter = Instance.new("ParticleEmitter")
        emitter.Name = "DangerParticles"

        if visuals.particles == "sparks" then
            emitter.Color = ColorSequence.new(visuals.glowColor or Color3.fromRGB(255, 200, 0))
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(1, 0),
            })
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(1, 1),
            })
            emitter.Lifetime = NumberRange.new(0.2, 0.5)
            emitter.Rate = 20
            emitter.Speed = NumberRange.new(5, 15)
            emitter.SpreadAngle = Vector2.new(180, 180)
            emitter.LightEmission = 1
            emitter.LightInfluence = 0

        elseif visuals.particles == "flames" then
            emitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 200, 50)),
                ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 100, 0)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 20, 0)),
            })
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(0.3, 1),
                NumberSequenceKeypoint.new(1, 0),
            })
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.2),
                NumberSequenceKeypoint.new(0.5, 0.5),
                NumberSequenceKeypoint.new(1, 1),
            })
            emitter.Lifetime = NumberRange.new(0.3, 0.6)
            emitter.Rate = 30
            emitter.Speed = NumberRange.new(3, 8)
            emitter.SpreadAngle = Vector2.new(20, 20)
            emitter.Acceleration = Vector3.new(0, 10, 0)
            emitter.LightEmission = 1
            emitter.LightInfluence = 0

        elseif visuals.particles == "electric" then
            emitter.Color = ColorSequence.new(visuals.glowColor or Color3.fromRGB(100, 200, 255))
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.1),
                NumberSequenceKeypoint.new(0.5, 0.4),
                NumberSequenceKeypoint.new(1, 0),
            })
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0),
                NumberSequenceKeypoint.new(0.8, 0.3),
                NumberSequenceKeypoint.new(1, 1),
            })
            emitter.Lifetime = NumberRange.new(0.1, 0.3)
            emitter.Rate = 40
            emitter.Speed = NumberRange.new(10, 25)
            emitter.SpreadAngle = Vector2.new(180, 180)
            emitter.LightEmission = 1
            emitter.LightInfluence = 0
            emitter.RotSpeed = NumberRange.new(-500, 500)

        elseif visuals.particles == "smoke" then
            emitter.Color = ColorSequence.new({
                ColorSequenceKeypoint.new(0, visuals.glowColor or Color3.fromRGB(100, 255, 100)),
                ColorSequenceKeypoint.new(1, Color3.fromRGB(50, 50, 50)),
            })
            emitter.Size = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.5),
                NumberSequenceKeypoint.new(0.5, 1.5),
                NumberSequenceKeypoint.new(1, 2),
            })
            emitter.Transparency = NumberSequence.new({
                NumberSequenceKeypoint.new(0, 0.3),
                NumberSequenceKeypoint.new(0.5, 0.6),
                NumberSequenceKeypoint.new(1, 1),
            })
            emitter.Lifetime = NumberRange.new(1, 2)
            emitter.Rate = 10
            emitter.Speed = NumberRange.new(1, 3)
            emitter.SpreadAngle = Vector2.new(30, 30)
            emitter.Acceleration = Vector3.new(0, 2, 0)
            emitter.LightEmission = 0.5
            emitter.LightInfluence = 0.5
        end

        emitter.Parent = obstacle
    end

    -- Add pulsing effect
    if visuals.pulseSpeed and visuals.pulseSpeed > 0 then
        task.spawn(function()
            local baseTransparency = obstacle.Transparency
            local speed = visuals.pulseSpeed
            local time = math.random() * math.pi * 2 -- Random start phase

            while obstacle.Parent do
                time = time + task.wait() * speed
                -- Pulse between 0 and 0.3 transparency
                obstacle.Transparency = baseTransparency + math.sin(time) * 0.15 + 0.15
            end
        end)
    end
end

function CorridorGenerator:addObstacleMovement(obstacle: BasePart, movement: ObstacleDefinitions.MovementConfig, difficulty: number)
    -- Scale speed with difficulty
    local speedMultiplier = 1 / (PlaceConfig.Difficulty.timingWindowShrink ^ (difficulty - 1))

    if movement.type == "swing" then
        -- Swinging pendulum motion
        local pivotAttachment = Instance.new("Attachment")
        pivotAttachment.Position = Vector3.new(0, movement.amplitude or 10, 0)
        pivotAttachment.Parent = obstacle

        -- Use script for pendulum motion
        task.spawn(function()
            local startCFrame = obstacle.CFrame
            local amplitude = math.rad(movement.amplitude or 45)
            local speed = (movement.speed or 2) * speedMultiplier
            local time = 0

            while obstacle.Parent do
                time = time + task.wait()
                local angle = math.sin(time * speed) * amplitude
                obstacle.CFrame = startCFrame * CFrame.Angles(0, 0, angle)
            end
        end)

    elseif movement.type == "slide" then
        -- Sliding back and forth
        task.spawn(function()
            local startPos = obstacle.Position
            local distance = movement.distance or 3
            local speed = (movement.speed or 5) * speedMultiplier
            local time = 0

            while obstacle.Parent do
                time = time + task.wait()
                local offset = math.sin(time * speed) * distance
                obstacle.Position = startPos + Vector3.new(offset, 0, 0)
            end
        end)

    elseif movement.type == "rise" then
        -- Rising and falling
        task.spawn(function()
            local startPos = obstacle.Position
            local height = movement.distance or 5
            local speed = (movement.speed or 3) * speedMultiplier
            local time = 0

            while obstacle.Parent do
                time = time + task.wait()
                local offset = (math.sin(time * speed) + 1) / 2 * height
                obstacle.Position = startPos + Vector3.new(0, offset, 0)
            end
        end)

    elseif movement.type == "rotate" then
        -- Rotating bar
        task.spawn(function()
            local speed = (movement.speed or 2) * speedMultiplier
            local time = 0

            while obstacle.Parent do
                time = time + task.wait()
                obstacle.CFrame = obstacle.CFrame * CFrame.Angles(0, speed * 0.016, 0)
            end
        end)
    end
end

function CorridorGenerator:applyZoneLighting(theme: string)
    local lighting = PlaceConfig.getLightingForZone(theme)
    if not lighting then return end

    for property, value in lighting do
        if Lighting:FindFirstChild(property) or pcall(function() return Lighting[property] end) then
            Lighting[property] = value
        end
    end
end

function CorridorGenerator:getFolder(): Folder?
    return corridorFolder
end

function CorridorGenerator:clear()
    if corridorFolder then
        corridorFolder:Destroy()
        corridorFolder = nil
    end
end

function CorridorGenerator:regenerate()
    self:clear()
    self:generate()
end

return CorridorGenerator
