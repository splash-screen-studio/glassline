# Crystal Clear Glass - The Fix

## Problem
Corridor glass walls appeared frosted/foggy instead of crystal clear.

## Root Causes

### 1. Glass Material Has Built-in Frost
Roblox's `Enum.Material.Glass` has an inherent frosted/translucent effect that cannot be removed.

**Fix:** Use `Enum.Material.SmoothPlastic` instead.

### 2. Low Transparency Value
Original `wallTransparency = 0.3` was too opaque.

**Fix:** Increase to `0.85` for crystal clear visibility.

### 3. Atmosphere Object in Lighting
An Atmosphere object with `Density = 0.3` and `Haze = 1` added global fog.

**Fix:** Set `Density = 0` and `Haze = 0`, or remove the Atmosphere entirely.

## The Fix (PlaceConfig.luau)

```lua
PlaceConfig.Corridor = {
    wallTransparency = 0.85,    -- Crystal clear (NOT 0.3)
    wallMaterial = Enum.Material.SmoothPlastic,  -- NOT Glass
    ceilingMaterial = Enum.Material.SmoothPlastic,
    wallColor = Color3.fromRGB(200, 220, 255),  -- Subtle blue tint
}
```

## The Fix (CorridorGenerator.luau)

```lua
-- Use config material, not hardcoded Glass
leftWall.Material = config.wallMaterial or Enum.Material.SmoothPlastic
rightWall.Material = config.wallMaterial or Enum.Material.SmoothPlastic
```

## The Fix (Lighting.Atmosphere)

```lua
local atmosphere = Lighting:FindFirstChildOfClass("Atmosphere")
if atmosphere then
    atmosphere.Density = 0
    atmosphere.Haze = 0
end
```

## Quick Studio Fix

If glass appears frosted, run this in the command bar:

```lua
-- Crystal clear glass fix
local corridor = workspace:FindFirstChild("GlasslineCorridor")
if corridor then
    for _, folder in {"Walls", "Ceiling"} do
        local f = corridor:FindFirstChild(folder)
        if f then
            for _, part in f:GetChildren() do
                part.Material = Enum.Material.SmoothPlastic
                part.Transparency = 0.85
            end
        end
    end
end

local Lighting = game:GetService("Lighting")
local atmo = Lighting:FindFirstChildOfClass("Atmosphere")
if atmo then atmo.Density = 0; atmo.Haze = 0 end

print("Glass is now crystal clear!")
```

## Lesson Learned

**Never use `Enum.Material.Glass` for transparent walls you want to see through clearly.** The Glass material is designed for frosted/translucent glass, not crystal clear windows.

Use `SmoothPlastic` + high transparency for truly clear surfaces.
