--!strict
--[[
    Client Entry Point - Glassline

    Initializes all client-side systems.
]]

local VERSION = "1.0.0"

print("[Client v" .. VERSION .. "] Initializing Glassline...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Force landscape orientation for mobile
local playerGui = Players.LocalPlayer:WaitForChild("PlayerGui")
playerGui.ScreenOrientation = Enum.ScreenOrientation.LandscapeSensor

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlaceConfig = require(Shared.PlaceConfig)
local Network = require(Shared.Network)

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

-- Listen for network events
Network.Events.ScoreUpdate.OnClientEvent:Connect(function(data)
    HUD:updateScore(data.runPoints, data.lifetimePoints, data.multiplier)
end)

Network.Events.ProgressUpdate.OnClientEvent:Connect(function(data)
    HUD:updateProgress(data.position, PlaceConfig.Corridor.length)
end)

Network.Events.DirectionStateChanged.OnClientEvent:Connect(function(data)
    HUD:updateDirectionState(data.state, data.multiplier)
end)

Network.Events.PlayerDied.OnClientEvent:Connect(function(data)
    HUD:showDeathScreen(data.cause, data.runPoints)
    AudioController:playSFX("death_obstacle")
end)

Network.Events.PlayerRespawned.OnClientEvent:Connect(function(_data)
    HUD:hideDeathScreen()
end)

Network.Events.ZoneChanged.OnClientEvent:Connect(function(data)
    Effects:transitionZone(data.theme)
    AudioController:playSFX("zone_change")
end)

Network.Events.VehicleMounted.OnClientEvent:Connect(function(data)
    HUD:showVehicleIndicator(data.vehicleType)
    AudioController:playSFX("vehicle_mount")
end)

Network.Events.VehicleDismounted.OnClientEvent:Connect(function(_data)
    HUD:hideVehicleIndicator()
    AudioController:playSFX("vehicle_dismount")
end)

Network.Events.ReachedEnd.OnClientEvent:Connect(function(data)
    HUD:showReachedEnd(data.runPoints, data.totalDistance)
    AudioController:playSFX("reached_end")
end)

-- Request initial player data
task.spawn(function()
    local result = Network.Functions.GetPlayerData:InvokeServer()
    if result.success then
        HUD:setInitialData(result.data)
    end
end)

-- Start music
AudioController:playMusic("main_theme")

print("[Client v" .. VERSION .. "] Glassline ready!")
