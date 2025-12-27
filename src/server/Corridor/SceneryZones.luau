--!strict
--[[
    Corridor/SceneryZones.luau
    Visual zone definitions for scenery outside the glass walls

    Note: Actual scenery models would be added in Studio or via asset pipeline.
    This module defines the visual themes and provides zone-based information.
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local SceneryZones = {}

-- Dependencies
local PlaceConfig: any

-- Zone theme configurations (for procedural effects, not full models)
export type ZoneTheme = {
    id: string,
    name: string,
    description: string,

    -- Colors for procedural elements
    primaryColor: Color3,
    secondaryColor: Color3,
    accentColor: Color3,

    -- Atmosphere
    fogDensity: number,
    particleType: string?,  -- "rain", "snow", "sparkle", "fire", etc.

    -- Sound (references AudioConfig)
    ambientSound: string?,
}

local ZoneThemes: { [string]: ZoneTheme } = {
    realistic_forest = {
        id = "realistic_forest",
        name = "Forest",
        description = "Lush green forest with dappled sunlight",
        primaryColor = Color3.fromRGB(34, 139, 34),
        secondaryColor = Color3.fromRGB(85, 107, 47),
        accentColor = Color3.fromRGB(255, 223, 186),
        fogDensity = 0.1,
        particleType = nil,
        ambientSound = "forest",
    },

    surreal_geometric = {
        id = "surreal_geometric",
        name = "Geometric Dreams",
        description = "Floating geometric shapes in impossible arrangements",
        primaryColor = Color3.fromRGB(147, 112, 219),
        secondaryColor = Color3.fromRGB(72, 61, 139),
        accentColor = Color3.fromRGB(255, 215, 0),
        fogDensity = 0.2,
        particleType = "sparkle",
        ambientSound = "ethereal",
    },

    underwater_depths = {
        id = "underwater_depths",
        name = "Deep Ocean",
        description = "Dark ocean depths with bioluminescent creatures",
        primaryColor = Color3.fromRGB(0, 105, 148),
        secondaryColor = Color3.fromRGB(0, 51, 102),
        accentColor = Color3.fromRGB(127, 255, 212),
        fogDensity = 0.4,
        particleType = "bubbles",
        ambientSound = "underwater",
    },

    dreamy_clouds = {
        id = "dreamy_clouds",
        name = "Cloud Kingdom",
        description = "Soft pastel clouds and floating islands",
        primaryColor = Color3.fromRGB(255, 182, 193),
        secondaryColor = Color3.fromRGB(230, 230, 250),
        accentColor = Color3.fromRGB(255, 255, 224),
        fogDensity = 0.15,
        particleType = "sparkle",
        ambientSound = "wind",
    },

    scary_shadows = {
        id = "scary_shadows",
        name = "Shadow Realm",
        description = "Dark twisted landscape with lurking shadows",
        primaryColor = Color3.fromRGB(25, 25, 25),
        secondaryColor = Color3.fromRGB(50, 0, 50),
        accentColor = Color3.fromRGB(255, 0, 0),
        fogDensity = 0.5,
        particleType = nil,
        ambientSound = "creepy",
    },

    girly_pastel = {
        id = "girly_pastel",
        name = "Pastel Paradise",
        description = "Cute pastel world with hearts and stars",
        primaryColor = Color3.fromRGB(255, 182, 193),
        secondaryColor = Color3.fromRGB(221, 160, 221),
        accentColor = Color3.fromRGB(255, 255, 224),
        fogDensity = 0.1,
        particleType = "sparkle",
        ambientSound = "magical",
    },

    neon_city = {
        id = "neon_city",
        name = "Neon City",
        description = "Cyberpunk cityscape with glowing neon lights",
        primaryColor = Color3.fromRGB(0, 255, 255),
        secondaryColor = Color3.fromRGB(255, 0, 255),
        accentColor = Color3.fromRGB(255, 255, 0),
        fogDensity = 0.3,
        particleType = "rain",
        ambientSound = "city",
    },

    abstract_art = {
        id = "abstract_art",
        name = "Abstract Gallery",
        description = "Living abstract art in motion",
        primaryColor = Color3.fromRGB(255, 165, 0),
        secondaryColor = Color3.fromRGB(0, 128, 128),
        accentColor = Color3.fromRGB(255, 255, 255),
        fogDensity = 0.2,
        particleType = nil,
        ambientSound = "ambient",
    },

    crystal_caves = {
        id = "crystal_caves",
        name = "Crystal Caves",
        description = "Glittering crystal formations",
        primaryColor = Color3.fromRGB(135, 206, 250),
        secondaryColor = Color3.fromRGB(75, 0, 130),
        accentColor = Color3.fromRGB(255, 255, 255),
        fogDensity = 0.25,
        particleType = "sparkle",
        ambientSound = "cave",
    },

    volcanic_fire = {
        id = "volcanic_fire",
        name = "Volcanic Inferno",
        description = "Rivers of lava and erupting volcanoes",
        primaryColor = Color3.fromRGB(255, 69, 0),
        secondaryColor = Color3.fromRGB(139, 0, 0),
        accentColor = Color3.fromRGB(255, 215, 0),
        fogDensity = 0.35,
        particleType = "fire",
        ambientSound = "lava",
    },

    frozen_tundra = {
        id = "frozen_tundra",
        name = "Frozen Tundra",
        description = "Endless ice and snow",
        primaryColor = Color3.fromRGB(240, 248, 255),
        secondaryColor = Color3.fromRGB(176, 224, 230),
        accentColor = Color3.fromRGB(135, 206, 250),
        fogDensity = 0.3,
        particleType = "snow",
        ambientSound = "wind",
    },

    candy_land = {
        id = "candy_land",
        name = "Candy Land",
        description = "Sweet treats and sugar everywhere",
        primaryColor = Color3.fromRGB(255, 105, 180),
        secondaryColor = Color3.fromRGB(255, 182, 193),
        accentColor = Color3.fromRGB(144, 238, 144),
        fogDensity = 0.1,
        particleType = "sparkle",
        ambientSound = "magical",
    },

    steampunk = {
        id = "steampunk",
        name = "Steampunk Factory",
        description = "Brass gears and steam machinery",
        primaryColor = Color3.fromRGB(184, 134, 11),
        secondaryColor = Color3.fromRGB(139, 69, 19),
        accentColor = Color3.fromRGB(255, 215, 0),
        fogDensity = 0.3,
        particleType = nil,
        ambientSound = "machinery",
    },

    cosmic_void = {
        id = "cosmic_void",
        name = "Cosmic Void",
        description = "Deep space with distant galaxies",
        primaryColor = Color3.fromRGB(25, 25, 112),
        secondaryColor = Color3.fromRGB(0, 0, 0),
        accentColor = Color3.fromRGB(255, 255, 255),
        fogDensity = 0.05,
        particleType = "sparkle",
        ambientSound = "space",
    },

    jungle_temple = {
        id = "jungle_temple",
        name = "Jungle Temple",
        description = "Ancient ruins in dense jungle",
        primaryColor = Color3.fromRGB(34, 139, 34),
        secondaryColor = Color3.fromRGB(85, 107, 47),
        accentColor = Color3.fromRGB(218, 165, 32),
        fogDensity = 0.35,
        particleType = nil,
        ambientSound = "jungle",
    },

    glitch_digital = {
        id = "glitch_digital",
        name = "Digital Glitch",
        description = "Corrupted digital reality",
        primaryColor = Color3.fromRGB(0, 255, 0),
        secondaryColor = Color3.fromRGB(0, 0, 0),
        accentColor = Color3.fromRGB(255, 0, 255),
        fogDensity = 0.2,
        particleType = nil,
        ambientSound = "digital",
    },

    ancient_ruins = {
        id = "ancient_ruins",
        name = "Ancient Ruins",
        description = "Crumbling stone temples",
        primaryColor = Color3.fromRGB(188, 143, 143),
        secondaryColor = Color3.fromRGB(139, 119, 101),
        accentColor = Color3.fromRGB(218, 165, 32),
        fogDensity = 0.25,
        particleType = nil,
        ambientSound = "wind",
    },

    rainbow_prism = {
        id = "rainbow_prism",
        name = "Rainbow Prism",
        description = "Pure light split into infinite colors",
        primaryColor = Color3.fromRGB(255, 0, 0),
        secondaryColor = Color3.fromRGB(0, 255, 0),
        accentColor = Color3.fromRGB(0, 0, 255),
        fogDensity = 0.1,
        particleType = "sparkle",
        ambientSound = "magical",
    },

    nightmare_realm = {
        id = "nightmare_realm",
        name = "Nightmare Realm",
        description = "Twisted landscape of fears",
        primaryColor = Color3.fromRGB(50, 0, 0),
        secondaryColor = Color3.fromRGB(0, 0, 0),
        accentColor = Color3.fromRGB(255, 0, 0),
        fogDensity = 0.6,
        particleType = nil,
        ambientSound = "horror",
    },

    transcendence = {
        id = "transcendence",
        name = "Transcendence",
        description = "Pure white light and peace",
        primaryColor = Color3.fromRGB(255, 255, 255),
        secondaryColor = Color3.fromRGB(255, 255, 240),
        accentColor = Color3.fromRGB(255, 215, 0),
        fogDensity = 0.05,
        particleType = "sparkle",
        ambientSound = "ethereal",
    },
}

function SceneryZones:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)

    print("[SceneryZones v" .. VERSION .. "] Loaded", #PlaceConfig.Zones, "zone themes")
end

function SceneryZones.getTheme(themeId: string): ZoneTheme?
    return ZoneThemes[themeId]
end

function SceneryZones.getThemeForPosition(zPosition: number): ZoneTheme?
    local zone = PlaceConfig.getZoneAtPosition(zPosition)
    if zone then
        return ZoneThemes[zone.theme]
    end
    return nil
end

function SceneryZones.getAllThemes(): { [string]: ZoneTheme }
    return ZoneThemes
end

return SceneryZones
