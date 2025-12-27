--!strict
--[[
    HUD/Components/DirectionIndicator.luau
    Shows current direction state (forward/backward)
]]

local VERSION = "1.0.0"

local TweenService = game:GetService("TweenService")

local DirectionIndicator = {}

local HUDConstants = require(script.Parent.Parent.HUDConstants)

export type DirectionIndicatorWidget = {
    frame: Frame,
    setState: (self: DirectionIndicatorWidget, state: string, multiplier: number) -> (),
    destroy: (self: DirectionIndicatorWidget) -> (),
}

function DirectionIndicator.create(parent: GuiObject): DirectionIndicatorWidget
    local C = HUDConstants

    -- Container (top-right)
    local frame = Instance.new("Frame")
    frame.Name = "DirectionIndicator"
    frame.Size = UDim2.new(0, 120, 0, C.Sizes.DirectionIndicatorSize)
    frame.Position = UDim2.new(1, -120 - C.Spacing.ScreenPadding, 0, C.Spacing.ScreenPadding)
    frame.BackgroundColor3 = C.Colors.Forward
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, C.Sizes.CornerRadius)
    corner.Parent = frame

    -- Arrow icon
    local arrow = Instance.new("TextLabel")
    arrow.Name = "Arrow"
    arrow.Size = UDim2.new(0, 30, 1, 0)
    arrow.Position = UDim2.new(0, 5, 0, 0)
    arrow.BackgroundTransparency = 1
    arrow.TextColor3 = C.Colors.TextPrimary
    arrow.TextSize = C.FontSizes.Large
    arrow.FontFace = C.Fonts.Title
    arrow.Text = ">"
    arrow.Parent = frame

    -- State text
    local stateLabel = Instance.new("TextLabel")
    stateLabel.Name = "StateLabel"
    stateLabel.Size = UDim2.new(1, -40, 1, 0)
    stateLabel.Position = UDim2.new(0, 35, 0, 0)
    stateLabel.BackgroundTransparency = 1
    stateLabel.TextColor3 = C.Colors.TextPrimary
    stateLabel.TextSize = C.FontSizes.Medium
    stateLabel.FontFace = C.Fonts.Title
    stateLabel.Text = "FORWARD"
    stateLabel.TextXAlignment = Enum.TextXAlignment.Left
    stateLabel.Parent = frame

    -- Widget
    local widget: DirectionIndicatorWidget = {
        frame = frame,

        setState = function(self, state: string, multiplier: number)
            local isForward = state == "forward"

            -- Update visuals
            arrow.Text = if isForward then ">" else "<"
            stateLabel.Text = if isForward then "FORWARD" else "BACKWARD"

            -- Animate color change
            local targetColor = if isForward then C.Colors.Forward else C.Colors.Backward

            local tween = TweenService:Create(
                frame,
                TweenInfo.new(C.Animation.TweenTime, C.Animation.EasingStyle, C.Animation.EasingDirection),
                { BackgroundColor3 = targetColor }
            )
            tween:Play()

            -- Flash effect
            if not isForward then
                -- Pulse for backward (2x mode)
                local pulse = TweenService:Create(
                    frame,
                    TweenInfo.new(0.5, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, 2, true),
                    { BackgroundTransparency = 0.1 }
                )
                pulse:Play()
            end
        end,

        destroy = function(self)
            self.frame:Destroy()
        end,
    }

    return widget
end

return DirectionIndicator
