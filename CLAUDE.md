# Glassline - Development Guide

A fast-paced runner game through a narrow glass corridor with radically shifting scenery.

## Game Concept

**Core Loop**: Run through a long glass corridor, avoid obstacles, accumulate lifetime points.

- **Corridor**: Single avatar width, tall glass ceiling, glass side walls, very long straight shot
- **Death**: Touch any obstacle = instant death, respawn at start
- **Scoring**: Forward state (1x points), Backward state after reaching end (2x points)
- **End Zone**: Opens to narrow side exploration areas (no points), teleport back resets to forward state
- **Multiplayer**: Ghost mode (see others, no collision)
- **Vehicles**: Appear mid-run with different handling
- **Progressive Difficulty**: Harder the further you go
- **Visuals**: Radically shifting scenery outside glass (realistic, surreal, dreamy, scary, girly, etc.)

---

## Project Structure

```
glassline/
├── src/
│   ├── server/
│   │   ├── init.server.luau     # Server initialization
│   │   ├── Data/                # PlayerDataService (lifetime points)
│   │   ├── Network/             # Handlers, RateLimiter, Validators
│   │   ├── Run/                 # RunService, ScoreService, DifficultyService
│   │   ├── Corridor/            # CorridorGenerator, Obstacles, Zones
│   │   ├── Vehicle/             # VehicleService, VehicleDefinitions
│   │   ├── Death/               # DeathService
│   │   └── Character/           # SpawnService
│   ├── client/
│   │   ├── init.client.luau
│   │   ├── Audio/               # MusicService, SFXService
│   │   ├── HUD/                 # ScoreDisplay, DirectionIndicator, ProgressBar
│   │   ├── Effects/             # ZoneTransition, SpeedLines
│   │   └── Input/               # InputController
│   └── shared/
│       ├── PlaceConfig.luau     # All game configuration
│       ├── Network/             # Event definitions, Types
│       └── Audio/               # AudioConfig, Types
├── tests/                       # TestEZ specs
└── assets/music/                # WAV/MP3 for upload reference
```

---

## Implemented Systems

### Server-Side (`src/server/`)
| Module | Purpose | Key APIs |
|--------|---------|----------|
| `Data/PlayerDataService` | Lifetime points, ProfileService | `:getData()`, `:addPoints()` |
| `Network/Handlers` | Server event handlers | Auto-initializes |
| `Network/Validators` | Input sanitization | `Validators.validate*()` |
| `Network/RateLimiter` | Exploit prevention | `RateLimiter:check()` |
| `Run/RunService` | Run state machine | `:getState()`, `:setState()` |
| `Run/ScoreService` | Directional scoring | `:addProgress()`, `:getMultiplier()` |
| `Run/DifficultyService` | Progressive difficulty | `:getDifficulty()`, `:getSpeedBonus()` |
| `Run/CheckpointService` | Progress tracking | `:getProgress()`, `:reachedEnd()` |
| `Death/DeathService` | Collision, respawn | `:onDeath()`, `:respawn()` |
| `Corridor/CorridorGenerator` | Procedural corridor | `:generate()`, `:getObstacles()` |
| `Vehicle/VehicleService` | Vehicle spawning | `:mount()`, `:dismount()` |
| `Character/SpawnService` | Player spawning | `:spawn()` |

### Client-Side (`src/client/`)
| Module | Purpose | Key APIs |
|--------|---------|----------|
| `Audio/MusicService` | Custom music playback | `:play()`, `:stop()` |
| `Audio/SFXService` | Sound effects | `:play()`, `:playAt()` |
| `HUD/Components/ScoreDisplay` | Lifetime + run points | `.create()`, `:update()` |
| `HUD/Components/DirectionIndicator` | Forward/backward state | `.create()`, `:setState()` |
| `HUD/Components/ProgressBar` | Distance progress | `.create()`, `:setProgress()` |
| `HUD/Components/DeathScreen` | Death overlay | `.create()`, `:show()` |
| `Effects/ZoneTransition` | Zone shift effects | `:transition()` |
| `Effects/SpeedLines` | Speed feedback | `:setIntensity()` |
| `Input/InputController` | Movement, jump, vehicle | `:init()` |

### Shared (`src/shared/`)
| Module | Purpose |
|--------|---------|
| `PlaceConfig` | Corridor, movement, scoring, difficulty, zones |
| `Network/` | RemoteEvent/Function creation, types |
| `Audio/AudioConfig` | Music tracks, SFX definitions |

---

## Key Configuration (PlaceConfig.luau)

```lua
Corridor = {
    width = 6,              -- Avatar width + margin
    height = 50,            -- Tall glass ceiling
    length = 10000,         -- Very long
    wallTransparency = 0.3, -- Glass effect
}

Movement = {
    baseRunSpeed = 80,      -- Very fast
    baseJumpPower = 80,     -- Very fast jumping
    vehicleSpeedMultiplier = 1.5,
}

Scoring = {
    forwardMultiplier = 1,
    backwardMultiplier = 2,
    pointsPerStud = 1,
}

Difficulty = {
    speedIncreasePerZone = 5,
    obstacleFrequencyBase = 0.1,
    obstacleFrequencyMax = 0.5,
    timingWindowShrink = 0.95,
}
```

---

## Development Workflow

### Daily Commands

```bash
# Start Rojo live sync
rojo serve

# Install dependencies
wally install

# Lint
selene src/

# Format
stylua src/
```

### Run Tests (in Studio command bar)

```lua
require(game.ReplicatedStorage.Tests)()
```

---

## Scoring System

### Direction States

1. **Forward State** (default from start)
   - Earn points moving forward
   - No points moving backward
   - Active until reaching end zone

2. **Backward State** (after reaching end)
   - Earn 2x points moving backward
   - No points moving forward
   - Resets to Forward State on teleport to start

### Lifetime Points

- Points persist across runs and sessions (ProfileService)
- Accumulate from all forward/backward progress
- Display: Current run points + Lifetime total

---

## Visual Zones

Scenery outside glass shifts radically every 500 studs:

| Zone | Theme | Difficulty |
|------|-------|------------|
| 0-500 | Realistic Forest | 1 |
| 500-1000 | Surreal Geometric | 2 |
| 1000-1500 | Underwater Depths | 3 |
| 1500-2000 | Dreamy Clouds | 4 |
| 2000-2500 | Scary Shadows | 5 |
| 2500-3000 | Girly Pastel | 6 |
| 3000-3500 | Neon City | 7 |
| 3500-4000 | Abstract Art | 8 |
| ... | More zones | ... |

**Performance**: Use Roblox lighting, fog, weather, colors - minimal geometry.

---

## Obstacle Types

### Static (Memorizable Patterns)
- Walls, pillars, gaps
- Spikes
- Low beams (duck/slide)
- High beams (jump)

### Moving (Timing Challenges)
- Swinging pendulums
- Sliding walls
- Rising/falling platforms
- Rotating bars

---

## Vehicle Types

| Vehicle | Speed | Jump | Notes |
|---------|-------|------|-------|
| Hoverboard | Faster | Lower | Smooth handling |
| Rocket | Much faster | Normal | Hard to control |
| Bouncer | Normal | Super high | For obstacle variety |

---

## Multiplayer

- **Ghost Mode**: See other players as semi-transparent ghosts
- No physical collision between players
- Leaderboard shows lifetime points
- Chaos comes from seeing others dodge/die

---

## Design Principles

### Performance First
- Narrow scenery on sides (minimal geometry)
- Use Roblox lighting, fog, colors for visual impact
- Stream corridor segments

### Mobile-First
- Large touch targets
- Simple controls (run is automatic, tap to jump)
- Portrait or landscape support

### Version Numbers
- Include version in all modules
- Format: `local VERSION = "X.Y.Z"`
- Log: `print("[ModuleName v" .. VERSION .. "] Initialized")`

---

## Music Integration

Custom music files ready (WAV/MP3). To add:
1. Upload to Roblox Creator Hub (Audio section)
2. Get asset IDs
3. Configure in `src/shared/Audio/AudioConfig.luau`

---

## Monetization: Points Multiplier Pass

**Single focused game pass**: Permanent 1.5x points multiplier on all earnings.

### Why This Works for Glassline
- **Stacks with mechanics**: Forward (1x) becomes 1.5x, Backward (2x) becomes 3x
- **No pay-to-win**: Doesn't make obstacles easier, just rewards dedicated players faster
- **Clear value**: Players see immediate impact in their score display
- **One-time purchase**: No subscription fatigue, builds goodwill

### Implementation

**Game Pass ID**: Create in Creator Hub → Monetization → Passes

**Server-side check** (`src/server/Run/ScoreService.luau`):
```lua
local MarketplaceService = game:GetService("MarketplaceService")
local MULTIPLIER_PASS_ID = 0 -- Replace with real ID

local function getPlayerMultiplier(player: Player): number
    local hasPass = MarketplaceService:UserOwnsGamePassAsync(player.UserId, MULTIPLIER_PASS_ID)
    return if hasPass then 1.5 else 1.0
end

-- Apply in score calculation:
points = points * getPlayerMultiplier(player)
```

**HUD indicator**: Show "1.5x" badge next to score for pass owners.

### Pricing Strategy
- **Price**: 199-299 Robux (impulse buy range)
- **Thumbnail**: Gold/sparkle effect on the multiplier number
- **Description**: "Earn 1.5x points on every run! Stacks with backward bonus for 3x total."

### Future Expansion (not in base project)
- Trail effects (cosmetic)
- Vehicle skins (cosmetic)
- Exclusive zone themes (cosmetic)

---

## Dependencies (wally.toml)

```toml
[server-dependencies]
ProfileService = "etheroit/profileservice@1.2.0"

[dev-dependencies]
TestEZ = "roblox/testez@0.4.1"
```
