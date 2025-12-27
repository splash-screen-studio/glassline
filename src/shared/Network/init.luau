--!strict
--[[
    Network/init.luau
    Centralized network event definitions for Glassline

    Server creates all RemoteEvents/Functions on init.
    Client lazily accesses them via Network.Events.EventName.
]]

local VERSION = "1.0.0"

local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Network = {}

-- Event definitions: { name, type }
local EventDefinitions = {
    -- Score & Progress
    { name = "ScoreUpdate", type = "event" },           -- Server → Client: score changed
    { name = "ProgressUpdate", type = "event" },        -- Server → Client: position/progress
    { name = "DirectionStateChanged", type = "event" }, -- Server → Client: forward/backward

    -- Death & Respawn
    { name = "PlayerDied", type = "event" },            -- Server → Client: player died
    { name = "PlayerRespawned", type = "event" },       -- Server → Client: player respawned
    { name = "RequestRespawn", type = "event" },        -- Client → Server: request respawn

    -- Vehicles
    { name = "VehicleMounted", type = "event" },        -- Server → Client: mounted vehicle
    { name = "VehicleDismounted", type = "event" },     -- Server → Client: dismounted
    { name = "RequestMount", type = "event" },          -- Client → Server: try mount
    { name = "RequestDismount", type = "event" },       -- Client → Server: try dismount

    -- Zones
    { name = "ZoneChanged", type = "event" },           -- Server → Client: entered new zone

    -- End Zone
    { name = "ReachedEnd", type = "event" },            -- Server → Client: reached end zone
    { name = "RequestTeleportToStart", type = "event" },-- Client → Server: teleport back

    -- Multiplayer (Ghost mode)
    { name = "GhostUpdate", type = "event" },           -- Server → All: player positions

    -- Data
    { name = "GetPlayerData", type = "function" },      -- Client → Server: request data
    { name = "DataLoaded", type = "event" },            -- Server → Client: data ready
}

-- Container for remotes
local remoteFolder: Folder

-- Lazy-loaded event/function accessors
Network.Events = {} :: { [string]: RemoteEvent }
Network.Functions = {} :: { [string]: RemoteFunction }

-- Server: Create all remotes
function Network.init()
    if not RunService:IsServer() then
        warn("[Network] init() should only be called on server")
        return
    end

    -- Create folder for remotes
    remoteFolder = Instance.new("Folder")
    remoteFolder.Name = "NetworkRemotes"
    remoteFolder.Parent = ReplicatedStorage

    -- Create each remote
    for _, def in EventDefinitions do
        if def.type == "event" then
            local remote = Instance.new("RemoteEvent")
            remote.Name = def.name
            remote.Parent = remoteFolder
        elseif def.type == "function" then
            local remote = Instance.new("RemoteFunction")
            remote.Name = def.name
            remote.Parent = remoteFolder
        end
    end

    print("[Network v" .. VERSION .. "] Created", #EventDefinitions, "remotes")
end

-- Client/Server: Get remote folder (waits for it on client)
local function getRemoteFolder(): Folder
    if remoteFolder then
        return remoteFolder
    end

    if RunService:IsClient() then
        remoteFolder = ReplicatedStorage:WaitForChild("NetworkRemotes", 10) :: Folder
        if not remoteFolder then
            error("[Network] NetworkRemotes folder not found - is server running?")
        end
    end

    return remoteFolder
end

-- Metatable for lazy event access
setmetatable(Network.Events, {
    __index = function(_, name: string): RemoteEvent
        local folder = getRemoteFolder()
        local remote = folder:FindFirstChild(name)
        if not remote then
            error("[Network] RemoteEvent '" .. name .. "' not found")
        end
        return remote :: RemoteEvent
    end,
})

-- Metatable for lazy function access
setmetatable(Network.Functions, {
    __index = function(_, name: string): RemoteFunction
        local folder = getRemoteFolder()
        local remote = folder:FindFirstChild(name)
        if not remote then
            error("[Network] RemoteFunction '" .. name .. "' not found")
        end
        return remote :: RemoteFunction
    end,
})

return Network
