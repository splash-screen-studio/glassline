--!strict
--[[
    Scoring/ClientScoring.luau
    Client-side velocity scoring with real-time HUD updates

    - Calculates velocity and points locally (no network lag)
    - Syncs with server periodically for persistence
    - HUD updates smoothly every frame
]]

local VERSION = "1.0.0"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ClientScoring = {}

-- Dependencies
local PlaceConfig: any
local HUD: any

-- State
local player = Players.LocalPlayer
local initialized = false
local lastPosition: Vector3 = Vector3.new(0, 0, 0)
local lastTime: number = 0
local velocityHistory: { number } = {}
local runPoints: number = 0
local lifetimePoints: number = 0
local currentRate: number = 0
local currentSpeed: number = 0
local gameMode: string = "ranked"
local lastVelocity: number = 0

-- Progress tracking - bonus for new ground, penalty for retread
local highestZ: number = 0  -- Furthest position reached this run
local RETREAD_MULTIPLIER = 0.1  -- 10% points for already-covered ground
local NEW_GROUND_MULTIPLIER = 10  -- 10x points for new territory!
local isOnNewGround: boolean = false

-- Server sync
local lastServerSync: number = 0
local SERVER_SYNC_INTERVAL = 2.0  -- Sync every 2 seconds
local lastLifetimeSync: number = 0
local LIFETIME_SYNC_INTERVAL = 5.0  -- Fetch lifetime from server every 5 seconds

function ClientScoring:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)

    -- Get HUD reference (set later via setHUD)
    HUD = nil

    -- Start the scoring loop
    RunService.Heartbeat:Connect(function(dt)
        self:update(dt)
    end)

    -- Listen for game mode changes from server
    local NetworkRemotes = ReplicatedStorage:WaitForChild("NetworkRemotes", 5)
    if NetworkRemotes then
        local gameModeRemote = NetworkRemotes:FindFirstChild("GameModeChanged")
        if gameModeRemote then
            (gameModeRemote :: RemoteEvent).OnClientEvent:Connect(function(data)
                gameMode = data.mode or "ranked"
                print("[ClientScoring] Mode changed to:", gameMode)
            end)
        end
    end

    print("[ClientScoring v" .. VERSION .. "] Initialized")
end

function ClientScoring:setHUD(hudModule: any)
    HUD = hudModule
end

function ClientScoring:setGameMode(mode: string)
    gameMode = mode
end

function ClientScoring:update(dt: number)
    local character = player.Character
    if not character then return end

    local hrp = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not hrp then return end

    local currentPos = hrp.Position
    local currentTime = os.clock()

    -- First frame: just initialize
    if not initialized then
        lastPosition = currentPos
        lastTime = currentTime
        initialized = true
        return
    end

    local timeDelta = currentTime - lastTime
    if timeDelta < 0.016 then return end  -- Cap at ~60fps

    -- Calculate velocity in Z direction (forward)
    local deltaZ = currentPos.Z - lastPosition.Z
    local velocityZ = deltaZ / timeDelta
    local speed = math.abs(velocityZ)

    -- Track velocity history for smoothing (use absolute for calculations)
    table.insert(velocityHistory, speed)
    if #velocityHistory > 10 then
        table.remove(velocityHistory, 1)
    end

    -- Calculate smoothed speed
    local smoothedSpeed = 0
    for _, v in velocityHistory do
        smoothedSpeed = smoothedSpeed + v
    end
    smoothedSpeed = smoothedSpeed / math.max(1, #velocityHistory)

    -- Detect bumps (sudden deceleration)
    local deceleration = lastVelocity - speed
    local isBump = deceleration > PlaceConfig.Scoring.bumpDecelThreshold

    -- Direction check (for now, forward = positive Z)
    local isCorrectDirection = velocityZ > 0

    -- Display speed: positive for correct direction, negative for wrong
    local displaySpeed = if isCorrectDirection then smoothedSpeed else -smoothedSpeed

    -- Calculate point rate based on game mode
    local pointRate = 0
    local canEarnPoints = gameMode == "ranked"

    if canEarnPoints then
        local threshold = PlaceConfig.Scoring.velocityThreshold

        if isBump then
            pointRate = PlaceConfig.Scoring.penaltyBump
        elseif speed < 5 then
            pointRate = PlaceConfig.Scoring.penaltyStanding
        elseif not isCorrectDirection then
            pointRate = PlaceConfig.Scoring.penaltyWrongDirection
        elseif smoothedSpeed < threshold then
            pointRate = PlaceConfig.Scoring.penaltySlowSpeed
        else
            local velocityBonus = math.min(smoothedSpeed - threshold, PlaceConfig.Scoring.maxVelocityBonus)
            local bonusRatio = velocityBonus / PlaceConfig.Scoring.maxVelocityBonus
            local baseRate = PlaceConfig.Scoring.basePointsPerSecond
            local maxRate = PlaceConfig.Scoring.maxPointsPerSecond

            pointRate = baseRate + (maxRate - baseRate) * bonusRatio

            -- Check if we're on new ground or retreading
            local currentZ = currentPos.Z
            if currentZ > highestZ then
                -- NEW GROUND! 10x bonus!
                pointRate = pointRate * NEW_GROUND_MULTIPLIER
                highestZ = currentZ
                isOnNewGround = true
            else
                -- Retreading - reduced points
                pointRate = pointRate * RETREAD_MULTIPLIER
                isOnNewGround = false
            end
        end

        -- Apply points
        local pointsDelta = pointRate * timeDelta
        runPoints = math.max(0, runPoints + pointsDelta)
    end

    -- Update state
    currentRate = pointRate
    currentSpeed = math.floor(displaySpeed)  -- Signed speed for display
    lastPosition = currentPos
    lastTime = currentTime
    lastVelocity = speed

    -- Update HUD directly (no network!)
    if HUD then
        HUD:updateScore(
            math.floor(runPoints),
            math.floor(lifetimePoints),
            if isOnNewGround then NEW_GROUND_MULTIPLIER else 1,  -- Show multiplier
            math.floor(currentRate),
            currentSpeed,  -- Now signed: negative when wrong direction
            gameMode,
            math.floor(highestZ),  -- Highest position for indicator
            isOnNewGround  -- Whether on new ground
        )
    end

    -- Periodic server sync for persistence
    if canEarnPoints and currentTime - lastServerSync > SERVER_SYNC_INTERVAL then
        lastServerSync = currentTime
        self:syncWithServer()
    end

    -- Periodic lifetime points fetch
    if currentTime - lastLifetimeSync > LIFETIME_SYNC_INTERVAL then
        lastLifetimeSync = currentTime
        self:fetchLifetimePoints()
    end
end

function ClientScoring:syncWithServer()
    local NetworkRemotes = ReplicatedStorage:FindFirstChild("NetworkRemotes")
    if not NetworkRemotes then return end

    local syncRemote = NetworkRemotes:FindFirstChild("SyncScore")
    if syncRemote then
        (syncRemote :: RemoteEvent):FireServer({
            runPoints = runPoints,
            position = lastPosition.Z,
        })
    end
end

function ClientScoring:fetchLifetimePoints()
    local NetworkRemotes = ReplicatedStorage:FindFirstChild("NetworkRemotes")
    if not NetworkRemotes then return end

    local getLifetime = NetworkRemotes:FindFirstChild("GetLifetimePoints")
    if getLifetime then
        task.spawn(function()
            local points = (getLifetime :: RemoteFunction):InvokeServer()
            if points and type(points) == "number" then
                lifetimePoints = points
            end
        end)
    end
end

function ClientScoring:resetPoints()
    runPoints = 0
    currentRate = 0
    velocityHistory = {}
    initialized = false
    highestZ = 0  -- Reset progress on death/respawn
    isOnNewGround = false
end

function ClientScoring:getRunPoints(): number
    return runPoints
end

function ClientScoring:getCurrentRate(): number
    return currentRate
end

function ClientScoring:getCurrentSpeed(): number
    return currentSpeed
end

return ClientScoring
