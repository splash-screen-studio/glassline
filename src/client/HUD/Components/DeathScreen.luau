--!strict
--[[
    HUD/Components/DeathScreen.luau
    Death overlay with cause and stats
]]

local VERSION = "1.0.0"

local TweenService = game:GetService("TweenService")

local DeathScreen = {}

local HUDConstants = require(script.Parent.Parent.HUDConstants)

export type DeathScreenWidget = {
    frame: Frame,
    show: (self: DeathScreenWidget, cause: string, runPoints: number) -> (),
    hide: (self: DeathScreenWidget) -> (),
    destroy: (self: DeathScreenWidget) -> (),
}

function DeathScreen.create(parent: GuiObject): DeathScreenWidget
    local C = HUDConstants

    -- Full screen overlay
    local frame = Instance.new("Frame")
    frame.Name = "DeathScreen"
    frame.Size = UDim2.new(1, 0, 1, 0)
    frame.Position = UDim2.new(0, 0, 0, 0)
    frame.BackgroundColor3 = C.Colors.DeathOverlay
    frame.BackgroundTransparency = 1
    frame.ZIndex = C.ZIndex.DeathScreen
    frame.Visible = false
    frame.Parent = parent

    -- Center panel
    local panel = Instance.new("Frame")
    panel.Name = "Panel"
    panel.Size = UDim2.new(0, 300, 0, 200)
    panel.Position = UDim2.new(0.5, -150, 0.5, -100)
    panel.BackgroundColor3 = C.Colors.Background
    panel.BackgroundTransparency = 0.2
    panel.ZIndex = C.ZIndex.DeathScreen + 1
    panel.Parent = frame

    local panelCorner = Instance.new("UICorner")
    panelCorner.CornerRadius = UDim.new(0, C.Sizes.CornerRadius)
    panelCorner.Parent = panel

    -- Title
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, 0, 0, 50)
    title.Position = UDim2.new(0, 0, 0, 20)
    title.BackgroundTransparency = 1
    title.TextColor3 = C.Colors.DeathText
    title.TextSize = C.FontSizes.Title
    title.FontFace = C.Fonts.Title
    title.Text = "WASTED"
    title.ZIndex = C.ZIndex.DeathScreen + 2
    title.Parent = panel

    -- Cause
    local cause = Instance.new("TextLabel")
    cause.Name = "Cause"
    cause.Size = UDim2.new(1, 0, 0, 30)
    cause.Position = UDim2.new(0, 0, 0, 70)
    cause.BackgroundTransparency = 1
    cause.TextColor3 = C.Colors.TextSecondary
    cause.TextSize = C.FontSizes.Medium
    cause.FontFace = C.Fonts.Body
    cause.Text = "Hit an obstacle"
    cause.ZIndex = C.ZIndex.DeathScreen + 2
    cause.Parent = panel

    -- Points earned
    local points = Instance.new("TextLabel")
    points.Name = "Points"
    points.Size = UDim2.new(1, 0, 0, 40)
    points.Position = UDim2.new(0, 0, 0, 110)
    points.BackgroundTransparency = 1
    points.TextColor3 = C.Colors.TextPrimary
    points.TextSize = C.FontSizes.Large
    points.FontFace = C.Fonts.Score
    points.Text = "+0 points"
    points.ZIndex = C.ZIndex.DeathScreen + 2
    points.Parent = panel

    -- Respawning message
    local respawn = Instance.new("TextLabel")
    respawn.Name = "Respawn"
    respawn.Size = UDim2.new(1, 0, 0, 20)
    respawn.Position = UDim2.new(0, 0, 1, -30)
    respawn.BackgroundTransparency = 1
    respawn.TextColor3 = C.Colors.TextSecondary
    respawn.TextSize = C.FontSizes.Small
    respawn.FontFace = C.Fonts.Body
    respawn.Text = "Respawning..."
    respawn.ZIndex = C.ZIndex.DeathScreen + 2
    respawn.Parent = panel

    -- Widget
    local widget: DeathScreenWidget = {
        frame = frame,

        show = function(self, causeText: string, runPoints: number)
            cause.Text = "Hit: " .. causeText
            points.Text = "+" .. tostring(math.floor(runPoints)) .. " points"

            frame.Visible = true
            frame.BackgroundTransparency = 1

            -- Fade in overlay
            local overlayTween = TweenService:Create(
                frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                { BackgroundTransparency = 0.6 }
            )
            overlayTween:Play()

            -- Slide in panel
            panel.Position = UDim2.new(0.5, -150, 0.5, -200)
            local panelTween = TweenService:Create(
                panel,
                TweenInfo.new(0.4, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
                { Position = UDim2.new(0.5, -150, 0.5, -100) }
            )
            panelTween:Play()
        end,

        hide = function(self)
            -- Fade out
            local overlayTween = TweenService:Create(
                frame,
                TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In),
                { BackgroundTransparency = 1 }
            )
            overlayTween:Play()

            overlayTween.Completed:Once(function()
                frame.Visible = false
            end)
        end,

        destroy = function(self)
            self.frame:Destroy()
        end,
    }

    return widget
end

return DeathScreen
