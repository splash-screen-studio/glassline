--!strict
--[[
    Input/InputController.luau
    Movement, jump, and vehicle controls
]]

local VERSION = "1.0.0"

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local Players = game:GetService("Players")

local InputController = {}

-- Dependencies
local Network: any

-- State
local isMounted = false
local canDismount = true
local dismountCooldown = 0.5

function InputController:init()
    local Shared = ReplicatedStorage:WaitForChild("Shared")
    Network = require(Shared.Network)

    -- Bind jump action (spacebar / screen tap)
    self:bindJumpAction()

    -- Bind dismount action
    self:bindDismountAction()

    -- Listen for vehicle state changes
    Network.Events.VehicleMounted.OnClientEvent:Connect(function(_data)
        isMounted = true
    end)

    Network.Events.VehicleDismounted.OnClientEvent:Connect(function(_data)
        isMounted = false
    end)

    print("[InputController v" .. VERSION .. "] Initialized")
end

function InputController:bindJumpAction()
    -- Jump is handled natively by Roblox, but we can add extra behavior

    UserInputService.JumpRequest:Connect(function()
        -- Could add jump effects here
        local AudioController = _G.AudioController
        if AudioController then
            AudioController:playSFX("jump")
        end
    end)
end

function InputController:bindDismountAction()
    -- Press Q or double-tap to dismount
    ContextActionService:BindAction(
        "Dismount",
        function(_actionName, inputState, _inputObject)
            if inputState == Enum.UserInputState.Begin then
                self:tryDismount()
            end
            return Enum.ContextActionResult.Pass
        end,
        false, -- Don't create touch button (we'll make custom UI)
        Enum.KeyCode.Q
    )

    -- Double-tap for mobile
    local lastTapTime = 0
    UserInputService.TouchTap:Connect(function(_touchPositions, _gameProcessed)
        local now = os.clock()
        if now - lastTapTime < 0.3 then -- Double tap
            self:tryDismount()
        end
        lastTapTime = now
    end)
end

function InputController:tryDismount()
    if not isMounted then return end
    if not canDismount then return end

    canDismount = false
    Network.Events.RequestDismount:FireServer({})

    -- Cooldown
    task.delay(dismountCooldown, function()
        canDismount = true
    end)
end

function InputController:isMounted(): boolean
    return isMounted
end

return InputController
