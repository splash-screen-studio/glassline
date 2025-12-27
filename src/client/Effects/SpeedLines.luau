--!strict
--[[
    Effects/SpeedLines.luau
    Visual speed feedback with screen-edge lines
]]

local VERSION = "1.0.0"

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local SpeedLines = {}

-- State
local intensity: number = 0
local speedLinesFrame: Frame?
local lines: { Frame } = {}
local NUM_LINES = 8

function SpeedLines:init()
    local player = Players.LocalPlayer
    local playerGui = player:WaitForChild("PlayerGui")

    -- Create container
    local screenGui = Instance.new("ScreenGui")
    screenGui.Name = "SpeedLinesOverlay"
    screenGui.ResetOnSpawn = false
    screenGui.DisplayOrder = 50
    screenGui.IgnoreGuiInset = true
    screenGui.Parent = playerGui

    speedLinesFrame = Instance.new("Frame")
    speedLinesFrame.Name = "SpeedLines"
    speedLinesFrame.Size = UDim2.new(1, 0, 1, 0)
    speedLinesFrame.BackgroundTransparency = 1
    speedLinesFrame.Parent = screenGui

    -- Create speed lines (edges of screen)
    for i = 1, NUM_LINES do
        local line = Instance.new("Frame")
        line.Name = "Line" .. i
        line.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
        line.BackgroundTransparency = 1
        line.BorderSizePixel = 0
        line.Parent = speedLinesFrame

        -- Position on edges
        local side = (i - 1) % 4 -- 0=top, 1=right, 2=bottom, 3=left
        local offset = math.floor((i - 1) / 4) * 0.2

        if side == 0 then -- Top
            line.Size = UDim2.new(0.1 + offset * 0.1, 0, 0, 3)
            line.Position = UDim2.new(0.1 + offset * 0.2, 0, 0, 0)
            line.AnchorPoint = Vector2.new(0, 0)
        elseif side == 1 then -- Right
            line.Size = UDim2.new(0, 3, 0.1 + offset * 0.1, 0)
            line.Position = UDim2.new(1, 0, 0.1 + offset * 0.2, 0)
            line.AnchorPoint = Vector2.new(1, 0)
        elseif side == 2 then -- Bottom
            line.Size = UDim2.new(0.1 + offset * 0.1, 0, 0, 3)
            line.Position = UDim2.new(0.8 - offset * 0.2, 0, 1, 0)
            line.AnchorPoint = Vector2.new(1, 1)
        else -- Left
            line.Size = UDim2.new(0, 3, 0.1 + offset * 0.1, 0)
            line.Position = UDim2.new(0, 0, 0.8 - offset * 0.2, 0)
            line.AnchorPoint = Vector2.new(0, 1)
        end

        table.insert(lines, line)
    end

    -- Update loop
    RunService.RenderStepped:Connect(function()
        self:update()
    end)

    print("[SpeedLines v" .. VERSION .. "] Initialized")
end

function SpeedLines:setIntensity(newIntensity: number)
    intensity = math.clamp(newIntensity, 0, 1)
end

function SpeedLines:update()
    -- Auto-calculate intensity based on player speed
    local player = Players.LocalPlayer
    local character = player.Character
    if not character then return end

    local rootPart = character:FindFirstChild("HumanoidRootPart") :: BasePart?
    if not rootPart then return end

    local speed = rootPart.AssemblyLinearVelocity.Magnitude
    local normalizedSpeed = math.clamp((speed - 20) / 100, 0, 1) -- 20-120 range

    -- Lerp intensity
    intensity = intensity + (normalizedSpeed - intensity) * 0.1

    -- Update line transparency based on intensity
    for i, line in lines do
        local baseTransparency = 0.3 + (i / NUM_LINES) * 0.3
        local targetTransparency = 1 - (1 - baseTransparency) * intensity
        line.BackgroundTransparency = targetTransparency
    end
end

return SpeedLines
