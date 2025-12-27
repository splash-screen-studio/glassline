--!strict
--[[
    HUD/init.luau
    Main HUD controller for Glassline
]]

local VERSION = "1.1.0"

local Players = game:GetService("Players")

local HUD = {}

-- Components
local ScoreDisplay: any
local ProgressBar: any
local DeathScreen: any
local HUDConstants: any

-- UI instances
local screenGui: ScreenGui
local scoreWidget: any
local progressWidget: any
local deathWidget: any

-- State
local vehicleIndicator: TextLabel?

function HUD:init()
    HUDConstants = require(script.HUDConstants)
    ScoreDisplay = require(script.Components.ScoreDisplay)
    ProgressBar = require(script.Components.ProgressBar)
    DeathScreen = require(script.Components.DeathScreen)

    -- Create screen GUI
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    screenGui = Instance.new("ScreenGui")
    screenGui.Name = "GlasslineHUD"
    screenGui.ResetOnSpawn = false
    screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    screenGui.Parent = playerGui

    -- Create components
    scoreWidget = ScoreDisplay.create(screenGui)
    progressWidget = ProgressBar.create(screenGui)
    deathWidget = DeathScreen.create(screenGui)

    print("[HUD v" .. VERSION .. "] Initialized")
end

function HUD:updateScore(runPoints: number, lifetimePoints: number, multiplier: number)
    if scoreWidget then
        scoreWidget:update(runPoints, lifetimePoints, multiplier)
    end
end

function HUD:updateProgress(position: number, total: number)
    if progressWidget then
        progressWidget:setProgress(position / total)
    end
end

function HUD:updateDirectionState(state: string, multiplier: number)
    -- Direction indicator removed
end

function HUD:showDeathScreen(cause: string, runPoints: number)
    if deathWidget then
        deathWidget:show(cause, runPoints)
    end
end

function HUD:hideDeathScreen()
    if deathWidget then
        deathWidget:hide()
    end
end

function HUD:showVehicleIndicator(vehicleType: string)
    if vehicleIndicator then
        vehicleIndicator:Destroy()
    end

    vehicleIndicator = Instance.new("TextLabel")
    vehicleIndicator.Name = "VehicleIndicator"
    vehicleIndicator.Size = UDim2.new(0, 150, 0, 40)
    vehicleIndicator.Position = UDim2.new(0.5, -75, 0, 100)
    vehicleIndicator.BackgroundColor3 = HUDConstants.Colors.Success
    vehicleIndicator.BackgroundTransparency = 0.3
    vehicleIndicator.TextColor3 = HUDConstants.Colors.TextPrimary
    vehicleIndicator.Text = vehicleType:upper()
    vehicleIndicator.TextSize = HUDConstants.FontSizes.Large
    vehicleIndicator.FontFace = HUDConstants.Fonts.Title
    vehicleIndicator.Parent = screenGui

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, HUDConstants.Sizes.CornerRadius)
    corner.Parent = vehicleIndicator
end

function HUD:hideVehicleIndicator()
    if vehicleIndicator then
        vehicleIndicator:Destroy()
        vehicleIndicator = nil
    end
end

function HUD:showReachedEnd(runPoints: number, totalDistance: number)
    -- Could show a special end screen
    -- For now, just update score
    if scoreWidget then
        scoreWidget:flashMultiplier()
    end
end

function HUD:setInitialData(data: { lifetimePoints: number, highestDistance: number })
    if scoreWidget then
        scoreWidget:update(0, data.lifetimePoints, 1)
    end
end

return HUD
