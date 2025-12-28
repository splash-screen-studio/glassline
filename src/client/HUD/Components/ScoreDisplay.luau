--!strict
--[[
    HUD/Components/ScoreDisplay.luau
    Displays run points, point rate, and lifetime points stacked vertically
    with visual feedback for accumulation/decumulation
]]

local VERSION = "2.0.0"

local TweenService = game:GetService("TweenService")

local ScoreDisplay = {}

local HUDConstants = require(script.Parent.Parent.HUDConstants)

export type ScoreDisplayWidget = {
    frame: Frame,
    update: (self: ScoreDisplayWidget, runPoints: number, lifetimePoints: number, multiplier: number, pointRate: number?, speed: number?, gameMode: string?, highestZ: number?, isNewGround: boolean?) -> (),
    destroy: (self: ScoreDisplayWidget) -> (),
}

function ScoreDisplay.create(parent: GuiObject): ScoreDisplayWidget
    local C = HUDConstants

    -- Main container (top-right, taller for vertical stack)
    local frame = Instance.new("Frame")
    frame.Name = "ScoreDisplay"
    frame.Size = UDim2.new(0, 180, 0, 160)  -- Taller for new ground indicator
    frame.Position = UDim2.new(1, -180 - C.Spacing.ScreenPadding, 0, C.Spacing.ScreenPadding)
    frame.BackgroundColor3 = C.Colors.Background
    frame.BackgroundTransparency = C.Colors.BackgroundTransparency
    frame.Parent = parent

    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, C.Sizes.CornerRadius)
    corner.Parent = frame

    -- Run points (top, large)
    local runPointsLabel = Instance.new("TextLabel")
    runPointsLabel.Name = "RunPoints"
    runPointsLabel.Size = UDim2.new(1, 0, 0, 40)
    runPointsLabel.Position = UDim2.new(0, 0, 0, 5)
    runPointsLabel.BackgroundTransparency = 1
    runPointsLabel.TextColor3 = C.Colors.TextPrimary
    runPointsLabel.TextSize = 36
    runPointsLabel.FontFace = C.Fonts.Score
    runPointsLabel.Text = "0"
    runPointsLabel.Parent = frame

    -- Point rate indicator (middle, shows +/- rate)
    local rateContainer = Instance.new("Frame")
    rateContainer.Name = "RateContainer"
    rateContainer.Size = UDim2.new(0, 100, 0, 28)
    rateContainer.Position = UDim2.new(0.5, -50, 0, 45)
    rateContainer.BackgroundColor3 = C.Colors.Success
    rateContainer.BackgroundTransparency = 0.3
    rateContainer.Parent = frame

    local rateCorner = Instance.new("UICorner")
    rateCorner.CornerRadius = UDim.new(0, 6)
    rateCorner.Parent = rateContainer

    local rateLabel = Instance.new("TextLabel")
    rateLabel.Name = "RateLabel"
    rateLabel.Size = UDim2.new(1, 0, 1, 0)
    rateLabel.BackgroundTransparency = 1
    rateLabel.TextColor3 = C.Colors.TextPrimary
    rateLabel.TextSize = C.FontSizes.Medium
    rateLabel.FontFace = C.Fonts.Title
    rateLabel.Text = "+0/s"
    rateLabel.Parent = rateContainer

    -- Speed indicator (below rate)
    local speedLabel = Instance.new("TextLabel")
    speedLabel.Name = "SpeedLabel"
    speedLabel.Size = UDim2.new(1, 0, 0, 18)
    speedLabel.Position = UDim2.new(0, 0, 0, 76)
    speedLabel.BackgroundTransparency = 1
    speedLabel.TextColor3 = C.Colors.TextSecondary
    speedLabel.TextSize = C.FontSizes.Small
    speedLabel.FontFace = C.Fonts.Body
    speedLabel.Text = "0 studs/s"
    speedLabel.Parent = frame

    -- Lifetime points
    local lifetimeLabel = Instance.new("TextLabel")
    lifetimeLabel.Name = "LifetimePoints"
    lifetimeLabel.Size = UDim2.new(1, 0, 0, 20)
    lifetimeLabel.Position = UDim2.new(0, 0, 0, 100)
    lifetimeLabel.BackgroundTransparency = 1
    lifetimeLabel.TextColor3 = C.Colors.TextSecondary
    lifetimeLabel.TextSize = C.FontSizes.Small
    lifetimeLabel.FontFace = C.Fonts.Body
    lifetimeLabel.Text = "Lifetime: 0"
    lifetimeLabel.Parent = frame

    -- Highest position indicator
    local highestLabel = Instance.new("TextLabel")
    highestLabel.Name = "HighestPosition"
    highestLabel.Size = UDim2.new(1, 0, 0, 18)
    highestLabel.Position = UDim2.new(0, 0, 0, 120)
    highestLabel.BackgroundTransparency = 1
    highestLabel.TextColor3 = Color3.fromRGB(255, 215, 0)  -- Gold
    highestLabel.TextSize = C.FontSizes.Small
    highestLabel.FontFace = C.Fonts.Body
    highestLabel.Text = "Best: 0m"
    highestLabel.Parent = frame

    -- NEW GROUND indicator (flashes when hitting new territory)
    local newGroundLabel = Instance.new("TextLabel")
    newGroundLabel.Name = "NewGround"
    newGroundLabel.Size = UDim2.new(1, 0, 0, 22)
    newGroundLabel.Position = UDim2.new(0, 0, 0, 138)
    newGroundLabel.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
    newGroundLabel.BackgroundTransparency = 0.2
    newGroundLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    newGroundLabel.TextSize = C.FontSizes.Medium
    newGroundLabel.FontFace = C.Fonts.Title
    newGroundLabel.Text = "NEW GROUND 10x"
    newGroundLabel.Visible = false
    newGroundLabel.Parent = frame

    local newGroundCorner = Instance.new("UICorner")
    newGroundCorner.CornerRadius = UDim.new(0, 4)
    newGroundCorner.Parent = newGroundLabel

    -- Colors for rate feedback
    local positiveColor = Color3.fromRGB(50, 205, 50)   -- Lime green
    local negativeColor = Color3.fromRGB(255, 70, 70)   -- Red
    local neutralColor = C.Colors.Primary

    -- Track last values for smooth animation
    local displayedRunPoints = 0
    local targetRunPoints = 0
    local animating = false

    -- Widget
    local widget: ScoreDisplayWidget = {
        frame = frame,

        update = function(self, runPoints: number, lifetimePoints: number, multiplier: number, pointRate: number?, speed: number?, gameMode: string?, highestZ: number?, isNewGround: boolean?)
            local rate = pointRate or 0
            local currentSpeed = speed or 0
            local mode = gameMode or "ranked"
            local isFunMode = mode == "fun"
            local highest = highestZ or 0
            local onNewGround = isNewGround or false

            -- Update highest position
            highestLabel.Text = "Best: " .. tostring(highest) .. "m"

            -- Show/hide NEW GROUND indicator
            newGroundLabel.Visible = onNewGround and not isFunMode

            if isFunMode then
                -- Fun mode: show mode name instead of points
                runPointsLabel.Text = "FUN MODE"
                rateLabel.Text = "No Points"
                rateContainer.BackgroundColor3 = Color3.fromRGB(255, 150, 50)  -- Orange for fun
                lifetimeLabel.Text = "Practice Run"
            else
                -- Ranked mode: show points
                targetRunPoints = runPoints

                -- Animate run points smoothly
                if not animating and math.abs(targetRunPoints - displayedRunPoints) > 0.5 then
                    animating = true
                    task.spawn(function()
                        while math.abs(targetRunPoints - displayedRunPoints) > 0.5 do
                            local diff = targetRunPoints - displayedRunPoints
                            local step = diff * 0.3  -- Smooth interpolation
                            displayedRunPoints = displayedRunPoints + step
                            runPointsLabel.Text = tostring(math.floor(displayedRunPoints))
                            task.wait(0.03)
                        end
                        displayedRunPoints = targetRunPoints
                        runPointsLabel.Text = tostring(math.floor(targetRunPoints))
                        animating = false
                    end)
                elseif not animating then
                    displayedRunPoints = targetRunPoints
                    runPointsLabel.Text = tostring(math.floor(targetRunPoints))
                end

                -- Update rate display with color feedback
                local rateText: string
                if onNewGround and rate > 0 then
                    rateText = "+" .. tostring(rate) .. "/s (10x!)"
                elseif rate >= 0 then
                    rateText = "+" .. tostring(rate) .. "/s"
                else
                    rateText = tostring(rate) .. "/s"
                end
                rateLabel.Text = rateText

                -- Color based on rate and new ground status
                local targetColor: Color3
                if onNewGround and rate > 0 then
                    targetColor = Color3.fromRGB(0, 255, 100)  -- Bright green for new ground
                elseif rate > 50 then
                    targetColor = positiveColor
                elseif rate < -20 then
                    targetColor = negativeColor
                else
                    targetColor = neutralColor
                end

                -- Tween the color for smooth transitions
                local colorTween = TweenService:Create(
                    rateContainer,
                    TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                    { BackgroundColor3 = targetColor }
                )
                colorTween:Play()

                -- Flash effect on new ground or big rate changes
                if onNewGround and rate > 0 then
                    -- Strong flash for new ground
                    rateContainer.BackgroundTransparency = 0
                    local flashTween = TweenService:Create(
                        rateContainer,
                        TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 0.2 }
                    )
                    flashTween:Play()
                elseif rate > 100 then
                    rateContainer.BackgroundTransparency = 0
                    local flashTween = TweenService:Create(
                        rateContainer,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 0.3 }
                    )
                    flashTween:Play()
                elseif rate < -80 then
                    rateContainer.BackgroundTransparency = 0
                    local flashTween = TweenService:Create(
                        rateContainer,
                        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
                        { BackgroundTransparency = 0.3 }
                    )
                    flashTween:Play()
                end

                -- Update lifetime
                lifetimeLabel.Text = "Lifetime: " .. tostring(math.floor(lifetimePoints))
            end

            -- Always update speed display
            speedLabel.Text = tostring(currentSpeed) .. " studs/s"
        end,

        destroy = function(self)
            self.frame:Destroy()
        end,
    }

    return widget
end

return ScoreDisplay
