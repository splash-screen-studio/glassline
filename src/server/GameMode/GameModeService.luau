--!strict
--[[
    GameMode/GameModeService.luau
    Manages game modes: Ranked vs Fun

    RANKED: Predators active, points earned, death enabled
    FUN: No predators, no death, no points (practice mode)

    Version: 1.0.0
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local GameModeService = {}

-- Dependencies
local PlaceConfig: any
local Network: any

-- Player modes
local playerModes: { [Player]: string } = {}

function GameModeService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    -- Seed random with time for true randomness
    math.randomseed(os.time() + tick() * 1000)

    local folder = ReplicatedStorage:FindFirstChild("NetworkRemotes")
    if folder then
        -- Create mode toggle remote
        if not folder:FindFirstChild("ToggleGameMode") then
            local remote = Instance.new("RemoteEvent")
            remote.Name = "ToggleGameMode"
            remote.Parent = folder
        end

        -- Create GetGameMode function for client queries
        if not folder:FindFirstChild("GetGameMode") then
            local remote = Instance.new("RemoteFunction")
            remote.Name = "GetGameMode"
            remote.Parent = folder
            remote.OnServerInvoke = function(player)
                return self:getMode(player)
            end
        end

        -- Create GameModeChanged event
        if not folder:FindFirstChild("GameModeChanged") then
            local remote = Instance.new("RemoteEvent")
            remote.Name = "GameModeChanged"
            remote.Parent = folder
        end
    end

    -- Listen for mode toggle requests
    task.defer(function()
        local toggleRemote = folder and folder:FindFirstChild("ToggleGameMode")
        if toggleRemote then
            (toggleRemote :: RemoteEvent).OnServerEvent:Connect(function(player, mode)
                self:setMode(player, mode)
            end)
        end
    end)

    print("[GameModeService v" .. VERSION .. "] Initialized")
end

function GameModeService:initPlayer(player: Player)
    -- Randomly select mode
    self:randomizeMode(player)
end

function GameModeService:randomizeMode(player: Player)
    -- FUN MODE DISABLED FOR NOW - always ranked
    -- TODO: Re-enable fun mode later (was 90% ranked, 10% fun)
    -- local roll = math.random(1, 100)
    -- local mode = if roll <= 90 then PlaceConfig.GameModes.RANKED else PlaceConfig.GameModes.FUN
    local mode = PlaceConfig.GameModes.RANKED
    print("[GameModeService] Mode:", mode, "(fun mode disabled)")
    self:setMode(player, mode)
end

function GameModeService:onRespawn(player: Player)
    -- Randomly select new mode on each respawn
    self:randomizeMode(player)
end

function GameModeService:cleanupPlayer(player: Player)
    playerModes[player] = nil
end

function GameModeService:setMode(player: Player, mode: string)
    if mode ~= PlaceConfig.GameModes.RANKED and mode ~= PlaceConfig.GameModes.FUN then
        warn("[GameModeService] Invalid mode:", mode)
        return
    end

    local previousMode = playerModes[player]
    playerModes[player] = mode

    -- Apply mode effects
    if mode == PlaceConfig.GameModes.FUN then
        self:applyFunMode(player)
    else
        self:applyRankedMode(player)
    end

    -- Notify client via the remote we created in init
    local folder = ReplicatedStorage:FindFirstChild("NetworkRemotes")
    if folder then
        local modeChanged = folder:FindFirstChild("GameModeChanged")
        if modeChanged then
            (modeChanged :: RemoteEvent):FireClient(player, {
                mode = mode,
                previousMode = previousMode,
            })
        end
    end

    print("[GameModeService]", player.Name, "switched to", mode, "mode")
end

function GameModeService:applyFunMode(player: Player)
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
    if humanoid then
        -- Make invincible
        humanoid.MaxHealth = math.huge
        humanoid.Health = math.huge
    end
end

function GameModeService:applyRankedMode(player: Player)
    local char = player.Character
    if not char then return end

    local humanoid = char:FindFirstChild("Humanoid") :: Humanoid?
    if humanoid then
        -- Restore normal health
        humanoid.MaxHealth = 100
        humanoid.Health = 100
    end
end

function GameModeService:getMode(player: Player): string
    return playerModes[player] or PlaceConfig.GameModes.RANKED
end

function GameModeService:isFunMode(player: Player): boolean
    return playerModes[player] == PlaceConfig.GameModes.FUN
end

function GameModeService:isRankedMode(player: Player): boolean
    return playerModes[player] == PlaceConfig.GameModes.RANKED
end

function GameModeService:canEarnPoints(player: Player): boolean
    return self:isRankedMode(player)
end

function GameModeService:canDie(player: Player): boolean
    return self:isRankedMode(player)
end

return GameModeService
