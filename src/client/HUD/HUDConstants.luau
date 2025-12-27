--!strict
--[[
    HUD/HUDConstants.luau
    Centralized styling constants for Glassline HUD
]]

local HUDConstants = {}

-- Spacing (mobile-first)
HUDConstants.Spacing = {
    ScreenPadding = 16,
    ContainerPadding = 12,
    ElementGap = 8,
}

-- Sizes
HUDConstants.Sizes = {
    TouchTarget = 48,
    CornerRadius = 10,
    ProgressBarHeight = 8,
    ScoreHeight = 60,
    DirectionIndicatorSize = 40,
}

-- Colors
HUDConstants.Colors = {
    -- Base
    Background = Color3.fromRGB(0, 0, 0),
    BackgroundTransparency = 0.5,

    -- Text
    TextPrimary = Color3.fromRGB(255, 255, 255),
    TextSecondary = Color3.fromRGB(180, 180, 180),

    -- Accents
    Primary = Color3.fromRGB(0, 200, 255),      -- Cyan
    Secondary = Color3.fromRGB(255, 100, 0),    -- Orange
    Success = Color3.fromRGB(0, 255, 100),      -- Green
    Warning = Color3.fromRGB(255, 200, 0),      -- Yellow
    Danger = Color3.fromRGB(255, 50, 50),       -- Red

    -- Direction states
    Forward = Color3.fromRGB(0, 200, 255),      -- Cyan (1x)
    Backward = Color3.fromRGB(255, 200, 0),     -- Gold (2x)

    -- Progress bar
    ProgressBackground = Color3.fromRGB(40, 40, 40),
    ProgressFill = Color3.fromRGB(0, 200, 255),

    -- Death screen
    DeathOverlay = Color3.fromRGB(50, 0, 0),
    DeathText = Color3.fromRGB(255, 50, 50),
}

-- Fonts
HUDConstants.Fonts = {
    Title = Font.fromName("GothamBold", Enum.FontWeight.Bold),
    Body = Font.fromName("Gotham", Enum.FontWeight.Regular),
    Score = Font.fromName("GothamBold", Enum.FontWeight.Bold),
}

-- Font sizes
HUDConstants.FontSizes = {
    Small = 12,
    Medium = 16,
    Large = 24,
    Title = 32,
    Score = 48,
}

-- Animation
HUDConstants.Animation = {
    TweenTime = 0.3,
    TweenTimeFast = 0.15,
    TweenTimeSlow = 0.5,
    EasingStyle = Enum.EasingStyle.Quad,
    EasingDirection = Enum.EasingDirection.Out,
}

-- Z-Index layers
HUDConstants.ZIndex = {
    Background = 1,
    HUD = 10,
    Overlay = 50,
    DeathScreen = 100,
}

return HUDConstants
