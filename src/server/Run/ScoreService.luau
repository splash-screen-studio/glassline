--!strict
--[[
    Run/ScoreService.luau
    Directional scoring system for Glassline

    - Forward state: 1x points for forward progress
    - Backward state: 2x points for backward progress
    - Points accumulate lifetime
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunServiceRoblox = game:GetService("RunService")

local ScoreService = {}

-- Dependencies
local PlaceConfig: any
local Network: any
local PlayerDataService: any
local RunService: any

-- Player scores
export type PlayerScore = {
    runPoints: number,          -- Points this run
    lastPosition: number,       -- Last Z position for delta calculation
}

local playerScores: { [Player]: PlayerScore } = {}

-- Update interval (don't spam network)
local UPDATE_INTERVAL = 0.1
local lastUpdate = 0

function ScoreService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    local Server = script.Parent.Parent
    PlayerDataService = require(Server.Data.PlayerDataService)
    RunService = require(Server.Run.RunService)

    -- Position tracking loop
    RunServiceRoblox.Heartbeat:Connect(function(dt)
        lastUpdate = lastUpdate + dt
        if lastUpdate < UPDATE_INTERVAL then return end
        lastUpdate = 0

        self:updateAllPlayers()
    end)

    print("[ScoreService v" .. VERSION .. "] Initialized")
end

function ScoreService:initPlayer(player: Player)
    playerScores[player] = {
        runPoints = 0,
        lastPosition = 0,
    }
end

function ScoreService:cleanupPlayer(player: Player)
    playerScores[player] = nil
end

function ScoreService:updateAllPlayers()
    for player, score in playerScores do
        if not player.Character then continue end

        local humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        if not humanoidRootPart then continue end

        local currentZ = humanoidRootPart.Position.Z
        self:updateProgress(player, currentZ)
    end
end

function ScoreService:updateProgress(player: Player, currentZ: number)
    local score = playerScores[player]
    if not score then return end

    local runState = RunService:getState(player)
    if not runState then return end

    local delta = currentZ - score.lastPosition
    score.lastPosition = currentZ

    -- Update run service with position
    RunService:updatePosition(player, currentZ)

    -- Calculate points based on direction state
    local points = 0
    local directionState = runState.directionState

    if directionState == PlaceConfig.Scoring.states.FORWARD then
        -- Forward state: points for moving forward
        if delta > 0 then
            points = delta * PlaceConfig.Scoring.pointsPerStud * PlaceConfig.Scoring.forwardMultiplier
        end
    elseif directionState == PlaceConfig.Scoring.states.BACKWARD then
        -- Backward state: points for moving backward
        if delta < 0 then
            points = math.abs(delta) * PlaceConfig.Scoring.pointsPerStud * PlaceConfig.Scoring.backwardMultiplier
        end
    end

    -- Add points
    if points > 0 then
        score.runPoints = score.runPoints + points
        PlayerDataService:addPoints(player, math.floor(points))

        -- Send score update (throttled by update interval)
        Network.Events.ScoreUpdate:FireClient(player, {
            runPoints = math.floor(score.runPoints),
            lifetimePoints = PlayerDataService:getLifetimePoints(player),
            multiplier = if directionState == PlaceConfig.Scoring.states.BACKWARD
                then PlaceConfig.Scoring.backwardMultiplier
                else PlaceConfig.Scoring.forwardMultiplier,
        })
    end

    -- Update highest distance
    PlayerDataService:updateHighestDistance(player, currentZ)
end

function ScoreService:getRunPoints(player: Player): number
    local score = playerScores[player]
    return if score then score.runPoints else 0
end

function ScoreService:resetRunPoints(player: Player)
    local score = playerScores[player]
    if score then
        score.runPoints = 0
        score.lastPosition = 0
    end
end

function ScoreService:getMultiplier(player: Player): number
    local runState = RunService:getState(player)
    if not runState then return 1 end

    return if runState.directionState == PlaceConfig.Scoring.states.BACKWARD
        then PlaceConfig.Scoring.backwardMultiplier
        else PlaceConfig.Scoring.forwardMultiplier
end

return ScoreService
