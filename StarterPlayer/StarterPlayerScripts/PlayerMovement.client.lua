-- PlayerMovement.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local humanoid
local moveLeft = false
local moveRight = false


local function setupCharacter(character)

	humanoid = character:WaitForChild("Humanoid")

	-- runner speed
	humanoid.WalkSpeed = 30

	player:SetAttribute("Escaped", false)

end


if player.Character then
	setupCharacter(player.Character)
end


player.CharacterAdded:Connect(function(character)
	setupCharacter(character)
end)


UserInputService.InputBegan:Connect(function(input, processed)

	if processed then return end

	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
		moveLeft = true
	elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
		moveRight = true
	elseif input.KeyCode == Enum.KeyCode.Space then
		
		if humanoid then
			humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
		end
		
	end

end)


UserInputService.InputEnded:Connect(function(input)

	if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
		moveLeft = false
	elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
		moveRight = false
	end

end)


RunService.RenderStepped:Connect(function()

	if not humanoid then return end

	local lateral = 0

	if moveLeft then
		lateral = -1
	elseif moveRight then
		lateral = 1
	end

	local direction = Vector3.new(lateral,0,1)

	humanoid:Move(direction,false)

end)