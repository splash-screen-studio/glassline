--!strict
--[[
    Run/RunService.luau
    Core run state management for Glassline

    Tracks player direction state (forward/backward) and run progress.
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunServiceRoblox = game:GetService("RunService")

local GlasslineRunService = {}

-- Dependencies
local PlaceConfig: any
local Network: any

-- Player states
export type RunState = {
    directionState: string,     -- "forward" or "backward"
    currentPosition: number,    -- Z position in corridor
    runStartTime: number,       -- When this run started
    hasReachedEnd: boolean,     -- Has player reached end this session
}

local playerStates: { [Player]: RunState } = {}

function GlasslineRunService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    print("[RunService v" .. VERSION .. "] Initialized")
end

function GlasslineRunService:initPlayer(player: Player)
    playerStates[player] = {
        directionState = PlaceConfig.Scoring.states.FORWARD,
        currentPosition = 0,
        runStartTime = os.clock(),
        hasReachedEnd = false,
    }
end

function GlasslineRunService:cleanupPlayer(player: Player)
    playerStates[player] = nil
end

function GlasslineRunService:getState(player: Player): RunState?
    return playerStates[player]
end

function GlasslineRunService:getDirectionState(player: Player): string
    local state = playerStates[player]
    return if state then state.directionState else PlaceConfig.Scoring.states.FORWARD
end

function GlasslineRunService:setDirectionState(player: Player, newState: string)
    local state = playerStates[player]
    if not state then return end

    local oldState = state.directionState
    state.directionState = newState

    -- Notify client of state change
    if oldState ~= newState then
        local multiplier = if newState == PlaceConfig.Scoring.states.BACKWARD
            then PlaceConfig.Scoring.backwardMultiplier
            else PlaceConfig.Scoring.forwardMultiplier

        Network.Events.DirectionStateChanged:FireClient(player, {
            state = newState,
            multiplier = multiplier,
        })
    end
end

function GlasslineRunService:updatePosition(player: Player, zPosition: number)
    local state = playerStates[player]
    if not state then return end

    local oldPosition = state.currentPosition
    state.currentPosition = zPosition

    -- Check if reached end
    if zPosition >= PlaceConfig.EndZone.startZ and not state.hasReachedEnd then
        state.hasReachedEnd = true
        self:setDirectionState(player, PlaceConfig.Scoring.states.BACKWARD)

        -- Notify client
        Network.Events.ReachedEnd:FireClient(player, {
            runPoints = 0, -- ScoreService will calculate
            totalDistance = zPosition,
            newState = PlaceConfig.Scoring.states.BACKWARD,
        })
    end

    -- Send progress update
    Network.Events.ProgressUpdate:FireClient(player, {
        position = zPosition,
        speed = PlaceConfig.getSpeedAtPosition(zPosition),
        direction = if zPosition > oldPosition then "forward" else "backward",
    })
end

function GlasslineRunService:resetRun(player: Player)
    local state = playerStates[player]
    if not state then return end

    state.directionState = PlaceConfig.Scoring.states.FORWARD
    state.currentPosition = 0
    state.runStartTime = os.clock()
    state.hasReachedEnd = false

    -- Notify client
    Network.Events.DirectionStateChanged:FireClient(player, {
        state = PlaceConfig.Scoring.states.FORWARD,
        multiplier = PlaceConfig.Scoring.forwardMultiplier,
    })
end

return GlasslineRunService
