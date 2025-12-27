--!strict
--[[
    Server Entry Point - Glassline

    Initializes all server-side services in the correct order.
    All services exported to _G for Studio debugging.
]]

local VERSION = "1.0.0"

print("[Server v" .. VERSION .. "] Initializing Glassline...")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

-- Wait for shared modules
local Shared = ReplicatedStorage:WaitForChild("Shared")
local PlaceConfig = require(Shared.PlaceConfig)

-- Remove default baseplate
local baseplate = workspace:FindFirstChild("Baseplate")
if baseplate then
    baseplate:Destroy()
end

-- Server modules
local Server = script

-- Initialize order:
-- 1. Data (player profiles)
-- 2. Network (remote events)
-- 3. Run mechanics (scoring, checkpoints, difficulty)
-- 4. Death handling
-- 5. Corridor generation
-- 6. Vehicles
-- 7. Character spawning

-- Step 1: Player Data Service
local PlayerDataService = require(Server.Data.PlayerDataService)
PlayerDataService:init()
_G.PlayerDataService = PlayerDataService

-- Step 2: Network Handlers (creates remotes + handles events)
local Handlers = require(Server.Network.Handlers)
Handlers:init()
_G.NetworkHandlers = Handlers

-- Step 3: Run Services
local RunService = require(Server.Run.RunService)
RunService:init()
_G.RunService = RunService

local ScoreService = require(Server.Run.ScoreService)
ScoreService:init()
_G.ScoreService = ScoreService

local CheckpointService = require(Server.Run.CheckpointService)
CheckpointService:init()
_G.CheckpointService = CheckpointService

local DifficultyService = require(Server.Run.DifficultyService)
DifficultyService:init()
_G.DifficultyService = DifficultyService

-- Step 4: Death Service
local DeathService = require(Server.Death.DeathService)
DeathService:init()
_G.DeathService = DeathService

-- Step 5: Corridor System
local CorridorGenerator = require(Server.Corridor.CorridorGenerator)
CorridorGenerator:init()
_G.CorridorGenerator = CorridorGenerator

-- Step 6: Vehicle Service
local VehicleService = require(Server.Vehicle.VehicleService)
VehicleService:init()
_G.VehicleService = VehicleService

-- Step 7: Spawn Service
local SpawnService = require(Server.Character.SpawnService)
SpawnService:init()
_G.SpawnService = SpawnService

-- Handle player joining
Players.PlayerAdded:Connect(function(player)
    print("[Server] Player joined:", player.Name)

    -- Load player data
    PlayerDataService:loadPlayer(player)

    -- Initialize run state
    RunService:initPlayer(player)
    ScoreService:initPlayer(player)

    -- Wait for character
    player.CharacterAdded:Connect(function(character)
        SpawnService:onCharacterAdded(player, character)
        DeathService:setupCharacter(player, character)
    end)

    -- Handle initial character if already exists
    if player.Character then
        SpawnService:onCharacterAdded(player, player.Character)
        DeathService:setupCharacter(player, player.Character)
    end
end)

-- Handle player leaving
Players.PlayerRemoving:Connect(function(player)
    print("[Server] Player leaving:", player.Name)

    -- Save player data
    PlayerDataService:savePlayer(player)

    -- Cleanup
    RunService:cleanupPlayer(player)
    ScoreService:cleanupPlayer(player)
end)

-- Generate the corridor
CorridorGenerator:generate()

print("[Server v" .. VERSION .. "] Glassline initialized!")
