-- EscapeSystem.server.lua

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local ESCAPE_DISTANCE = 900

local safeZone = Instance.new("Part")
safeZone.Name = "EscapeZone"
safeZone.Size = Vector3.new(80,10,40)
safeZone.Anchored = true
safeZone.CanCollide = false
safeZone.Material = Enum.Material.Neon
safeZone.Color = Color3.fromRGB(0,255,120)

safeZone.Position = Vector3.new(0,5,ESCAPE_DISTANCE)

safeZone.Parent = workspace


-- portal particles
local particle = Instance.new("ParticleEmitter")
particle.Texture = "rbxassetid://243660364"
particle.Rate = 40
particle.Speed = NumberRange.new(2,5)
particle.Lifetime = NumberRange.new(1,2)
particle.Parent = safeZone


-- portal sound
local portalSound = Instance.new("Sound")
portalSound.SoundId = "rbxassetid://1843520823"
portalSound.Volume = 1
portalSound.Looped = true
portalSound.Parent = safeZone
portalSound:Play()


local function spawnHelicopter()

	local heli = Instance.new("Part")
	heli.Name = "RescueHelicopter"
	heli.Size = Vector3.new(20,6,20)
	heli.Anchored = true
	heli.Color = Color3.fromRGB(0,0,0)

	heli.Position = Vector3.new(0,40,ESCAPE_DISTANCE)

	heli.Parent = workspace

	local heliSound = Instance.new("Sound")
	heliSound.SoundId = "rbxassetid://9125618043"
	heliSound.Looped = true
	heliSound.Volume = 1
	heliSound.Parent = heli
	heliSound:Play()

	local tween = TweenService:Create(
		heli,
		TweenInfo.new(4),
		{Position = Vector3.new(0,15,ESCAPE_DISTANCE)}
	)

	tween:Play()

end


local reachedPlayers = {}

safeZone.Touched:Connect(function(hit)

	local character = hit.Parent
	if not character then return end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	if reachedPlayers[player] then return end
	reachedPlayers[player] = true

	player:SetAttribute("Escaped",true)

	print(player.Name.." ESCAPED!")

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0
	end

	spawnHelicopter()

end)