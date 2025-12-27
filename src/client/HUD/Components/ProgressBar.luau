--!strict
--[[
    HUD/Components/ProgressBar.luau
    Shows distance progress through the corridor
]]

local VERSION = "1.0.0"

local TweenService = game:GetService("TweenService")

local ProgressBar = {}

local HUDConstants = require(script.Parent.Parent.HUDConstants)

export type ProgressBarWidget = {
    frame: Frame,
    setProgress: (self: ProgressBarWidget, progress: number) -> (),
    destroy: (self: ProgressBarWidget) -> (),
}

function ProgressBar.create(parent: GuiObject): ProgressBarWidget
    local C = HUDConstants

    -- Container (bottom-center, full width)
    local frame = Instance.new("Frame")
    frame.Name = "ProgressBar"
    frame.Size = UDim2.new(1, -C.Spacing.ScreenPadding * 2, 0, C.Sizes.ProgressBarHeight)
    frame.Position = UDim2.new(0, C.Spacing.ScreenPadding, 1, -C.Spacing.ScreenPadding - C.Sizes.ProgressBarHeight)
    frame.BackgroundColor3 = C.Colors.ProgressBackground
    frame.BackgroundTransparency = 0.3
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, C.Sizes.ProgressBarHeight / 2)
    corner.Parent = frame

    -- Fill bar
    local fill = Instance.new("Frame")
    fill.Name = "Fill"
    fill.Size = UDim2.new(0, 0, 1, 0)
    fill.Position = UDim2.new(0, 0, 0, 0)
    fill.BackgroundColor3 = C.Colors.ProgressFill
    fill.Parent = frame

    local fillCorner = Instance.new("UICorner")
    fillCorner.CornerRadius = UDim.new(0, C.Sizes.ProgressBarHeight / 2)
    fillCorner.Parent = fill

    -- Zone markers (vertical lines at zone boundaries)
    -- These would be added based on PlaceConfig.Zones

    -- Widget
    local widget: ProgressBarWidget = {
        frame = frame,

        setProgress = function(self, progress: number)
            progress = math.clamp(progress, 0, 1)

            local tween = TweenService:Create(
                fill,
                TweenInfo.new(C.Animation.TweenTimeFast, C.Animation.EasingStyle, C.Animation.EasingDirection),
                { Size = UDim2.new(progress, 0, 1, 0) }
            )
            tween:Play()

            -- Color shift based on progress (cyan -> gold at end)
            local color = C.Colors.ProgressFill:Lerp(C.Colors.Backward, progress)
            fill.BackgroundColor3 = color
        end,

        destroy = function(self)
            self.frame:Destroy()
        end,
    }

    return widget
end

return ProgressBar
