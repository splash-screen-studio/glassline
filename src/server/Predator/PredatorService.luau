--!strict
--[[
    Predator/PredatorService.luau
    Dual predator chase system for Glassline

    Each player has TWO predators:
    - HUNTER: Chases from behind
    - STALKER: Flanks to front to trap

    Version: 1.0.0
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local PredatorService = {}

-- Dependencies (loaded in init)
local PlaceConfig: any
local Network: any
local GameModeService: any

-- Types
export type PredatorData = {
    hunter: Model,
    stalker: Model,
    hunterZ: number,
    stalkerZ: number,
    isChasing: boolean,
    isTrapped: boolean,
    variant: number,
    startTime: number,
}

-- Player predator data
local playerPredators: { [Player]: PredatorData } = {}

-- Create predator model
local function createPredatorModel(variant: any, role: string): Model
    local model = Instance.new("Model")
    model.Name = variant.name .. "_" .. role

    -- Main body
    local body = Instance.new("Part")
    body.Name = "Body"
    body.Size = Vector3.new(3, 4, 2)
    body.Color = variant.primaryColor
    body.Material = Enum.Material.Neon
    body.Anchored = true
    body.CanCollide = false
    body.CastShadow = false
    body.Parent = model

    -- Glowing eyes
    local leftEye = Instance.new("Part")
    leftEye.Name = "LeftEye"
    leftEye.Size = Vector3.new(0.4, 0.4, 0.2)
    leftEye.Color = variant.secondaryColor
    leftEye.Material = Enum.Material.Neon
    leftEye.Anchored = true
    leftEye.CanCollide = false
    leftEye.Parent = model

    local rightEye = leftEye:Clone()
    rightEye.Name = "RightEye"
    rightEye.Parent = model

    -- Glow effect
    local light = Instance.new("PointLight")
    light.Color = variant.secondaryColor
    light.Brightness = 2
    light.Range = 15
    light.Parent = body

    model.PrimaryPart = body
    return model
end

-- Update predator model position
local function updatePredatorPosition(model: Model, x: number, y: number, z: number, facingZ: number)
    local body = model:FindFirstChild("Body") :: BasePart?
    if not body then return end

    local pos = Vector3.new(x, y + 2, z)
    local lookAt = Vector3.new(x, y + 2, facingZ)
    body.CFrame = CFrame.lookAt(pos, lookAt)

    -- Position eyes
    local leftEye = model:FindFirstChild("LeftEye") :: BasePart?
    local rightEye = model:FindFirstChild("RightEye") :: BasePart?
    if leftEye and rightEye then
        leftEye.CFrame = body.CFrame * CFrame.new(-0.6, 0.8, -1)
        rightEye.CFrame = body.CFrame * CFrame.new(0.6, 0.8, -1)
    end
end

function PredatorService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    -- GameModeService loaded later to avoid circular dependency
    task.defer(function()
        local Server = script.Parent.Parent
        local gameModeModule = Server:FindFirstChild("GameMode")
        if gameModeModule then
            GameModeService = require(gameModeModule.GameModeService)
        end
    end)

    print("[PredatorService v" .. VERSION .. "] Initialized")
end

function PredatorService:setupPlayer(player: Player)
    -- Pick random variant
    local variants = PlaceConfig.Predator.variants
    local variantIndex = math.random(1, #variants)
    local variant = variants[variantIndex]

    -- Create predator models
    local hunter = createPredatorModel(variant, "Hunter")
    hunter.Parent = workspace

    local stalker = createPredatorModel(variant, "Stalker")
    stalker.Parent = workspace

    -- Store data
    playerPredators[player] = {
        hunter = hunter,
        stalker = stalker,
        hunterZ = PlaceConfig.Predator.hunterStartZ,
        stalkerZ = PlaceConfig.Predator.stalkerStartZ,
        isChasing = false,
        isTrapped = false,
        variant = variantIndex,
        startTime = tick(),
    }

    -- Initial positions
    updatePredatorPosition(hunter, 0, 0, playerPredators[player].hunterZ, 0)
    updatePredatorPosition(stalker, 0, 0, playerPredators[player].stalkerZ, 0)

    print("[PredatorService] Created predators for", player.Name, "-", variant.name)
end

function PredatorService:cleanupPlayer(player: Player)
    local data = playerPredators[player]
    if data then
        if data.hunter then data.hunter:Destroy() end
        if data.stalker then data.stalker:Destroy() end
        playerPredators[player] = nil
    end
end

function PredatorService:resetPredators(player: Player)
    local data = playerPredators[player]
    if not data then return end

    data.hunterZ = PlaceConfig.Predator.hunterStartZ
    data.stalkerZ = PlaceConfig.Predator.stalkerStartZ
    data.isChasing = false
    data.isTrapped = false
    data.startTime = tick()

    updatePredatorPosition(data.hunter, 0, 0, data.hunterZ, 0)
    updatePredatorPosition(data.stalker, 0, 0, data.stalkerZ, 0)
end

function PredatorService:update(dt: number)
    for player, data in pairs(playerPredators) do
        -- Skip if player left
        if not player.Parent then
            self:cleanupPlayer(player)
            continue
        end

        -- Skip if in fun mode
        if GameModeService and GameModeService:isFunMode(player) then
            -- Hide predators
            data.hunter.Parent = nil
            data.stalker.Parent = nil
            continue
        else
            -- Show predators
            if not data.hunter.Parent then
                data.hunter.Parent = workspace
                data.stalker.Parent = workspace
            end
        end

        -- Get player position
        local char = player.Character
        if not char then continue end
        local hrp = char:FindFirstChild("HumanoidRootPart") :: BasePart?
        if not hrp then continue end

        local playerZ = hrp.Position.Z
        local playerY = hrp.Position.Y

        -- Check chase delay
        local elapsed = tick() - data.startTime
        if elapsed < PlaceConfig.Predator.chaseDelay then
            continue
        end

        if not data.isChasing then
            data.isChasing = true
        end

        -- Update hunter (chases from behind)
        local config = PlaceConfig.Predator
        local hunterSpeed = config.baseSpeed
        if playerZ - data.hunterZ > 50 then
            hunterSpeed = config.catchUpSpeed
        end

        data.hunterZ = data.hunterZ + hunterSpeed * dt
        updatePredatorPosition(data.hunter, 0, playerY - 2, data.hunterZ, playerZ)

        -- Update stalker (flanks to front when hunter close)
        local hunterDistance = playerZ - data.hunterZ
        if hunterDistance < 30 then
            -- Stalker moves to front
            local targetZ = playerZ + 10
            if data.stalkerZ < targetZ then
                data.stalkerZ = data.stalkerZ + config.catchUpSpeed * 1.5 * dt
            end
        else
            -- Stalker follows behind hunter
            data.stalkerZ = data.hunterZ - 20
        end
        updatePredatorPosition(data.stalker, 0, playerY - 2, data.stalkerZ, playerZ)

        -- Check trap condition (player between both predators)
        local stalkerDistance = data.stalkerZ - playerZ
        if hunterDistance < config.catchDistance and stalkerDistance > -config.catchDistance then
            if not data.isTrapped then
                data.isTrapped = true
                -- Trigger trap sequence
                self:triggerTrap(player, data)
            end
        end

        -- Check catch (hunter caught player)
        if hunterDistance < 2 and not data.isTrapped then
            self:killPlayer(player, "devoured")
        end
    end
end

function PredatorService:triggerTrap(player: Player, data: PredatorData)
    -- Notify client
    Network.Events.PlayerDied:FireClient(player, {
        cause = "trapped",
        warning = true,
    })

    -- Wait for trap duration, checking for jump
    local humanoid = player.Character and player.Character:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid then return end

    local jumpConnection: RBXScriptConnection?
    local jumped = false

    jumpConnection = humanoid.StateChanged:Connect(function(_, newState)
        if newState == Enum.HumanoidStateType.Jumping then
            jumped = true
            if jumpConnection then jumpConnection:Disconnect() end
            self:killPlayer(player, "jumped_in_trap")
        end
    end)

    task.delay(PlaceConfig.Predator.trapPauseDuration, function()
        if jumpConnection then jumpConnection:Disconnect() end
        if not jumped and data.isTrapped then
            self:killPlayer(player, "devoured")
        end
    end)
end

function PredatorService:killPlayer(player: Player, cause: string)
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
    if humanoid and humanoid.Health > 0 then
        -- Notify through death service or directly
        Network.Events.PlayerDied:FireClient(player, {
            cause = cause,
            runPoints = 0,
        })
        humanoid.Health = 0
    end

    -- Reset predators for next run
    self:resetPredators(player)
end

function PredatorService:getPredatorData(player: Player): PredatorData?
    return playerPredators[player]
end

-- Start update loop
function PredatorService:startLoop()
    RunService.Heartbeat:Connect(function(dt)
        self:update(dt)
    end)
end

return PredatorService
