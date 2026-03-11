local Players = game:GetService("Players")

local safeZone = workspace:WaitForChild("EscapeZone")

local reachedPlayers = {}

safeZone.Touched:Connect(function(hit)

	local character = hit.Parent
	if not character then return end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	if reachedPlayers[player] then return end
	reachedPlayers[player] = true

	print(player.Name.." reached the safe zone!")

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0
	end

end)