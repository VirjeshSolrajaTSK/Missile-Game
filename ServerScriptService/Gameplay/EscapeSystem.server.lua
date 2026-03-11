local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

local ESCAPE_DISTANCE = GameConfig.EscapeDistance

------------------------------------------------
-- CAMP BASE
------------------------------------------------

local base = Instance.new("Part")

base.Name = "SafeZone"
base.Size = Vector3.new(120,1,80)

base.Anchored = true
base.Material = Enum.Material.Concrete
base.Color = Color3.fromRGB(70,70,70)

base.Position = Vector3.new(0,0.5,ESCAPE_DISTANCE)

base.Parent = workspace

------------------------------------------------
-- TENT
------------------------------------------------

local tent = Instance.new("WedgePart")

tent.Size = Vector3.new(40,20,30)
tent.Anchored = true
tent.Material = Enum.Material.Fabric
tent.Color = Color3.fromRGB(60,80,60)

tent.Position = Vector3.new(0,10,ESCAPE_DISTANCE)

tent.Parent = workspace

------------------------------------------------
-- TOUCH DETECTION
------------------------------------------------

local reachedPlayers = {}

base.Touched:Connect(function(hit)

	local character = hit.Parent
	if not character then return end

	local player = Players:GetPlayerFromCharacter(character)
	if not player then return end

	if reachedPlayers[player] then return end
	reachedPlayers[player] = true

	player:SetAttribute("Escaped", true)

	print("MISSION COMPLETE:",player.Name)

	------------------------------------------------
	-- STOP MISSILES
	------------------------------------------------

	local missiles = workspace:FindFirstChild("Missiles")

	if missiles then
		for _,m in pairs(missiles:GetChildren()) do
			m:Destroy()
		end
	end

	------------------------------------------------
	-- WALK PLAYER INTO CAMP
	------------------------------------------------

	local root = character:FindFirstChild("HumanoidRootPart")

	if root then

		local goal = {}
		goal.Position = Vector3.new(0,3,ESCAPE_DISTANCE+20)

		local tween = TweenService:Create(
			root,
			TweenInfo.new(3),
			goal
		)

		tween:Play()

	end

	------------------------------------------------
	-- FREEZE PLAYER
	------------------------------------------------

	local humanoid = character:FindFirstChild("Humanoid")

	if humanoid then
		humanoid.WalkSpeed = 0
	end

	------------------------------------------------
	-- SHOW GAME FINISHED
	------------------------------------------------

	player:SetAttribute("GameFinished",true)

end)

------------------------------------------------
-- CAMP FLOODLIGHTS
------------------------------------------------

for i = -2,2 do

	local pole = Instance.new("Part")
	pole.Size = Vector3.new(1,18,1)
	pole.Anchored = true
	pole.Material = Enum.Material.Metal
	pole.Color = Color3.fromRGB(40,40,40)

	pole.Position = Vector3.new(i*25,9,ESCAPE_DISTANCE+10)
	pole.Parent = workspace

	local light = Instance.new("SpotLight")

	light.Brightness = 10
	light.Range = 80
	light.Angle = 120

	light.Color = Color3.fromRGB(255,255,220)

	light.Parent = pole

end