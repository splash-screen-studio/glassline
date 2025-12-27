--!strict
--[[
    HUD/Components/ModeToggle.luau
    Toggle between Ranked and Fun game modes

    Version: 1.1.0
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

    -- Container frame
    local frame = Instance.new("Frame")
    frame.Name = "ModePanel"
    frame.Size = UDim2.new(0, 80, 0, 50)
    frame.Position = UDim2.new(1, -S.ScreenPadding - 80, 0, S.ScreenPadding)
    frame.BackgroundColor3 = C.Background
    frame.BackgroundTransparency = C.BackgroundTransparency
    frame.BorderSizePixel = 0
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, HUDConstants.Sizes.CornerRadius)
    corner.Parent = frame

    local padding = Instance.new("UIPadding")
    padding.PaddingLeft = UDim.new(0, S.ElementGap)
    padding.PaddingRight = UDim.new(0, S.ElementGap)
    padding.PaddingTop = UDim.new(0, S.ElementGap)
    padding.Parent = frame

    -- Toggle button
    local button = Instance.new("TextButton")
    button.Name = "ModeButton"
    button.Size = UDim2.new(1, 0, 0, 22)
    button.BackgroundColor3 = C.Danger
    button.BackgroundTransparency = 0.5
    button.Text = "RANKED"
    button.TextColor3 = C.Danger
    button.TextSize = HUDConstants.FontSizes.Small
    button.Font = Enum.Font.GothamBold
    button.AutoButtonColor = true
    button.Parent = frame

    local buttonCorner = Instance.new("UICorner")
    buttonCorner.CornerRadius = UDim.new(0, 6)
    buttonCorner.Parent = button

    -- Mode info label
    local label = Instance.new("TextLabel")
    label.Name = "ModeInfo"
    label.Size = UDim2.new(1, 0, 0, 12)
    label.Position = UDim2.new(0, 0, 0, 26)
    label.BackgroundTransparency = 1
    label.Text = "Points ON"
    label.TextColor3 = C.TextSecondary
    label.TextSize = HUDConstants.FontSizes.Small
    label.Font = Enum.Font.Gotham
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
            self.button.TextColor3 = C.Success
            self.button.BackgroundColor3 = C.Success
            self.label.Text = "No death"
        else
            self.button.Text = "RANKED"
            self.button.TextColor3 = C.Danger
            self.button.BackgroundColor3 = C.Danger
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
