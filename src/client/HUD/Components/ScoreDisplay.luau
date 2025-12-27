--!strict
--[[
    HUD/Components/ScoreDisplay.luau
    Displays run points, multiplier, and lifetime points stacked vertically
]]

local VERSION = "1.1.0"

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

    -- Main container (top-center, taller for vertical stack)
    local frame = Instance.new("Frame")
    frame.Name = "ScoreDisplay"
    frame.Size = UDim2.new(0, 160, 0, 100)
    frame.Position = UDim2.new(0.5, -80, 0, C.Spacing.ScreenPadding)
    frame.BackgroundColor3 = C.Colors.Background
    frame.BackgroundTransparency = C.Colors.BackgroundTransparency
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, C.Sizes.CornerRadius)
    corner.Parent = frame

    -- Run points (top, large)
    local runPointsLabel = Instance.new("TextLabel")
    runPointsLabel.Name = "RunPoints"
    runPointsLabel.Size = UDim2.new(1, 0, 0, 40)
    runPointsLabel.Position = UDim2.new(0, 0, 0, 5)
    runPointsLabel.BackgroundTransparency = 1
    runPointsLabel.TextColor3 = C.Colors.TextPrimary
    runPointsLabel.TextSize = 36
    runPointsLabel.FontFace = C.Fonts.Score
    runPointsLabel.Text = "0"
    runPointsLabel.Parent = frame

    -- Multiplier (middle, centered)
    local multiplierLabel = Instance.new("TextLabel")
    multiplierLabel.Name = "Multiplier"
    multiplierLabel.Size = UDim2.new(0, 50, 0, 24)
    multiplierLabel.Position = UDim2.new(0.5, -25, 0, 45)
    multiplierLabel.BackgroundColor3 = C.Colors.Primary
    multiplierLabel.BackgroundTransparency = 0.3
    multiplierLabel.TextColor3 = C.Colors.TextPrimary
    multiplierLabel.TextSize = C.FontSizes.Medium
    multiplierLabel.FontFace = C.Fonts.Title
    multiplierLabel.Text = "1x"
    multiplierLabel.Parent = frame

    local multCorner = Instance.new("UICorner")
    multCorner.CornerRadius = UDim.new(0, 5)
    multCorner.Parent = multiplierLabel

    -- Lifetime points (bottom, smaller)
    local lifetimeLabel = Instance.new("TextLabel")
    lifetimeLabel.Name = "LifetimePoints"
    lifetimeLabel.Size = UDim2.new(1, 0, 0, 20)
    lifetimeLabel.Position = UDim2.new(0, 0, 0, 72)
    lifetimeLabel.BackgroundTransparency = 1
    lifetimeLabel.TextColor3 = C.Colors.TextSecondary
    lifetimeLabel.TextSize = C.FontSizes.Small
    lifetimeLabel.FontFace = C.Fonts.Body
    lifetimeLabel.Text = "0"
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

            -- Update lifetime (just the number)
            lifetimeLabel.Text = tostring(math.floor(lifetimePoints))

            -- Update multiplier
            multiplierLabel.Text = tostring(multiplier) .. "x"
            multiplierLabel.BackgroundColor3 = if multiplier > 1
                then C.Colors.Warning
                else C.Colors.Primary
        end,

        flashMultiplier = function(self)
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
