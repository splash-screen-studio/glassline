--!strict
--[[
    Run/ScoreService.luau
    Server-side score persistence for Glassline

    - Client handles real-time scoring
    - Server validates and persists scores
    - No real-time network updates needed
]]

local VERSION = "3.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ScoreService = {}

-- Dependencies
local PlaceConfig: any
local PlayerDataService: any

function ScoreService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)

    local Server = script.Parent.Parent
    PlayerDataService = require(Server.Data.PlayerDataService)

    local folder = ReplicatedStorage:FindFirstChild("NetworkRemotes")
    if folder then
        -- Create SyncScore remote for client to sync points
        if not folder:FindFirstChild("SyncScore") then
            local remote = Instance.new("RemoteEvent")
            remote.Name = "SyncScore"
            remote.Parent = folder

            remote.OnServerEvent:Connect(function(player, data)
                self:onClientSync(player, data)
            end)
        end

        -- Create GetLifetimePoints remote for client to fetch lifetime
        if not folder:FindFirstChild("GetLifetimePoints") then
            local remote = Instance.new("RemoteFunction")
            remote.Name = "GetLifetimePoints"
            remote.Parent = folder

            remote.OnServerInvoke = function(player)
                return PlayerDataService:getLifetimePoints(player)
            end
        end
    end

    print("[ScoreService v" .. VERSION .. "] Initialized (server persistence only)")
end

function ScoreService:initPlayer(player: Player)
    -- Nothing needed - client handles scoring
end

function ScoreService:cleanupPlayer(player: Player)
    -- Nothing needed
end

function ScoreService:onClientSync(player: Player, data: { runPoints: number, position: number })
    -- Validate the sync
    if not data or type(data.runPoints) ~= "number" then
        return
    end

    -- Basic anti-cheat: cap points per sync
    local maxPointsPerSync = 500  -- Max reasonable points in 2 seconds
    local points = math.min(data.runPoints, maxPointsPerSync)

    -- Only persist positive points
    if points > 0 then
        PlayerDataService:addPoints(player, points)
    end

    -- Update position tracking
    if data.position and type(data.position) == "number" then
        PlayerDataService:updateHighestDistance(player, data.position)
    end
end

function ScoreService:getRunPoints(player: Player): number
    -- Client tracks this now
    return 0
end

function ScoreService:resetRunPoints(player: Player)
    -- Client handles this
end

function ScoreService:getMultiplier(player: Player): number
    return 1
end

return ScoreService
