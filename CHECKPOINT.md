# Glassline Checkpoint - Terrain World

**Date:** 2025-12-27

## Current State

Working terrain-based world with:
- 10,000 stud corridor with Concrete floor (perfectly level left-to-right)
- 20 themed zones with different terrain materials on sides
- Undulating terrain that dips below water level
- Large spawn room (80x20x20) with forced camera facing down corridor
- Entry arch with neon glow

## Versions

| Component | Version |
|-----------|---------|
| Server | 2.0.0 |
| PlaceConfig | 1.2.0 |
| SpawnService | 1.1.0 |
| TerrainGenerator | 1.0.0 |
| SpawnRoomBuilder | 1.0.0 |

## Git

- **Commit:** `43496a6adf11e149367322ac9f8d3ea261842737`
- **Short:** `43496a6`
- **Message:** Add terrain-based world generation - major milestone

## Roblox

- **Experience ID:** 9446184940
- **Place ID:** 134785407886208
- **Published Version:** 20

## How to Revert

### Revert Code
```bash
git checkout 43496a6
```

Or to create a branch at this point:
```bash
git checkout -b checkpoint-terrain-world 43496a6
```

### Revert Roblox Place
1. Go to Creator Hub: https://create.roblox.com
2. Navigate to Glassline experience
3. Go to Places > Version History
4. Select Version 20
5. Click "Revert to this version"

### Rebuild from Code
```bash
git checkout 43496a6
rojo build -o glassline.rbxl
source .env && rbxcloud experience publish \
  --api-key "$ROBLOX_API_KEY" \
  --universe-id 9446184940 \
  --place-id 134785407886208 \
  --filename glassline.rbxl \
  --version-type published
```

## Zone Materials (in order)

1. Grass (0-500)
2. Rock (500-1000)
3. Sand (1000-1500)
4. Snow (1500-2000)
5. Slate (2000-2500)
6. Grass (2500-3000)
7. Asphalt (3000-3500)
8. Sandstone (3500-4000)
9. Ice (4000-4500)
10. CrackedLava (4500-5000)
11. Glacier (5000-5500)
12. Grass (5500-6000)
13. Brick (6000-6500)
14. Basalt (6500-7000)
15. LeafyGrass (7000-7500)
16. Limestone (7500-8000)
17. Rock (8000-8500)
18. Salt (8500-9000)
19. Mud (9000-9500)
20. Snow (9500-10000)
