--!strict
--[[
    Character/SpawnService.luau
    Player spawning and teleportation
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local SpawnService = {}

-- Dependencies
local PlaceConfig: any
local Network: any
local DifficultyService: any

function SpawnService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    local Server = script.Parent.Parent
    DifficultyService = require(Server.Run.DifficultyService)

    print("[SpawnService v" .. VERSION .. "] Initialized")
end

function SpawnService:onCharacterAdded(player: Player, character: Model)
    -- Wait for character to load
    local humanoid = character:WaitForChild("Humanoid") :: Humanoid
    local rootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

    -- Apply initial movement settings
    humanoid.WalkSpeed = PlaceConfig.Movement.baseRunSpeed
    humanoid.JumpPower = PlaceConfig.Movement.baseJumpPower

    -- Position at spawn
    rootPart.CFrame = CFrame.new(PlaceConfig.Spawn.position) *
        CFrame.lookAt(Vector3.zero, PlaceConfig.Spawn.lookDirection)

    print("[SpawnService]", player.Name, "spawned at start")
end

function SpawnService:respawnPlayer(player: Player)
    -- Force respawn
    player:LoadCharacter()
end

function SpawnService:teleportToStart(player: Player)
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not rootPart then return end

    -- Teleport to start position
    rootPart.CFrame = CFrame.new(PlaceConfig.Spawn.position) *
        CFrame.lookAt(Vector3.zero, PlaceConfig.Spawn.lookDirection)

    -- Notify client
    Network.Events.PlayerRespawned:FireClient(player, {
        position = PlaceConfig.Spawn.position,
        resetRun = true,
    })

    print("[SpawnService]", player.Name, "teleported to start")
end

function SpawnService:teleportToPosition(player: Player, position: Vector3)
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not rootPart then return end

    rootPart.CFrame = CFrame.new(position)

    -- Update movement speed for new position
    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if humanoid then
        DifficultyService:applyToCharacter(character, position.Z)
    end
end

return SpawnService
