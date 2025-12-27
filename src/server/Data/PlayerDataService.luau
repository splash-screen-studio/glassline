--!strict
--[[
    PlayerDataService.luau
    Manages player data persistence using ProfileService

    Stores:
    - Lifetime points
    - Highest distance reached
    - Total runs
    - Total deaths
]]

local VERSION = "1.0.0"

local Players = game:GetService("Players")
local ServerScriptService = game:GetService("ServerScriptService")

local PlayerDataService = {}

-- Profile template (default data for new players)
local PROFILE_TEMPLATE = {
    lifetimePoints = 0,
    highestDistance = 0,
    totalRuns = 0,
    totalDeaths = 0,
    settings = {
        musicVolume = 0.6,
        sfxVolume = 0.8,
    },
}

-- ProfileService (loaded in init)
local ProfileService: any
local ProfileStore: any

-- Active profiles
local profiles: { [Player]: any } = {}

function PlayerDataService:init()
    -- Load ProfileService from ServerPackages
    local ServerPackages = ServerScriptService:FindFirstChild("ServerPackages")
    if ServerPackages then
        local profileServiceModule = ServerPackages:FindFirstChild("ProfileService")
        if profileServiceModule then
            ProfileService = require(profileServiceModule)
            ProfileStore = ProfileService.GetProfileStore("GlasslinePlayerData", PROFILE_TEMPLATE)
            print("[PlayerDataService v" .. VERSION .. "] ProfileService loaded")
        else
            warn("[PlayerDataService] ProfileService not found - using mock data")
        end
    else
        warn("[PlayerDataService] ServerPackages not found - run 'wally install'")
    end

    print("[PlayerDataService v" .. VERSION .. "] Initialized")
end

function PlayerDataService:loadPlayer(player: Player)
    if not ProfileStore then
        -- Mock profile for development without ProfileService
        profiles[player] = {
            Data = table.clone(PROFILE_TEMPLATE),
            Release = function() end,
        }
        print("[PlayerDataService] Created mock profile for", player.Name)
        return
    end

    local profileKey = "Player_" .. player.UserId
    local profile = ProfileStore:LoadProfileAsync(profileKey)

    if profile then
        profile:AddUserId(player.UserId)
        profile:Reconcile() -- Fill in missing values from template

        profile:ListenToRelease(function()
            profiles[player] = nil
            player:Kick("Profile released - please rejoin")
        end)

        if player:IsDescendantOf(Players) then
            profiles[player] = profile
            print("[PlayerDataService] Loaded profile for", player.Name)
        else
            profile:Release()
        end
    else
        player:Kick("Failed to load data - please rejoin")
    end
end

function PlayerDataService:savePlayer(player: Player)
    local profile = profiles[player]
    if profile then
        profile:Release()
        profiles[player] = nil
        print("[PlayerDataService] Saved profile for", player.Name)
    end
end

function PlayerDataService:getData(player: Player): typeof(PROFILE_TEMPLATE)?
    local profile = profiles[player]
    if profile then
        return profile.Data
    end
    return nil
end

function PlayerDataService:addPoints(player: Player, points: number)
    local data = self:getData(player)
    if data then
        data.lifetimePoints = data.lifetimePoints + points
    end
end

function PlayerDataService:getLifetimePoints(player: Player): number
    local data = self:getData(player)
    return if data then data.lifetimePoints else 0
end

function PlayerDataService:updateHighestDistance(player: Player, distance: number)
    local data = self:getData(player)
    if data and distance > data.highestDistance then
        data.highestDistance = distance
    end
end

function PlayerDataService:incrementRuns(player: Player)
    local data = self:getData(player)
    if data then
        data.totalRuns = data.totalRuns + 1
    end
end

function PlayerDataService:incrementDeaths(player: Player)
    local data = self:getData(player)
    if data then
        data.totalDeaths = data.totalDeaths + 1
    end
end

return PlayerDataService
