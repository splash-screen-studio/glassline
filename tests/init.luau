--!strict
--[[
    Test Runner for Glassline

    Run in Studio command bar:
    require(game.ReplicatedStorage.Tests)()
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")

-- Try to load TestEZ
local TestEZ
local DevPackages = ReplicatedStorage:FindFirstChild("DevPackages")
if DevPackages then
    local testEZModule = DevPackages:FindFirstChild("TestEZ")
    if testEZModule then
        TestEZ = require(testEZModule)
    end
end

if not TestEZ then
    return function()
        warn("[Tests] TestEZ not found. Run 'wally install' first.")
    end
end

-- Find all test files
local function findTests(container: Instance): { ModuleScript }
    local tests = {}

    for _, child in container:GetChildren() do
        if child:IsA("ModuleScript") and child.Name:match("%.spec$") then
            table.insert(tests, child)
        elseif child:IsA("Folder") then
            for _, test in findTests(child) do
                table.insert(tests, test)
            end
        end
    end

    return tests
end

return function()
    print("=" .. string.rep("=", 50))
    print("  GLASSLINE TEST SUITE")
    print("=" .. string.rep("=", 50))

    local tests = findTests(script)
    print("Found", #tests, "test files")

    if #tests == 0 then
        print("No tests found. Create .spec.luau files in tests/")
        return
    end

    TestEZ.TestBootstrap:run(tests)
end
