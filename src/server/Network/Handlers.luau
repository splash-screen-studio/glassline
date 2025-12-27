--!strict
--[[
    Network/Handlers.luau
    Server-side event handlers with validation and rate limiting
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Handlers = {}

-- Dependencies (loaded in init)
local Network: any
local Validators: any
local RateLimiter: any
local PlayerDataService: any
local RunService: any
local ScoreService: any
local VehicleService: any
local SpawnService: any

-- Wrapper for handlers: rate limit + pcall + response
local function wrapHandler(eventName: string, handler: (Player, any) -> any)
    return function(player: Player, data: any)
        -- Rate limiting
        if not RateLimiter:check(player, eventName) then
            return { success = false, error = "Rate limited" }
        end

        -- Execute handler with error handling
        local success, result = pcall(handler, player, data)
        if not success then
            warn("[Handlers]", eventName, "error:", result)
            return { success = false, error = "Internal error" }
        end

        return result
    end
end

function Handlers:init()
    -- Load dependencies
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    Network = require(Shared.Network)
    Validators = require(script.Parent.Validators)
    RateLimiter = require(script.Parent.RateLimiter)

    local Server = script.Parent.Parent
    PlayerDataService = require(Server.Data.PlayerDataService)

    -- Initialize network (creates all remotes)
    Network.init()

    -- Set up event handlers
    self:setupEventHandlers()
    self:setupFunctionHandlers()

    print("[Handlers v" .. VERSION .. "] Initialized")
end

function Handlers:setupEventHandlers()
    -- Request Respawn
    Network.Events.RequestRespawn.OnServerEvent:Connect(wrapHandler("RequestRespawn",
        function(player, _data)
            -- Respawn is handled by SpawnService
            local SpawnSvc = require(script.Parent.Parent.Character.SpawnService)
            SpawnSvc:respawnPlayer(player)
            return { success = true }
        end
    ))

    -- Request Mount Vehicle
    Network.Events.RequestMount.OnServerEvent:Connect(wrapHandler("RequestMount",
        function(player, data)
            local isValid, cleanData = Validators.validateMountRequest(data)
            if not isValid or not cleanData then
                return { success = false, error = "Invalid request" }
            end

            local VehicleSvc = require(script.Parent.Parent.Vehicle.VehicleService)
            local result = VehicleSvc:mountVehicle(player, cleanData.vehicleId)
            return result
        end
    ))

    -- Request Dismount Vehicle
    Network.Events.RequestDismount.OnServerEvent:Connect(wrapHandler("RequestDismount",
        function(player, _data)
            local VehicleSvc = require(script.Parent.Parent.Vehicle.VehicleService)
            local result = VehicleSvc:dismountVehicle(player)
            return result
        end
    ))

    -- Request Teleport to Start
    Network.Events.RequestTeleportToStart.OnServerEvent:Connect(wrapHandler("RequestTeleportToStart",
        function(player, _data)
            local RunSvc = require(script.Parent.Parent.Run.RunService)
            local SpawnSvc = require(script.Parent.Parent.Character.SpawnService)

            -- Reset to forward state
            RunSvc:setDirectionState(player, "forward")

            -- Teleport to start
            SpawnSvc:teleportToStart(player)

            return { success = true }
        end
    ))
end

function Handlers:setupFunctionHandlers()
    -- Get Player Data
    Network.Functions.GetPlayerData.OnServerInvoke = function(player)
        local data = PlayerDataService:getData(player)
        if data then
            return {
                success = true,
                data = {
                    lifetimePoints = data.lifetimePoints,
                    highestDistance = data.highestDistance,
                    totalRuns = data.totalRuns,
                    totalDeaths = data.totalDeaths,
                },
            }
        else
            return { success = false, error = "Data not loaded" }
        end
    end
end

return Handlers
