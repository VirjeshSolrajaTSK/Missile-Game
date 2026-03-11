-- TileGenerator.server.lua

local Players = game:GetService("Players")

local TILE_LENGTH = 120
local TILES_AHEAD = 12
local ROAD_WIDTH = 60

local lastTileZ = 0

local tilesFolder = workspace:FindFirstChild("RoadTiles") or Instance.new("Folder")
tilesFolder.Name = "RoadTiles"
tilesFolder.Parent = workspace


--------------------------------------------------
-- CREATE TILE
--------------------------------------------------

local function createTile(zPos)

	local tile = Instance.new("Model")
	tile.Name = "Tile"
	tile.Parent = tilesFolder

	-- road
	local road = Instance.new("Part")
	road.Size = Vector3.new(ROAD_WIDTH,1,TILE_LENGTH)
	road.Anchored = true
	road.Material = Enum.Material.Concrete
	road.Color = Color3.fromRGB(30,30,30)
	road.Position = Vector3.new(0,0,zPos)
	road.Parent = tile

	-- ground left
	local groundLeft = Instance.new("Part")
	groundLeft.Size = Vector3.new(250,1,TILE_LENGTH)
	groundLeft.Anchored = true
	groundLeft.Material = Enum.Material.Grass
	groundLeft.Color = Color3.fromRGB(40,110,40)
	groundLeft.Position = Vector3.new(-(ROAD_WIDTH/2+125),-0.5,zPos)
	groundLeft.Parent = tile

	-- ground right
	local groundRight = groundLeft:Clone()
	groundRight.Position = Vector3.new((ROAD_WIDTH/2+125),-0.5,zPos)
	groundRight.Parent = tile

end


--------------------------------------------------
-- INITIAL TILES
--------------------------------------------------

for i = 1,20 do

	createTile(lastTileZ)

	lastTileZ += TILE_LENGTH

end


--------------------------------------------------
-- TILE GENERATION LOOP
--------------------------------------------------

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


	-- cleanup tiles behind player
	for _,tile in pairs(tilesFolder:GetChildren()) do

		local road = tile:FindFirstChildWhichIsA("Part")

		if road and road.Position.Z < root.Position.Z - (TILE_LENGTH*4) then
			tile:Destroy()
		end

	end

end