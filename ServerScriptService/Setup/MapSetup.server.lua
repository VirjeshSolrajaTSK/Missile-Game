-- MapSetup.server.lua
-- Ensures basic map objects and folders exist for the endless runner.

local Workspace = game:GetService("Workspace")

-- SpawnPlatform
local platform = Workspace:FindFirstChild("SpawnPlatform")
if not platform then
    platform = Instance.new("Part")
    platform.Name = "SpawnPlatform"
    platform.Size = Vector3.new(50, 1, 50)
    platform.Anchored = true
    platform.Position = Vector3.new(0, 0, 0)
    platform.Material = Enum.Material.Asphalt
    platform.Color = Color3.fromRGB(50, 50, 50)
    platform.Parent = Workspace
    print("SpawnPlatform created")
else
    print("SpawnPlatform exists")
end

-- SpawnLocation above the platform
local spawn = Workspace:FindFirstChild("SpawnLocation")
if not spawn then
    spawn = Instance.new("SpawnLocation")
    spawn.Name = "SpawnLocation"
    spawn.Position = Vector3.new(0, 5, 0)
    spawn.Anchored = true
    spawn.Neutral = true
    spawn.Material = Enum.Material.Asphalt
    spawn.Color = Color3.fromRGB(50, 50, 50)
    spawn.Parent = Workspace
    print("SpawnLocation created")
else
    print("SpawnLocation exists")
end

-- Ensure workspace folders
local function ensureFolder(name)
    local f = Workspace:FindFirstChild(name)
    if not f then
        f = Instance.new("Folder")
        f.Name = name
        f.Parent = Workspace
        print(name .. " folder created")
    else
        print(name .. " folder exists")
    end
end

ensureFolder("RoadTiles")
ensureFolder("Coins")
ensureFolder("Missiles")
