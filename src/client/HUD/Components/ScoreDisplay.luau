--!strict
--[[
    HUD/Components/ScoreDisplay.luau
    Displays run points and lifetime points
]]

local VERSION = "1.0.0"

local TweenService = game:GetService("TweenService")

local ScoreDisplay = {}

local HUDConstants = require(script.Parent.Parent.HUDConstants)

export type ScoreDisplayWidget = {
    frame: Frame,
    update: (self: ScoreDisplayWidget, runPoints: number, lifetimePoints: number, multiplier: number) -> (),
    flashMultiplier: (self: ScoreDisplayWidget) -> (),
    destroy: (self: ScoreDisplayWidget) -> (),
}

function ScoreDisplay.create(parent: GuiObject): ScoreDisplayWidget
    local C = HUDConstants

    -- Main container (top-center)
    local frame = Instance.new("Frame")
    frame.Name = "ScoreDisplay"
    frame.Size = UDim2.new(0, 300, 0, C.Sizes.ScoreHeight)
    frame.Position = UDim2.new(0.5, -150, 0, C.Spacing.ScreenPadding)
    frame.BackgroundColor3 = C.Colors.Background
    frame.BackgroundTransparency = C.Colors.BackgroundTransparency
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, C.Sizes.CornerRadius)
    corner.Parent = frame

    -- Run points (large, center)
    local runPointsLabel = Instance.new("TextLabel")
    runPointsLabel.Name = "RunPoints"
    runPointsLabel.Size = UDim2.new(1, 0, 0.6, 0)
    runPointsLabel.Position = UDim2.new(0, 0, 0, 0)
    runPointsLabel.BackgroundTransparency = 1
    runPointsLabel.TextColor3 = C.Colors.TextPrimary
    runPointsLabel.TextSize = C.FontSizes.Score
    runPointsLabel.FontFace = C.Fonts.Score
    runPointsLabel.Text = "0"
    runPointsLabel.Parent = frame

    -- Multiplier indicator
    local multiplierLabel = Instance.new("TextLabel")
    multiplierLabel.Name = "Multiplier"
    multiplierLabel.Size = UDim2.new(0, 40, 0, 24)
    multiplierLabel.Position = UDim2.new(1, -50, 0, 5)
    multiplierLabel.BackgroundColor3 = C.Colors.Forward
    multiplierLabel.BackgroundTransparency = 0.3
    multiplierLabel.TextColor3 = C.Colors.TextPrimary
    multiplierLabel.TextSize = C.FontSizes.Medium
    multiplierLabel.FontFace = C.Fonts.Title
    multiplierLabel.Text = "1x"
    multiplierLabel.Parent = frame

    local multCorner = Instance.new("UICorner")
    multCorner.CornerRadius = UDim.new(0, 5)
    multCorner.Parent = multiplierLabel

    -- Lifetime points (smaller, bottom)
    local lifetimeLabel = Instance.new("TextLabel")
    lifetimeLabel.Name = "LifetimePoints"
    lifetimeLabel.Size = UDim2.new(1, 0, 0.4, 0)
    lifetimeLabel.Position = UDim2.new(0, 0, 0.6, 0)
    lifetimeLabel.BackgroundTransparency = 1
    lifetimeLabel.TextColor3 = C.Colors.TextSecondary
    lifetimeLabel.TextSize = C.FontSizes.Medium
    lifetimeLabel.FontFace = C.Fonts.Body
    lifetimeLabel.Text = "Lifetime: 0"
    lifetimeLabel.Parent = frame

    -- Widget
    local widget: ScoreDisplayWidget = {
        frame = frame,

        update = function(self, runPoints: number, lifetimePoints: number, multiplier: number)
            -- Animate run points
            local currentText = runPointsLabel.Text
            local current = tonumber(currentText) or 0
            local target = runPoints

            if current ~= target then
                -- Quick count-up animation
                local steps = 10
                local stepValue = (target - current) / steps

                task.spawn(function()
                    for i = 1, steps do
                        current = current + stepValue
                        runPointsLabel.Text = tostring(math.floor(current))
                        task.wait(0.02)
                    end
                    runPointsLabel.Text = tostring(math.floor(target))
                end)
            end

            -- Update lifetime
            lifetimeLabel.Text = "Lifetime: " .. tostring(math.floor(lifetimePoints))

            -- Update multiplier
            multiplierLabel.Text = tostring(multiplier) .. "x"
            multiplierLabel.BackgroundColor3 = if multiplier > 1
                then C.Colors.Backward
                else C.Colors.Forward
        end,

        flashMultiplier = function(self)
            -- Flash animation for multiplier change
            local original = multiplierLabel.BackgroundColor3
            multiplierLabel.BackgroundColor3 = Color3.fromRGB(255, 255, 255)

            local tween = TweenService:Create(
                multiplierLabel,
                TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundColor3 = original }
            )
            tween:Play()
        end,

        destroy = function(self)
            self.frame:Destroy()
        end,
    }

    return widget
end

return ScoreDisplay
