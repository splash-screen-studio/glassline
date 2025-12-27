--!strict
--[[
    Run/CheckpointService.luau
    Progress tracking and zone management
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local CheckpointService = {}

-- Dependencies
local PlaceConfig: any
local Network: any

-- Player checkpoints
export type PlayerCheckpoint = {
    currentZoneIndex: number,
    highestZoneReached: number,
    zoneEntryTimes: { [number]: number }, -- Zone index -> entry time
}

local playerCheckpoints: { [Player]: PlayerCheckpoint } = {}

function CheckpointService:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    PlaceConfig = require(Shared.PlaceConfig)
    Network = require(Shared.Network)

    print("[CheckpointService v" .. VERSION .. "] Initialized")
end

function CheckpointService:initPlayer(player: Player)
    playerCheckpoints[player] = {
        currentZoneIndex = 1,
        highestZoneReached = 1,
        zoneEntryTimes = { [1] = os.clock() },
    }
end

function CheckpointService:cleanupPlayer(player: Player)
    playerCheckpoints[player] = nil
end

function CheckpointService:updatePlayerZone(player: Player, zPosition: number)
    local checkpoint = playerCheckpoints[player]
    if not checkpoint then return end

    -- Find current zone
    local newZoneIndex = 1
    for i, zone in PlaceConfig.Zones do
        if zPosition >= zone.startZ and zPosition < zone.endZ then
            newZoneIndex = i
            break
        end
    end

    -- Check for zone change
    if newZoneIndex ~= checkpoint.currentZoneIndex then
        local oldZoneIndex = checkpoint.currentZoneIndex
        checkpoint.currentZoneIndex = newZoneIndex

        -- Track entry time for new zone
        if not checkpoint.zoneEntryTimes[newZoneIndex] then
            checkpoint.zoneEntryTimes[newZoneIndex] = os.clock()
        end

        -- Update highest reached
        if newZoneIndex > checkpoint.highestZoneReached then
            checkpoint.highestZoneReached = newZoneIndex
        end

        -- Notify client of zone change
        local newZone = PlaceConfig.Zones[newZoneIndex]
        if newZone then
            Network.Events.ZoneChanged:FireClient(player, {
                zone = newZone,
                theme = newZone.theme,
                difficulty = newZone.difficulty,
            })
        end
    end
end

function CheckpointService:getCurrentZone(player: Player): typeof(PlaceConfig.Zones[1])?
    local checkpoint = playerCheckpoints[player]
    if not checkpoint then return nil end

    return PlaceConfig.Zones[checkpoint.currentZoneIndex]
end

function CheckpointService:getProgress(player: Player): number
    -- Returns progress as 0-1 through the corridor
    local checkpoint = playerCheckpoints[player]
    if not checkpoint then return 0 end

    local zone = PlaceConfig.Zones[checkpoint.currentZoneIndex]
    if not zone then return 0 end

    -- Calculate based on current position within corridor
    return zone.startZ / PlaceConfig.Corridor.length
end

function CheckpointService:hasReachedEnd(player: Player): boolean
    local checkpoint = playerCheckpoints[player]
    if not checkpoint then return false end

    return checkpoint.highestZoneReached >= #PlaceConfig.Zones
end

function CheckpointService:resetProgress(player: Player)
    local checkpoint = playerCheckpoints[player]
    if checkpoint then
        checkpoint.currentZoneIndex = 1
        -- Note: highestZoneReached is NOT reset (lifetime tracking)
        checkpoint.zoneEntryTimes = { [1] = os.clock() }
    end
end

return CheckpointService
