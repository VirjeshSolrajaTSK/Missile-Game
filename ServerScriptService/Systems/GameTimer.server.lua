-- GameTimer.server.lua

local Players = game:GetService("Players")

local ROUND_TIME = 40
local timeLeft = ROUND_TIME

_G.AddTime = function(seconds)
	timeLeft += seconds
	print("Time extended:", seconds)
end

local function endGame(player)

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end

end

Players.PlayerAdded:Connect(function(player)

	timeLeft = ROUND_TIME

	while timeLeft > 0 do

		task.wait(1)
		timeLeft -= 1

		print("Time left:", timeLeft)

	end

	endGame(player)

end)