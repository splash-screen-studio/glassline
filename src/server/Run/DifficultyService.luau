--!strict
--[[
    Run/DifficultyService.luau
    Progressive difficulty scaling

    - Speed increases per zone
    - Obstacle frequency increases
    - Moving obstacles get faster (tighter timing windows)
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local DifficultyService = {}

-- Dependencies
local PlaceConfig: any

function DifficultyService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)

    print("[DifficultyService v" .. VERSION .. "] Initialized")
end

-- Get difficulty level at a Z position (1-20 based on zones)
function DifficultyService:getDifficultyAtPosition(zPosition: number): number
    return PlaceConfig.getDifficultyAtPosition(zPosition)
end

-- Get player run speed at position
function DifficultyService:getSpeedAtPosition(zPosition: number): number
    return PlaceConfig.getSpeedAtPosition(zPosition)
end

-- Get obstacle spawn frequency (0-1) at difficulty level
function DifficultyService:getObstacleFrequency(difficulty: number): number
    return PlaceConfig.getObstacleFrequency(difficulty)
end

-- Get moving obstacle speed multiplier
function DifficultyService:getObstacleSpeedMultiplier(difficulty: number): number
    local base = PlaceConfig.Difficulty.obstacleSpeedBase
    local current = PlaceConfig.getObstacleSpeed(difficulty)
    return current / base
end

-- Get jump power at position (may scale with difficulty)
function DifficultyService:getJumpPowerAtPosition(zPosition: number): number
    -- Jump power stays constant for now (could scale if needed)
    return PlaceConfig.Movement.baseJumpPower
end

-- Apply difficulty settings to a character
function DifficultyService:applyToCharacter(character: Model, zPosition: number)
    local humanoid = character:FindFirstChild("Humanoid") :: Humanoid?
    if not humanoid then return end

    local speed = self:getSpeedAtPosition(zPosition)
    humanoid.WalkSpeed = speed
end

-- Get difficulty summary for UI
function DifficultyService:getDifficultySummary(zPosition: number): {
    level: number,
    speedBonus: number,
    obstacleFrequency: number,
    zoneName: string,
}
    local difficulty = self:getDifficultyAtPosition(zPosition)
    local zone = PlaceConfig.getZoneAtPosition(zPosition)

    return {
        level = difficulty,
        speedBonus = (difficulty - 1) * PlaceConfig.Difficulty.speedIncreasePerZone,
        obstacleFrequency = self:getObstacleFrequency(difficulty),
        zoneName = if zone then zone.theme else "unknown",
    }
end

return DifficultyService
