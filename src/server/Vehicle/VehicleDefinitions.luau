--!strict
--[[
    Vehicle/VehicleDefinitions.luau
    Vehicle type definitions
]]

local VERSION = "1.0.0"

local VehicleDefinitions = {}

export type VehicleDefinition = {
    id: string,
    name: string,
    description: string,
    speedMultiplier: number,    -- Multiplier on base run speed
    jumpMultiplier: number,     -- Multiplier on base jump power
    color: Color3,              -- Visual color
    duration: number?,          -- Optional: auto-dismount after seconds
}

local Vehicles: { [string]: VehicleDefinition } = {
    hoverboard = {
        id = "hoverboard",
        name = "Hoverboard",
        description = "Faster but lower jumps",
        speedMultiplier = 1.5,
        jumpMultiplier = 0.7,
        color = Color3.fromRGB(0, 200, 255),
    },

    rocket = {
        id = "rocket",
        name = "Rocket",
        description = "Much faster but hard to control",
        speedMultiplier = 2.0,
        jumpMultiplier = 1.0,
        color = Color3.fromRGB(255, 100, 0),
    },

    bouncer = {
        id = "bouncer",
        name = "Bouncer",
        description = "Normal speed but super high jumps",
        speedMultiplier = 1.0,
        jumpMultiplier = 2.0,
        color = Color3.fromRGB(0, 255, 100),
    },
}

function VehicleDefinitions.get(id: string): VehicleDefinition?
    return Vehicles[id]
end

function VehicleDefinitions.getAll(): { [string]: VehicleDefinition }
    return Vehicles
end

print("[VehicleDefinitions v" .. VERSION .. "] Loaded", 3, "vehicles")

return VehicleDefinitions
