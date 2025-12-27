--!strict
--[[
    Network/RateLimiter.luau
    Per-player, per-event rate limiting to prevent exploits
]]

local VERSION = "1.0.0"

local Players = game:GetService("Players")

local RateLimiter = {}

-- Rate limits: { requests per window, window in seconds }
local Limits = {
    RequestRespawn = { requests = 5, windowSeconds = 10 },
    RequestMount = { requests = 10, windowSeconds = 5 },
    RequestDismount = { requests = 10, windowSeconds = 5 },
    RequestTeleportToStart = { requests = 5, windowSeconds = 10 },
    _default = { requests = 30, windowSeconds = 10 },
}

-- Tracking: player -> event -> { timestamps }
local playerRequests: { [Player]: { [string]: { number } } } = {}

function RateLimiter:init()
    -- Cleanup on player leave
    Players.PlayerRemoving:Connect(function(player)
        playerRequests[player] = nil
    end)

    print("[RateLimiter v" .. VERSION .. "] Initialized")
end

function RateLimiter:check(player: Player, eventName: string): boolean
    -- Get or create player tracking
    if not playerRequests[player] then
        playerRequests[player] = {}
    end

    local playerEvents = playerRequests[player]
    if not playerEvents[eventName] then
        playerEvents[eventName] = {}
    end

    local timestamps = playerEvents[eventName]
    local limits = Limits[eventName] or Limits._default
    local now = os.clock()
    local windowStart = now - limits.windowSeconds

    -- Remove old timestamps
    local validTimestamps = {}
    for _, timestamp in timestamps do
        if timestamp > windowStart then
            table.insert(validTimestamps, timestamp)
        end
    end

    -- Check if under limit
    if #validTimestamps >= limits.requests then
        warn("[RateLimiter] Player", player.Name, "rate limited on", eventName)
        return false
    end

    -- Add new timestamp
    table.insert(validTimestamps, now)
    playerEvents[eventName] = validTimestamps

    return true
end

-- Initialize on module load
RateLimiter:init()

return RateLimiter
