local Workspace = game:GetService("Workspace")

------------------------------------------------
-- HOUSE BASE
------------------------------------------------

local base = Instance.new("Part")
base.Name = "HouseBase"
base.Size = Vector3.new(60,2,40)

base.Anchored = true
base.Material = Enum.Material.Concrete
base.Color = Color3.fromRGB(220,220,220)

base.Position = Vector3.new(0,1,0)
base.Parent = Workspace

------------------------------------------------
-- WALL FUNCTION
------------------------------------------------

local function createWall(size,pos)

	local wall = Instance.new("Part")

	wall.Size = size
	wall.Anchored = true

	wall.Material = Enum.Material.SmoothPlastic
	wall.Color = Color3.fromRGB(255,255,255)

	wall.Position = pos
	wall.Parent = Workspace

end

------------------------------------------------
-- MAIN WALLS
------------------------------------------------

createWall(Vector3.new(60,16,1),Vector3.new(0,9,-20))
createWall(Vector3.new(1,16,40),Vector3.new(-30,9,0))
createWall(Vector3.new(1,16,40),Vector3.new(30,9,0))

-- front with door gap
createWall(Vector3.new(22,16,1),Vector3.new(-19,9,20))
createWall(Vector3.new(22,16,1),Vector3.new(19,9,20))

------------------------------------------------
-- FRONT PORCH FLOOR
------------------------------------------------

local porch = Instance.new("Part")

porch.Size = Vector3.new(30,1,10)
porch.Anchored = true
porch.Material = Enum.Material.Concrete
porch.Color = Color3.fromRGB(230,230,230)

porch.Position = Vector3.new(0,1,25)
porch.Parent = Workspace

------------------------------------------------
-- WHITE HOUSE COLUMNS
------------------------------------------------

local function createColumn(x)

	local column = Instance.new("Part")

	column.Shape = Enum.PartType.Cylinder
	column.Size = Vector3.new(2,14,2)

	column.Anchored = true
	column.Material = Enum.Material.Marble
	column.Color = Color3.fromRGB(255,255,255)

	column.Position = Vector3.new(x,8,24)

	column.Orientation = Vector3.new(0,0,90)

	column.Parent = Workspace

end

createColumn(-10)
createColumn(-5)
createColumn(0)
createColumn(5)
createColumn(10)

------------------------------------------------
-- ROOF BASE
------------------------------------------------

local roof = Instance.new("Part")

roof.Size = Vector3.new(64,2,44)
roof.Anchored = true

roof.Material = Enum.Material.Slate
roof.Color = Color3.fromRGB(200,200,200)

roof.Position = Vector3.new(0,17,0)

roof.Parent = Workspace

------------------------------------------------
-- TRIANGULAR FRONT ROOF
------------------------------------------------

local frontRoof = Instance.new("WedgePart")

frontRoof.Size = Vector3.new(30,10,10)
frontRoof.Anchored = true

frontRoof.Material = Enum.Material.Slate
frontRoof.Color = Color3.fromRGB(200,200,200)

frontRoof.Position = Vector3.new(0,22,20)

frontRoof.Parent = Workspace

------------------------------------------------
-- WINDOWS
------------------------------------------------

local function createWindow(x,z)

	local window = Instance.new("Part")

	window.Size = Vector3.new(6,5,0.3)
	window.Anchored = true

	window.Material = Enum.Material.Glass
	window.Transparency = 0.3

	window.Position = Vector3.new(x,9,z)

	window.Parent = Workspace

end

createWindow(-15,-19.7)
createWindow(15,-19.7)
createWindow(-15,19.7)
createWindow(15,19.7)

------------------------------------------------
-- SPAWN LOCATION
------------------------------------------------

local spawn = Instance.new("SpawnLocation")

spawn.Size = Vector3.new(6,1,6)
spawn.Position = Vector3.new(0,3,10)

spawn.Anchored = true
spawn.Neutral = true

spawn.Parent = Workspace

------------------------------------------------
-- REQUIRED FOLDERS
------------------------------------------------

local function ensureFolder(name)

	local folder = Workspace:FindFirstChild(name)

	if not folder then
		folder = Instance.new("Folder")
		folder.Name = name
		folder.Parent = Workspace
	end

end

ensureFolder("RoadTiles")
ensureFolder("Coins")
ensureFolder("Missiles")
ensureFolder("Traffic")