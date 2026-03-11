-- HUD.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ESCAPE_DISTANCE = 900
local TOTAL_TIME = 30

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.Parent = player:WaitForChild("PlayerGui")

----------------------------------------------------
-- TIMER (RIGHT SIDE)
----------------------------------------------------

local timerLabel = Instance.new("TextLabel")

timerLabel.Size = UDim2.new(0,120,0,40)
timerLabel.Position = UDim2.new(1,-140,0.1,0)

timerLabel.BackgroundTransparency = 0.3
timerLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)

timerLabel.TextColor3 = Color3.fromRGB(255,255,255)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.SourceSansBold

timerLabel.Text = "30"

timerLabel.Parent = screenGui

----------------------------------------------------
-- PROGRESS BAR (TOP)
----------------------------------------------------

local progressBG = Instance.new("Frame")

progressBG.Size = UDim2.new(0.5,0,0,20)
progressBG.Position = UDim2.new(0.25,0,0.02,0)

progressBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
progressBG.BorderSizePixel = 0

progressBG.Parent = screenGui


local progressFill = Instance.new("Frame")

progressFill.Size = UDim2.new(0,0,1,0)
progressFill.BackgroundColor3 = Color3.fromRGB(0,255,120)
progressFill.BorderSizePixel = 0

progressFill.Parent = progressBG

----------------------------------------------------
-- TIMER LOGIC
----------------------------------------------------

local timeLeft = TOTAL_TIME

task.spawn(function()

	while timeLeft > 0 do
		
		timerLabel.Text = tostring(timeLeft)
		
		task.wait(1)
		
		timeLeft -= 1
		
	end

	timerLabel.Text = "0"

end)

----------------------------------------------------
-- PROGRESS LOGIC
----------------------------------------------------

RunService.RenderStepped:Connect(function()

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local distance = root.Position.Z

	local progress = math.clamp(distance / ESCAPE_DISTANCE,0,1)

	progressFill.Size = UDim2.new(progress,0,1,0)

end)