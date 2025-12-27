--!strict
--[[
    Effects/init.luau
    Visual effects controller for Glassline
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Effects = {}

-- Sub-modules
local ZoneTransition: any
local SpeedLines: any

function Effects:init()
    ZoneTransition = require(script.ZoneTransition)
    ZoneTransition:init()

    SpeedLines = require(script.SpeedLines)
    SpeedLines:init()

    print("[Effects v" .. VERSION .. "] Initialized")
end

function Effects:transitionZone(newTheme: string)
    ZoneTransition:transition(newTheme)
end

function Effects:setSpeedIntensity(intensity: number)
    SpeedLines:setIntensity(intensity)
end

function Effects:showImpact(position: Vector3)
    -- Could add impact particle effects here
end

return Effects
