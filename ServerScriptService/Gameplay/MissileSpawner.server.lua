local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local MISSILE_SPEED = GameConfig.Missile.Speed
local SPAWN_DISTANCE = GameConfig.Missile.SpawnDistance
local SPAWN_INTERVAL = GameConfig.Missile.SpawnInterval
local LANES = GameConfig.Missile.Lanes

local missilesFolder = workspace:WaitForChild("Missiles")

--------------------------------------------------
-- WARNING MARKER
--------------------------------------------------

local function createWarning(position)

	local marker = Instance.new("Part")

	marker.Anchored = true
	marker.CanCollide = false

	marker.Size = Vector3.new(8,0.2,8)

	marker.Material = Enum.Material.Neon
	marker.Color = Color3.fromRGB(255,0,0)

	marker.Position = position
	marker.Parent = workspace

	task.delay(1,function()
		if marker then
			marker:Destroy()
		end
	end)

end

--------------------------------------------------
-- EXPLOSION
--------------------------------------------------

local function createExplosion(pos)

	local explosion = Instance.new("Explosion")

	explosion.Position = pos
	explosion.BlastRadius = GameConfig.Missile.ExplosionRadius
	explosion.BlastPressure = 0

	explosion.Parent = workspace

end

--------------------------------------------------
-- MISSILE
--------------------------------------------------

local function spawnMissile(player)

	if player:GetAttribute("Escaped") then return end

	local char = player.Character
	if not char then return end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then return end

	local lane = LANES[math.random(1,#LANES)]

	local spawnPos = Vector3.new(
		lane,
		root.Position.Y + 3,
		root.Position.Z - SPAWN_DISTANCE
	)

	createWarning(spawnPos)

	task.wait(1)

	local missile = Instance.new("Part")

	missile.Name = "Missile"
	missile.Size = Vector3.new(2,2,6)

	missile.Anchored = true
	missile.Material = Enum.Material.Neon
	missile.Color = Color3.fromRGB(255,60,60)

	missile.Position = spawnPos
	missile.Parent = missilesFolder

	local connection

	connection = RunService.Heartbeat:Connect(function(dt)

		if not missile.Parent then
			connection:Disconnect()
			return
		end

		missile.Position += Vector3.new(0,0,MISSILE_SPEED * dt)

		local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not target then return end

		if (missile.Position - target.Position).Magnitude < 6 then

			createExplosion(missile.Position)

			local humanoid = player.Character:FindFirstChild("Humanoid")

			if humanoid then
				humanoid.Health = 0
			end

			missile:Destroy()

		end

	end)

	Debris:AddItem(missile,15)

end

--------------------------------------------------
-- LOOP
--------------------------------------------------

while true do

	task.wait(SPAWN_INTERVAL)

	local player = Players:GetPlayers()[1]

	if player then
		spawnMissile(player)
	end

end