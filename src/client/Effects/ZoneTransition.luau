--!strict
--[[
    Effects/ZoneTransition.luau
    Visual transition effects when entering new zones
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local ZoneTransition = {}

-- Dependencies
local PlaceConfig: any

-- Current state
local currentTheme: string = ""

-- Transition overlay
local transitionOverlay: Frame?

function ZoneTransition:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)

    -- Create transition overlay
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "ZoneTransitionOverlay"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 100
    screenGui.Parent = playerGui

    transitionOverlay = Instance.new("Frame")
    transitionOverlay.Name = "Overlay"
    transitionOverlay.Size = UDim2.new(1, 0, 1, 0)
    transitionOverlay.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
    transitionOverlay.BackgroundTransparency = 1
    transitionOverlay.Parent = screenGui

    print("[ZoneTransition v" .. VERSION .. "] Initialized")
end

function ZoneTransition:transition(newTheme: string)
    if newTheme == currentTheme then return end
    currentTheme = newTheme

    -- Get lighting preset
    local lighting = PlaceConfig.getLightingForZone(newTheme)
    if not lighting then return end

    -- Flash overlay
    if transitionOverlay then
        transitionOverlay.BackgroundTransparency = 0.7

        local fadeOut = TweenService:Create(
            transitionOverlay,
            TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            { BackgroundTransparency = 1 }
        )
        fadeOut:Play()
    end

    -- Tween lighting properties
    for property, value in lighting do
        if typeof(value) == "Color3" then
            local tween = TweenService:Create(
                Lighting,
                TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { [property] = value }
            )
            tween:Play()
        elseif typeof(value) == "number" then
            local tween = TweenService:Create(
                Lighting,
                TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
                { [property] = value }
            )
            tween:Play()
        end
    end
end

function ZoneTransition:getCurrentTheme(): string
    return currentTheme
end

return ZoneTransition
