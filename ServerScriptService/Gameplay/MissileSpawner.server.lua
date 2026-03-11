-- MissileSpawner.server.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Debris = game:GetService("Debris")

local MISSILE_SPEED = 120
local SPAWN_DISTANCE = 140
local SPAWN_INTERVAL = 6

local missilesFolder = workspace:FindFirstChild("Missiles") or Instance.new("Folder")
missilesFolder.Name = "Missiles"
missilesFolder.Parent = workspace

-- road lanes
local LANES = {-20,0,20}

--------------------------------------------------
-- EXPLOSION
--------------------------------------------------

local function createExplosion(pos)

	local explosion = Instance.new("Explosion")
	explosion.Position = pos
	explosion.BlastRadius = 10
	explosion.BlastPressure = 0
	explosion.Parent = workspace

end

--------------------------------------------------
-- SPAWN MISSILE
--------------------------------------------------

local function spawnMissile(player)

	local character = player.Character
	if not character then return end

	local root = character:FindFirstChild("HumanoidRootPart")
	if not root then return end

	-- pick random lane
	local lane = LANES[math.random(1,#LANES)]

	local missile = Instance.new("Part")
	missile.Size = Vector3.new(2,2,6)
	missile.Anchored = true
	missile.Material = Enum.Material.Neon
	missile.Color = Color3.fromRGB(255,60,60)
	missile.Name = "Missile"

	missile.Position = Vector3.new(
		lane,
		root.Position.Y + 3,
		root.Position.Z - SPAWN_DISTANCE
	)

	missile.Parent = missilesFolder

	-- fire effect
	local fire = Instance.new("Fire")
	fire.Size = 6
	fire.Heat = 10
	fire.Parent = missile

	local smoke = Instance.new("Smoke")
	smoke.Size = 5
	smoke.RiseVelocity = 8
	smoke.Parent = missile

	local connection
	connection = RunService.Heartbeat:Connect(function(dt)

		if not missile.Parent then
			connection:Disconnect()
			return
		end

		-- missile moves straight forward
		missile.Position = missile.Position + Vector3.new(0,0,MISSILE_SPEED * dt)

		local target = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		if not target then return end

		-- hit detection
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