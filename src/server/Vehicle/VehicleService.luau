--!strict
--[[
    Vehicle/VehicleService.luau
    Vehicle spawning, mounting, and dismounting
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local VehicleService = {}

-- Dependencies
local PlaceConfig: any
local Network: any
local VehicleDefinitions: any

-- Player vehicle states
export type VehicleState = {
    mounted: boolean,
    vehicleType: string?,
    vehicleModel: Model?,
    originalWalkSpeed: number,
    originalJumpPower: number,
}

local playerVehicles: { [Player]: VehicleState } = {}

-- Spawned vehicle pickup zones
local vehiclePickups: { [number]: BasePart } = {} -- zPosition -> pickup part

function VehicleService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)
    VehicleDefinitions = require(script.Parent.VehicleDefinitions)

    -- Spawn vehicle pickup zones
    self:spawnVehiclePickups()

    print("[VehicleService v" .. VERSION .. "] Initialized")
end

function VehicleService:spawnVehiclePickups()
    local pickupsFolder = Instance.new("Folder")
    pickupsFolder.Name = "VehiclePickups"
    pickupsFolder.Parent = workspace

    for _, spawn in PlaceConfig.VehicleSpawns do
        local pickup = Instance.new("Part")
        pickup.Name = "VehiclePickup_" .. spawn.vehicleType
        pickup.Anchored = true
        pickup.CanCollide = false
        pickup.Transparency = 0.5
        pickup.Size = Vector3.new(PlaceConfig.Corridor.width - 1, 5, 3)
        pickup.Position = Vector3.new(0, 3, spawn.position)
        pickup.Color = Color3.fromRGB(0, 255, 100)
        pickup.Material = Enum.Material.Neon
        pickup:SetAttribute("VehicleType", spawn.vehicleType)
        pickup.Parent = pickupsFolder

        vehiclePickups[spawn.position] = pickup

        -- Touch detection for auto-mount
        pickup.Touched:Connect(function(other)
            local player = game.Players:GetPlayerFromCharacter(other.Parent)
            if player then
                local state = playerVehicles[player]
                if not state or not state.mounted then
                    self:mountVehicle(player, spawn.vehicleType)
                end
            end
        end)
    end
end

function VehicleService:mountVehicle(player: Player, vehicleType: string): { success: boolean, error: string? }
    local vehicleDef = VehicleDefinitions.get(vehicleType)
    if not vehicleDef then
        return { success = false, error = "Unknown vehicle type" }
    end

    local character = player.Character
    if not character then
        return { success = false, error = "No character" }
    end

    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid then
        return { success = false, error = "No humanoid" }
    end

    -- Check if already mounted
    local state = playerVehicles[player]
    if state and state.mounted then
        return { success = false, error = "Already mounted" }
    end

    -- Store original stats
    local originalWalkSpeed = humanoid.WalkSpeed
    local originalJumpPower = humanoid.JumpPower

    -- Apply vehicle stats
    humanoid.WalkSpeed = originalWalkSpeed * vehicleDef.speedMultiplier
    humanoid.JumpPower = originalJumpPower * vehicleDef.jumpMultiplier

    -- Create vehicle state
    playerVehicles[player] = {
        mounted = true,
        vehicleType = vehicleType,
        vehicleModel = nil, -- Could attach a vehicle model here
        originalWalkSpeed = originalWalkSpeed,
        originalJumpPower = originalJumpPower,
    }

    -- Notify client
    Network.Events.VehicleMounted:FireClient(player, {
        vehicleType = vehicleType,
        speedMultiplier = vehicleDef.speedMultiplier,
        jumpMultiplier = vehicleDef.jumpMultiplier,
    })

    print("[VehicleService]", player.Name, "mounted", vehicleType)
    return { success = true }
end

function VehicleService:dismountVehicle(player: Player): { success: boolean, error: string? }
    local state = playerVehicles[player]
    if not state or not state.mounted then
        return { success = false, error = "Not mounted" }
    end

    local character = player.Character
    if not character then
        return { success = false, error = "No character" }
    end

    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid then
        return { success = false, error = "No humanoid" }
    end

    -- Restore original stats
    humanoid.WalkSpeed = state.originalWalkSpeed
    humanoid.JumpPower = state.originalJumpPower

    -- Cleanup vehicle model if exists
    if state.vehicleModel then
        state.vehicleModel:Destroy()
    end

    -- Update state
    state.mounted = false
    state.vehicleType = nil
    state.vehicleModel = nil

    -- Notify client
    Network.Events.VehicleDismounted:FireClient(player, {})

    print("[VehicleService]", player.Name, "dismounted")
    return { success = true }
end

function VehicleService:isPlayerMounted(player: Player): boolean
    local state = playerVehicles[player]
    return state ~= nil and state.mounted
end

function VehicleService:getPlayerVehicleType(player: Player): string?
    local state = playerVehicles[player]
    if state and state.mounted then
        return state.vehicleType
    end
    return nil
end

function VehicleService:cleanupPlayer(player: Player)
    local state = playerVehicles[player]
    if state and state.vehicleModel then
        state.vehicleModel:Destroy()
    end
    playerVehicles[player] = nil
end

return VehicleService
