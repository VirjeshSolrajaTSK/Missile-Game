local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local TimeService = {}

------------------------------------------------
-- STATE
------------------------------------------------

local timeLeft = GameConfig.RoundTime
local running = false

------------------------------------------------
-- ADD TIME (coins use this)
------------------------------------------------

function TimeService.AddTime(seconds)

	timeLeft = timeLeft + (seconds or 0)

	for _,player in pairs(Players:GetPlayers()) do
		player:SetAttribute("TimeLeft", timeLeft)
	end

end

------------------------------------------------
-- GET TIME
------------------------------------------------

function TimeService.GetTime()
	return timeLeft
end

------------------------------------------------
-- TIMER LOOP
------------------------------------------------

local function runTimer()

	while running and timeLeft > 0 do

		task.wait(1)

		timeLeft -= 1

		-- update HUD
		for _,player in pairs(Players:GetPlayers()) do
			player:SetAttribute("TimeLeft", timeLeft)
		end

	end

	------------------------------------------------
	-- TIME OVER
	------------------------------------------------

	if timeLeft <= 0 then

		for _,player in pairs(Players:GetPlayers()) do

			-- DO NOT kill if player escaped
			if player:GetAttribute("Escaped") then
				continue
			end

			local character = player.Character
			if character then

				local humanoid = character:FindFirstChild("Humanoid")

				if humanoid then
					humanoid.Health = 0
				end

			end

		end

	end

end

------------------------------------------------
-- START TIMER
------------------------------------------------

function TimeService.Start()

	if running then return end

	running = true
	timeLeft = GameConfig.RoundTime

	for _,player in pairs(Players:GetPlayers()) do
		player:SetAttribute("TimeLeft", timeLeft)
	end

	task.spawn(runTimer)

end

------------------------------------------------
-- PLAYER JOIN
------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	player:SetAttribute("TimeLeft", timeLeft)
	player:SetAttribute("Escaped", false)

end)

return TimeService