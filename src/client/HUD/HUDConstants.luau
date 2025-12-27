--!strict
--[[
    HUD/HUDConstants.luau
    Consolidated Design System for Glassline HUD

    SINGLE SOURCE OF TRUTH for all HUD styling.
    Mobile-first, iPhone landscape optimized.
]]

local HUDConstants = {}

-- ============================================
-- TYPOGRAPHY (ONE font family)
-- ============================================
HUDConstants.Fonts = {
    Primary = Enum.Font.GothamBold,
    Secondary = Enum.Font.Gotham,
}

HUDConstants.FontSizes = {
    XS = 8,
    SM = 10,
    MD = 12,
    LG = 16,
    XL = 24,
    XXL = 32,
}

-- ============================================
-- COLOR PALETTE (LIMITED - 7 colors)
-- ============================================
HUDConstants.Colors = {
    -- Backgrounds
    bg = Color3.fromRGB(15, 15, 20),
    bgAlt = Color3.fromRGB(25, 25, 35),

    -- Text
    text = Color3.fromRGB(220, 220, 220),
    textMuted = Color3.fromRGB(120, 120, 130),

    -- Semantic
    accent = Color3.fromRGB(80, 200, 255),   -- Cyan (points, highlights)
    danger = Color3.fromRGB(255, 80, 80),    -- Red (ranked, death)
    success = Color3.fromRGB(80, 255, 120),  -- Green (fun mode)
}

-- ============================================
-- TRANSPARENCY (Consistent)
-- ============================================
HUDConstants.Transparency = {
    bg = 0.35,
    overlay = 0.5,
    solid = 0,
}

-- ============================================
-- SPACING (Consistent padding/gaps)
-- ============================================
HUDConstants.Spacing = {
    xs = 4,
    sm = 6,
    md = 10,
    lg = 16,
    xl = 24,
}

-- ============================================
-- BORDER RADIUS
-- ============================================
HUDConstants.Radius = {
    sm = 4,
    md = 6,
    lg = 10,
}

-- ============================================
-- SAFE AREAS (iPhone notch/edge)
-- ============================================
HUDConstants.SafeArea = {
    left = 48,
    right = 48,
    top = 8,
    bottom = 8,
}

-- ============================================
-- ELEMENT SIZES (Mobile-first, compact)
-- ============================================
HUDConstants.Sizes = {
    panelHeight = 44,
    mirrorSize = 60,
    buttonMin = 36,
    touchTarget = 44,
}

-- ============================================
-- Z-INDEX LAYERS
-- ============================================
HUDConstants.ZIndex = {
    base = 1,
    hud = 10,
    overlay = 50,
    death = 100,
}

-- ============================================
-- ANIMATION
-- ============================================
HUDConstants.Animation = {
    fast = 0.15,
    normal = 0.3,
    slow = 0.5,
    easing = Enum.EasingStyle.Quad,
    direction = Enum.EasingDirection.Out,
}

-- ============================================
-- LAYOUT POSITIONS
-- ============================================
HUDConstants.Layout = {
    -- Panel sizes
    scorePanelWidth = 100,
    modePanelWidth = 70,
    zonePanelWidth = 80,
    mirrorPanelWidth = 72,
    mirrorPanelHeight = 80,
}

return HUDConstants
