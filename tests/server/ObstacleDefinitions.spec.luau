--!strict
--[[
    ObstacleDefinitions Tests
]]

return function()
    -- Note: ObstacleDefinitions is server-side, so we test PlaceConfig zones instead
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local PlaceConfig = require(Shared.PlaceConfig)

    describe("PlaceConfig.Zones", function()
        it("should have at least 10 zones", function()
            expect(#PlaceConfig.Zones >= 10).to.equal(true)
        end)

        it("should have zones that cover the entire corridor", function()
            local lastEnd = 0
            for _, zone in PlaceConfig.Zones do
                expect(zone.startZ).to.equal(lastEnd)
                lastEnd = zone.endZ
            end
            expect(lastEnd).to.equal(PlaceConfig.Corridor.length)
        end)

        it("should have unique themes for each zone", function()
            local themes = {}
            for _, zone in PlaceConfig.Zones do
                expect(themes[zone.theme]).to.equal(nil)
                themes[zone.theme] = true
            end
        end)

        it("should have increasing difficulty", function()
            local lastDifficulty = 0
            for _, zone in PlaceConfig.Zones do
                expect(zone.difficulty > lastDifficulty).to.equal(true)
                lastDifficulty = zone.difficulty
            end
        end)

        it("each zone should have required fields", function()
            for _, zone in PlaceConfig.Zones do
                expect(zone.startZ).to.be.a("number")
                expect(zone.endZ).to.be.a("number")
                expect(zone.theme).to.be.a("string")
                expect(zone.difficulty).to.be.a("number")
            end
        end)
    end)

    describe("PlaceConfig.Corridor", function()
        it("should have valid dimensions", function()
            expect(PlaceConfig.Corridor.width).to.be.a("number")
            expect(PlaceConfig.Corridor.width > 0).to.equal(true)

            expect(PlaceConfig.Corridor.height).to.be.a("number")
            expect(PlaceConfig.Corridor.height > 0).to.equal(true)

            expect(PlaceConfig.Corridor.length).to.be.a("number")
            expect(PlaceConfig.Corridor.length > 0).to.equal(true)
        end)

        it("should have glass wall settings", function()
            expect(PlaceConfig.Corridor.wallTransparency).to.be.a("number")
            expect(PlaceConfig.Corridor.wallTransparency >= 0).to.equal(true)
            expect(PlaceConfig.Corridor.wallTransparency <= 1).to.equal(true)
        end)
    end)

    describe("PlaceConfig.VehicleSpawns", function()
        it("should have vehicle spawn points", function()
            expect(#PlaceConfig.VehicleSpawns > 0).to.equal(true)
        end)

        it("each spawn should have position and type", function()
            for _, spawn in PlaceConfig.VehicleSpawns do
                expect(spawn.position).to.be.a("number")
                expect(spawn.vehicleType).to.be.a("string")
            end
        end)

        it("spawn positions should be within corridor", function()
            for _, spawn in PlaceConfig.VehicleSpawns do
                expect(spawn.position >= 0).to.equal(true)
                expect(spawn.position <= PlaceConfig.Corridor.length).to.equal(true)
            end
        end)
    end)
end
