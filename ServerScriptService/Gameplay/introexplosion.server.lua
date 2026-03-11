local Players = game:GetService("Players")
local Debris = game:GetService("Debris")

local triggered = false

------------------------------------------------
-- CREATE DEBRIS PIECES
------------------------------------------------

local function createDebris(position)

	for i = 1,40 do

		local part = Instance.new("Part")

		part.Size = Vector3.new(
			math.random(2,6),
			math.random(2,6),
			math.random(2,6)
		)

		part.Position = position + Vector3.new(
			math.random(-10,10),
			math.random(5,20),
			math.random(-10,10)
		)

		part.Material = Enum.Material.Concrete
		part.Color = Color3.fromRGB(200,200,200)

		part.Anchored = false
		part.Parent = workspace

		local force = Instance.new("BodyVelocity")

		force.Velocity = Vector3.new(
			math.random(-80,80),
			math.random(60,120),
			math.random(-80,80)
		)

		force.MaxForce = Vector3.new(1e6,1e6,1e6)
		force.Parent = part

		Debris:AddItem(force,0.3)
		Debris:AddItem(part,8)

	end

end

------------------------------------------------
-- EXPLOSION
------------------------------------------------

local function destroyHouse()

	local house = workspace:FindFirstChild("HouseBase")
	if not house then return end

	local pos = house.Position

	------------------------------------------
	-- HUGE EXPLOSION
	------------------------------------------

	local explosion = Instance.new("Explosion")

	explosion.Position = pos
	explosion.BlastRadius = 80
	explosion.BlastPressure = 800000

	explosion.Parent = workspace

	------------------------------------------
	-- FIREBALL EFFECT
	------------------------------------------

	local fireball = Instance.new("Part")

	fireball.Shape = Enum.PartType.Ball
	fireball.Size = Vector3.new(30,30,30)

	fireball.Anchored = true
	fireball.Material = Enum.Material.Neon
	fireball.Color = Color3.fromRGB(255,120,0)

	fireball.Position = pos + Vector3.new(0,10,0)

	fireball.Parent = workspace

	Debris:AddItem(fireball,0.4)

	------------------------------------------
	-- DEBRIS
	------------------------------------------

	createDebris(pos)

	------------------------------------------
	-- DELETE HOUSE PARTS
	------------------------------------------

	for _,obj in pairs(workspace:GetChildren()) do

		if obj.Name == "HouseBase"
		or obj.Name == "HouseFloor"
		or obj.Name == "Roof"
		or obj.Name == "Wall" then

			obj:Destroy()

		end

	end

end

------------------------------------------------
-- TRIGGER
------------------------------------------------

Players.PlayerAdded:Connect(function(player)

	player.CharacterAdded:Connect(function()

		if triggered then return end
		triggered = true

		task.wait(3)

		destroyHouse()

	end)

end)