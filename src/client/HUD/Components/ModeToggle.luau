--!strict
--[[
    HUD/Components/ModeToggle.luau
    Toggle between Ranked and Fun game modes

    Version: 1.0.0
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ModeToggle = {}

local HUDConstants: any

export type ModeToggleWidget = {
    frame: Frame,
    button: TextButton,
    label: TextLabel,
    isFunMode: boolean,
    setMode: (self: ModeToggleWidget, funMode: boolean) -> (),
}

function ModeToggle.create(parent: ScreenGui): ModeToggleWidget
    HUDConstants = require(script.Parent.Parent.HUDConstants)

    local C = HUDConstants.Colors
    local S = HUDConstants.Spacing
    local F = HUDConstants.FontSizes
    local Safe = HUDConstants.SafeArea
    local Layout = HUDConstants.Layout

    -- Container frame
    local frame = Instance.new("Frame")
    frame.Name = "ModePanel"
    frame.Size = UDim2.new(0, Layout.modePanelWidth, 0, HUDConstants.Sizes.panelHeight)
    frame.Position = UDim2.new(1, -Safe.right - Layout.modePanelWidth, 0, Safe.top)
    frame.BackgroundColor3 = C.bg
    frame.BackgroundTransparency = HUDConstants.Transparency.bg
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, HUDConstants.Radius.md)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, S.sm)
    padding.PaddingRight = UDim.new(0, S.sm)
    padding.PaddingTop = UDim.new(0, S.sm)
    padding.Parent = frame

    -- Toggle button
    local button = Instance.new("TextButton")
    button.Name = "ModeButton"
    button.Size = UDim2.new(1, 0, 0, 22)
    button.BackgroundColor3 = C.danger
    button.BackgroundTransparency = 0.5
    button.Text = "RANKED"
    button.TextColor3 = C.danger
    button.TextSize = F.SM
    button.Font = HUDConstants.Fonts.Primary
    button.AutoButtonColor = true
    button.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, HUDConstants.Radius.sm)
    buttonCorner.Parent = button

    -- Mode info label
    local label = Instance.new("TextLabel")
    label.Name = "ModeInfo"
    label.Size = UDim2.new(1, 0, 0, 12)
    label.Position = UDim2.new(0, 0, 0, 24)
    label.BackgroundTransparency = 1
    label.Text = "Points ON"
    label.TextColor3 = C.textMuted
    label.TextSize = F.XS
    label.Font = HUDConstants.Fonts.Secondary
    label.TextXAlignment = Enum.TextXAlignment.Center
    label.Parent = frame

    -- Widget state
    local widget: ModeToggleWidget = {
        frame = frame,
        button = button,
        label = label,
        isFunMode = false,
        setMode = function() end, -- Defined below
    }

    -- Set mode function
    function widget:setMode(funMode: boolean)
        self.isFunMode = funMode

        if funMode then
            self.button.Text = "FUN"
            self.button.TextColor3 = C.success
            self.button.BackgroundColor3 = C.success
            self.label.Text = "No death"
        else
            self.button.Text = "RANKED"
            self.button.TextColor3 = C.danger
            self.button.BackgroundColor3 = C.danger
            self.label.Text = "Points ON"
        end
    end

    -- Button click handler
    button.Activated:Connect(function()
        widget:setMode(not widget.isFunMode)

        -- Notify server
        local folder = ReplicatedStorage:FindFirstChild("NetworkRemotes")
        if folder then
            local toggleRemote = folder:FindFirstChild("ToggleGameMode")
            if toggleRemote then
                local Shared = ReplicatedStorage:WaitForChild("Shared")
                local PlaceConfig = require(Shared.PlaceConfig)
                local mode = widget.isFunMode and PlaceConfig.GameModes.FUN or PlaceConfig.GameModes.RANKED
                ;(toggleRemote :: RemoteEvent):FireServer(mode)
            end
        end
    end)

    return widget
end

return ModeToggle
