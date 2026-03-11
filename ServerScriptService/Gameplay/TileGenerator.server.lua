local Players = game:GetService("Players")

local TILE_LENGTH = 120
local TILES_AHEAD = 12
local ROAD_WIDTH = 80

local lastTileZ = 0

local tilesFolder = workspace:WaitForChild("RoadTiles")

------------------------------------------------
-- TREE
------------------------------------------------

local function createTree(x,z,parent)

	local trunk = Instance.new("Part")
	trunk.Size = Vector3.new(2,8,2)
	trunk.Anchored = true
	trunk.Color = Color3.fromRGB(101,67,33)
	trunk.Position = Vector3.new(x,4,z)
	trunk.Parent = parent

	local leaves = Instance.new("Part")
	leaves.Shape = Enum.PartType.Ball
	leaves.Size = Vector3.new(8,8,8)
	leaves.Anchored = true
	leaves.Color = Color3.fromRGB(40,140,60)
	leaves.Position = Vector3.new(x,10,z)
	leaves.Parent = parent

end

------------------------------------------------
-- STREET LIGHT
------------------------------------------------

local function createStreetLight(x,z,parent)

	local pole = Instance.new("Part")
	pole.Size = Vector3.new(1,16,1)
	pole.Anchored = true
	pole.Color = Color3.fromRGB(70,70,70)
	pole.Position = Vector3.new(x,8,z)
	pole.Parent = parent

	local lamp = Instance.new("Part")
	lamp.Size = Vector3.new(2,1,2)
	lamp.Anchored = true
	lamp.Material = Enum.Material.Neon
	lamp.Color = Color3.fromRGB(255,230,180)
	lamp.Position = Vector3.new(x,16,z)
	lamp.Parent = parent

	local light = Instance.new("SpotLight")
	light.Face = Enum.NormalId.Bottom

	light.Angle = 130
	light.Range = 90
	light.Brightness = 12

	light.Color = Color3.fromRGB(255,230,180)

	light.Parent = lamp

end

------------------------------------------------
-- CREATE HIGHWAY TILE
------------------------------------------------

local function createTile(zPos)

	local tile = Instance.new("Model")
	tile.Name = "Tile"
	tile.Parent = tilesFolder

	--------------------------------
	-- ROAD
	--------------------------------

	local road = Instance.new("Part")

	road.Size = Vector3.new(ROAD_WIDTH,1,TILE_LENGTH)
	road.Anchored = true
	road.Material = Enum.Material.Asphalt
	road.Color = Color3.fromRGB(35,35,35)

	road.Position = Vector3.new(0,0,zPos)

	road.Parent = tile

	--------------------------------
	-- LANE MARKINGS
	--------------------------------

	for i = -1,1 do

		local line = Instance.new("Part")

		line.Size = Vector3.new(1,0.05,TILE_LENGTH)
		line.Anchored = true

		line.Material = Enum.Material.SmoothPlastic
		line.Color = Color3.fromRGB(220,220,220)

		line.Position = Vector3.new(i*20,0.55,zPos)

		line.Parent = tile

	end

	--------------------------------
	-- TREES
	--------------------------------

	createTree(-55,zPos,tile)
	createTree(55,zPos,tile)

	--------------------------------
	-- STREET LIGHTS (NEAR ROAD)
	--------------------------------

	createStreetLight(-32,zPos,tile)
	createStreetLight(32,zPos,tile)

end

------------------------------------------------
-- INITIAL TILES
------------------------------------------------

for i = 1,20 do

	createTile(lastTileZ)

	lastTileZ += TILE_LENGTH

end

------------------------------------------------
-- TILE LOOP
------------------------------------------------

while true do

	task.wait(0.2)

	local player = Players:GetPlayers()[1]
	if not player then continue end

	local char = player.Character
	if not char then continue end

	local root = char:FindFirstChild("HumanoidRootPart")
	if not root then continue end

	while lastTileZ < root.Position.Z + (TILE_LENGTH * TILES_AHEAD) do

		createTile(lastTileZ)

		lastTileZ += TILE_LENGTH

	end

	for _,tile in pairs(tilesFolder:GetChildren()) do

		local road = tile:FindFirstChildWhichIsA("Part")

		if road and road.Position.Z < root.Position.Z - (TILE_LENGTH*4) then
			tile:Destroy()
		end

	end

end