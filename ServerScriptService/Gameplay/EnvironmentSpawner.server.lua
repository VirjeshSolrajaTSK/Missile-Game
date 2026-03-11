local Players = game:GetService("Players")

local LEFT_OFFSET = -60
local RIGHT_OFFSET = 60

local lastSpawn = 0

local function createTree(x,z)

	local trunk = Instance.new("Part")
	trunk.Size = Vector3.new(2,8,2)
	trunk.Anchored = true
	trunk.Color = Color3.fromRGB(101,67,33)
	trunk.Position = Vector3.new(x,4,z)
	trunk.Parent = workspace

	local leaves = Instance.new("Part")
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(8,8,8)
	leaves.Anchored = true
	leaves.Color = Color3.fromRGB(34,139,34)
	leaves.Position = Vector3.new(x,10,z)
	leaves.Parent = workspace

end


local function createBuilding(x,z)

	local building = Instance.new("Part")

	local height = math.random(40,80)

	building.Size = Vector3.new(20,height,20)
	building.Anchored = true
	building.Color = Color3.fromRGB(
		math.random(80,160),
		math.random(80,160),
		math.random(80,160)
	)

	building.Position = Vector3.new(x,height/2,z)
	building.Parent = workspace

end


while true do

	task.wait(2)

	local player = Players:GetPlayers()[1]
	if not player then continue end

	local char = player.Character
	if not char then continue end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then continue end

	local z = root.Position.Z + 80

	if z - lastSpawn > 80 then

		lastSpawn = z

		if math.random() > 0.5 then
			createTree(LEFT_OFFSET,z)
		else
			createBuilding(LEFT_OFFSET,z)
		end

		if math.random() > 0.5 then
			createTree(RIGHT_OFFSET,z)
		else
			createBuilding(RIGHT_OFFSET,z)
		end

	end

end