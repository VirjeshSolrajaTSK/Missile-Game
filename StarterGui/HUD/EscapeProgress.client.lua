-- EscapeProgress.client.lua

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local gui = script.Parent

local progressBar = gui:WaitForChild("ProgressBar")
local fill = progressBar:WaitForChild("Fill")

local timerBox = gui:WaitForChild("TimerBox")
local coinsBox = gui:WaitForChild("CoinsBox")

RunService.RenderStepped:Connect(function()

	local progress = player:GetAttribute("Progress") or 0
	fill.Size = UDim2.new(progress,0,1,0)

	local timeLeft = player:GetAttribute("TimeLeft") or 0
	timerBox.Text = tostring(math.floor(timeLeft))

	local coins = player:GetAttribute("Coins") or 0
	coinsBox.Text = "Coins: "..coins

end)