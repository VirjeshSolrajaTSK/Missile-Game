-- SafeZoneSpawner.server.lua

local SAFE_DISTANCE = 1200

local function createSafeZone()

	local safe = Instance.new("Part")

	safe.Name = "SafeZone"
	safe.Size = Vector3.new(60,2,60)
	safe.Anchored = true
	safe.Color = Color3.fromRGB(0,255,0)
    safe.Material = Enum.Material.Neon

	safe.Position = Vector3.new(0,1,SAFE_DISTANCE)

	safe.Parent = workspace

	print("Safe zone created")

end

createSafeZone()