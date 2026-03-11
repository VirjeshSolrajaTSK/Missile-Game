local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.Parent = player:WaitForChild("PlayerGui")

------------------------------------------------
-- TIMER UI
------------------------------------------------

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

------------------------------------------------
-- UPDATE TIMER
------------------------------------------------

RunService.RenderStepped:Connect(function()

	local timeLeft = player:GetAttribute("TimeLeft")

	if timeLeft then
		timerLabel.Text = tostring(timeLeft)
	end

end)