--!strict
--[[
    Client Entry Point - Glassline

    Initializes all client-side systems.
]]

local VERSION = "3.0.0"

print("[Client v" .. VERSION .. "] Initializing Glassline...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Force landscape orientation for mobile
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlaceConfig = require(Shared.PlaceConfig)

-- Client modules
local Client = script

-- Initialize systems
local AudioController = require(Client.Audio)
AudioController:init()
_G.AudioController = AudioController

local InputController = require(Client.Input.InputController)
InputController:init()
_G.InputController = InputController

local HUD = require(Client.HUD)
HUD:init()
_G.HUD = HUD

local Effects = require(Client.Effects)
Effects:init()
_G.Effects = Effects

-- Initialize client-side scoring (no network dependency for real-time updates!)
local ClientScoring = require(Client.Scoring.ClientScoring)
ClientScoring:init()
ClientScoring:setHUD(HUD)
_G.ClientScoring = ClientScoring

-- Listen for game mode changes from server
local NetworkRemotes = ReplicatedStorage:WaitForChild("NetworkRemotes", 10)
if NetworkRemotes then
    -- Game mode changes
    local gameModeRemote = NetworkRemotes:FindFirstChild("GameModeChanged")
    if gameModeRemote then
        (gameModeRemote :: RemoteEvent).OnClientEvent:Connect(function(data)
            ClientScoring:setGameMode(data.mode or "ranked")
            print("[Client] Game mode changed to:", data.mode)
        end)
    end

    -- Death handling
    local diedRemote = NetworkRemotes:FindFirstChild("PlayerDied")
    if diedRemote then
        (diedRemote :: RemoteEvent).OnClientEvent:Connect(function(data)
            HUD:showDeathScreen(data.cause, ClientScoring:getRunPoints())
            AudioController:playSFX("death_obstacle")
        end)
    end

    local respawnRemote = NetworkRemotes:FindFirstChild("PlayerRespawned")
    if respawnRemote then
        (respawnRemote :: RemoteEvent).OnClientEvent:Connect(function(_data)
            HUD:hideDeathScreen()
            ClientScoring:resetPoints()
        end)
    end

    -- Zone changes
    local zoneRemote = NetworkRemotes:FindFirstChild("ZoneChanged")
    if zoneRemote then
        (zoneRemote :: RemoteEvent).OnClientEvent:Connect(function(data)
            Effects:transitionZone(data.theme)
            AudioController:playSFX("zone_change")
        end)
    end

    -- Vehicle events
    local mountRemote = NetworkRemotes:FindFirstChild("VehicleMounted")
    if mountRemote then
        (mountRemote :: RemoteEvent).OnClientEvent:Connect(function(data)
            HUD:showVehicleIndicator(data.vehicleType)
            AudioController:playSFX("vehicle_mount")
        end)
    end

    local dismountRemote = NetworkRemotes:FindFirstChild("VehicleDismounted")
    if dismountRemote then
        (dismountRemote :: RemoteEvent).OnClientEvent:Connect(function(_data)
            HUD:hideVehicleIndicator()
            AudioController:playSFX("vehicle_dismount")
        end)
    end

    -- End zone
    local endRemote = NetworkRemotes:FindFirstChild("ReachedEnd")
    if endRemote then
        (endRemote :: RemoteEvent).OnClientEvent:Connect(function(data)
            HUD:showReachedEnd(data.runPoints, data.totalDistance)
            AudioController:playSFX("reached_end")
        end)
    end
end

-- Request initial game mode from server
task.spawn(function()
    task.wait(1)  -- Wait for server to initialize player
    local NetworkRemotes = ReplicatedStorage:FindFirstChild("NetworkRemotes")
    if NetworkRemotes then
        local getMode = NetworkRemotes:FindFirstChild("GetGameMode")
        if getMode then
            local mode = (getMode :: RemoteFunction):InvokeServer()
            if mode then
                ClientScoring:setGameMode(mode)
            end
        end
    end
end)

-- Start music
AudioController:playMusic("main_theme")

print("[Client v" .. VERSION .. "] Glassline ready!")
