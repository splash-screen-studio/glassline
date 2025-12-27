--!strict
--[[
    Death/DeathService.luau
    Collision detection and respawn handling

    Touch any obstacle = instant death + respawn at start.
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local DeathService = {}

-- Dependencies
local PlaceConfig: any
local Network: any
local PlayerDataService: any
local RunService: any
local ScoreService: any

-- Obstacle tag
local OBSTACLE_TAG = "GlasslineObstacle"

-- Active connections per player
local playerConnections: { [Player]: { RBXScriptConnection } } = {}

-- Death cooldown to prevent spam
local deathCooldowns: { [Player]: number } = {}
local DEATH_COOLDOWN = 1 -- seconds

function DeathService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    local Server = script.Parent.Parent
    PlayerDataService = require(Server.Data.PlayerDataService)
    RunService = require(Server.Run.RunService)
    ScoreService = require(Server.Run.ScoreService)

    print("[DeathService v" .. VERSION .. "] Initialized")
end

function DeathService:setupCharacter(player: Player, character: Model)
    -- Cleanup old connections
    self:cleanupCharacter(player)

    playerConnections[player] = {}

    -- Get humanoid and root part
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

    -- Listen for obstacle touches
    for _, part in character:GetDescendants() do
        if part:IsA("BasePart") then
            local conn = part.Touched:Connect(function(otherPart)
                self:onPartTouched(player, character, otherPart)
            end)
            table.insert(playerConnections[player], conn)
        end
    end

    -- Listen for humanoid death (fallback)
    local deathConn = humanoid.Died:Connect(function()
        self:onPlayerDied(player, character, "unknown")
    end)
    table.insert(playerConnections[player], deathConn)
end

function DeathService:cleanupCharacter(player: Player)
    local connections = playerConnections[player]
    if connections then
        for _, conn in connections do
            conn:Disconnect()
        end
        playerConnections[player] = nil
    end
end

function DeathService:onPartTouched(player: Player, character: Model, otherPart: BasePart)
    -- Check if it's an obstacle
    if not otherPart:HasTag(OBSTACLE_TAG) then
        return
    end

    -- Check cooldown
    local now = os.clock()
    if deathCooldowns[player] and now - deathCooldowns[player] < DEATH_COOLDOWN then
        return
    end

    -- Get obstacle type from attribute
    local obstacleType = otherPart:GetAttribute("ObstacleType") or "obstacle"

    -- Trigger death
    self:onPlayerDied(player, character, obstacleType)
end

function DeathService:onPlayerDied(player: Player, character: Model, cause: string)
    -- Set cooldown
    deathCooldowns[player] = os.clock()

    -- Get position before death
    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    local deathPosition = if rootPart then rootPart.Position else Vector3.zero

    -- Get run points before reset
    local runPoints = ScoreService:getRunPoints(player)

    -- Increment death counter
    PlayerDataService:incrementDeaths(player)

    -- Notify client
    Network.Events.PlayerDied:FireClient(player, {
        position = deathPosition,
        cause = cause,
        runPoints = runPoints,
    })

    -- Kill the character
    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if humanoid and humanoid.Health > 0 then
        humanoid.Health = 0
    end

    -- Reset run state
    RunService:resetRun(player)
    ScoreService:resetRunPoints(player)

    -- Respawn after delay (handled by Roblox or SpawnService)
    task.delay(2, function()
        if player and player.Parent then
            self:respawnPlayer(player)
        end
    end)
end

function DeathService:respawnPlayer(player: Player)
    -- Load character at start
    player:LoadCharacter()

    -- Increment run counter
    PlayerDataService:incrementRuns(player)

    -- Notify client
    Network.Events.PlayerRespawned:FireClient(player, {
        position = PlaceConfig.Spawn.position,
        resetRun = true,
    })
end

-- Tag an obstacle so it triggers death on touch
function DeathService:tagObstacle(part: BasePart, obstacleType: string?)
    part:AddTag(OBSTACLE_TAG)
    part:SetAttribute("ObstacleType", obstacleType or "obstacle")
end

return DeathService
