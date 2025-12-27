--!strict
--[[
    ScoreService Tests
]]

return function()
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    local PlaceConfig = require(Shared.PlaceConfig)

    describe("PlaceConfig.Scoring", function()
        it("should have forward multiplier of 1", function()
            expect(PlaceConfig.Scoring.forwardMultiplier).to.equal(1)
        end)

        it("should have backward multiplier of 2", function()
            expect(PlaceConfig.Scoring.backwardMultiplier).to.equal(2)
        end)

        it("should have points per stud defined", function()
            expect(PlaceConfig.Scoring.pointsPerStud).to.be.a("number")
            expect(PlaceConfig.Scoring.pointsPerStud).to.be.ok()
        end)

        it("should have direction states defined", function()
            expect(PlaceConfig.Scoring.states.FORWARD).to.equal("forward")
            expect(PlaceConfig.Scoring.states.BACKWARD).to.equal("backward")
        end)
    end)

    describe("PlaceConfig.Difficulty", function()
        it("should have speed increase per zone", function()
            expect(PlaceConfig.Difficulty.speedIncreasePerZone).to.be.a("number")
            expect(PlaceConfig.Difficulty.speedIncreasePerZone).to.be.ok()
        end)

        it("should have obstacle frequency settings", function()
            expect(PlaceConfig.Difficulty.obstacleFrequencyBase).to.be.a("number")
            expect(PlaceConfig.Difficulty.obstacleFrequencyMax).to.be.a("number")
            expect(PlaceConfig.Difficulty.obstacleFrequencyMax).never.to.equal(PlaceConfig.Difficulty.obstacleFrequencyBase)
        end)

        it("getSpeedAtPosition should increase with distance", function()
            local speed0 = PlaceConfig.getSpeedAtPosition(0)
            local speed5000 = PlaceConfig.getSpeedAtPosition(5000)

            expect(speed5000).to.be.ok()
            expect(speed5000 > speed0).to.equal(true)
        end)

        it("getDifficultyAtPosition should return 1 at start", function()
            local difficulty = PlaceConfig.getDifficultyAtPosition(0)
            expect(difficulty).to.equal(1)
        end)
    end)

    describe("PlaceConfig.getZoneAtPosition", function()
        it("should return first zone at position 0", function()
            local zone = PlaceConfig.getZoneAtPosition(0)
            expect(zone).to.be.ok()
            expect(zone.startZ).to.equal(0)
        end)

        it("should return nil for position beyond corridor", function()
            local zone = PlaceConfig.getZoneAtPosition(999999)
            expect(zone).to.equal(nil)
        end)

        it("should return correct zone for mid-corridor position", function()
            local zone = PlaceConfig.getZoneAtPosition(1250)
            expect(zone).to.be.ok()
            expect(zone.theme).to.equal("underwater_depths")
        end)
    end)
end
