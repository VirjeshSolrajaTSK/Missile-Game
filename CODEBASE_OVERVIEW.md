# Missile Game Codebase

## Project Structure

```
default.project.json
ReplicatedStorage/
    Modules/
        GameConfig.lua
ServerScriptService/
    Services/
        Init.server.lua
        TimeService.server.lua
    Core/
    Gameplay/
        CoinSpawner.server.lua
        EnvironmentSpawner.server.lua
        EscapeSystem.server.lua
        MissileSpawner.server.lua
        TileGenerator.server.lua
        TrafficSpawner.server.lua
    Setup/
        MapSetup.server.lua
src/
    client/
    server/
    shared/
StarterGui/
    HUD/
        EscapeProgress.client.lua
StarterPlayer/
    StarterPlayerScripts/
        HUD.client.lua
        PlayerMovement.client.lua
Workspace/
    Coins/
    Missiles/
    RoadTiles/
    Traffic/
```

## default.project.json

```json
{
  "name": "RunnerGame",
  "tree": {
    "$className": "DataModel",

    "Workspace": {
      "$path": "Workspace"
    },

    "ServerScriptService": {
      "$path": "ServerScriptService"
    },

    "StarterPlayer": {
      "StarterPlayerScripts": {
        "$path": "StarterPlayer/StarterPlayerScripts"
      }
    },

    "StarterGui": {
      "$path": "StarterGui"
    },

    "ReplicatedStorage": {
      "$path": "ReplicatedStorage"
    }
  }
}
```

## ServerScriptService

### Systems/GameTimer.server.lua

Short description: Tracks round time and exposes a global function to add time.

```lua
-- GameTimer.server.lua

local Players = game:GetService("Players")

local ROUND_TIME = 40
local timeLeft = ROUND_TIME

_G.AddTime = function(seconds)
	timeLeft += seconds
	print("Time extended:", seconds)
end

local function endGame(player)

	local character = player.Character
	if character then
		local humanoid = character:FindFirstChild("Humanoid")
		if humanoid then
			humanoid.Health = 0
		end
	end

end

Players.PlayerAdded:Connect(function(player)

	timeLeft = ROUND_TIME

    while timeLeft > 0 do

        task.wait(1)
        timeLeft -= 1

        print("Time left:", timeLeft)

    end

    endGame(player)

end)

```

### Systems/EscapeDistance.server.lua

Short description: Defines the escape distance and creates a remote event for distance updates.

```lua
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local ESCAPE_DISTANCE = 1200

local event = Instance.new("RemoteEvent")
event.Name = "DistanceUpdate"
event.Parent = ReplicatedStorage

-- expose distance value
_G.EscapeDistance = ESCAPE_DISTANCE
```

### Gameplay/CoinSpawner.server.lua

Short description: Spawns coins in the world and grants extra time when collected.

```lua
-- CoinSpawner.server.lua
-- Spawns coins and handles collection

local coinsFolder = workspace:WaitForChild("Coins")

local function spawnCoin()

    local coin = Instance.new("Part")
    coin.Shape = Enum.PartType.Ball
    coin.Size = Vector3.new(2,2,2)

    coin.Anchored = true
    coin.Color = Color3.fromRGB(255,215,0)

    local randomLane = math.random(-10,10)
    local randomZ = math.random(200,800)

    coin.Position = Vector3.new(randomLane,3,randomZ)

    coin.Parent = coinsFolder

    -- when player touches coin
    coin.Touched:Connect(function(hit)

        local character = hit.Parent
        local player = game.Players:GetPlayerFromCharacter(character)

        if player then

            if _G.AddTime then
            _G.AddTime(1)
            end

            coin:Destroy()

        end

    end)

end

while true do
    task.wait(3)
    spawnCoin()
end
```

### Gameplay/EscapeSystem.server.lua

Short description: Creates a safe zone players can touch to escape; spawns a helicopter.

```lua
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
```

### Gameplay/MissileSpawner.server.lua

Short description: Periodically spawns missiles that track and kill the player on impact.

```lua
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
```

### Gameplay/EnvironmentSpawner.server.lua

Short description: Generates trees and buildings alongside the road as the player progresses.

```lua
local Players = game:GetService("Players")

local LEFT_OFFSET = -60
local RIGHT_OFFSET = 60

local lastSpawn = 0

local function createTree(x,z)

    local trunk = Instance.new("Part")
    trunk.Size = Vector3.new(2,8,2)
    trunk.Anchored = true
    trunk.Color = Color3.fromRGB(101,67,33)
    trunk.Position = Vector3.new(x,4,z)
    trunk.Parent = workspace

    local leaves = Instance.new("Part")
    leaves.Shape = Enum.PartType.Ball
    leaves.Size = Vector3.new(8,8,8)
    leaves.Anchored = true
    leaves.Color = Color3.fromRGB(34,139,34)
    leaves.Position = Vector3.new(x,10,z)
    leaves.Parent = workspace

end


local function createBuilding(x,z)

    local building = Instance.new("Part")

    local height = math.random(40,80)

    building.Size = Vector3.new(20,height,20)
    building.Anchored = true
    building.Color = Color3.fromRGB(
        math.random(80,160),
        math.random(80,160),
        math.random(80,160)
    )

    building.Position = Vector3.new(x,height/2,z)
    building.Parent = workspace

end


while true do

    task.wait(2)

    local player = Players:GetPlayers()[1]
    if not player then continue end

    local char = player.Character
    if not char then continue end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then continue end

    local z = root.Position.Z + 80

    if z - lastSpawn > 80 then

        lastSpawn = z

        if math.random() > 0.5 then
            createTree(LEFT_OFFSET,z)
        else
            createBuilding(LEFT_OFFSET,z)
        end

        if math.random() > 0.5 then
            createTree(RIGHT_OFFSET,z)
        else
            createBuilding(RIGHT_OFFSET,z)
        end

    end

end
```

### Gameplay/TrafficSpawner.server.lua

Short description: Spawns moving cars in the world to simulate traffic.

```lua
local RunService = game:GetService("RunService")

local trafficFolder = Instance.new("Folder")
trafficFolder.Name = "Traffic"
trafficFolder.Parent = workspace


while true do
    
    task.wait(4)

    local car = Instance.new("Part")
    car.Size = Vector3.new(6,3,10)
    car.Anchored = true
    car.Color = Color3.fromRGB(200,0,0)

    car.Position = Vector3.new(20,3,-150)

    car.Parent = trafficFolder

    RunService.Heartbeat:Connect(function(dt)
        
        if car.Parent then
            car.Position = car.Position + Vector3.new(0,0,60*dt)
        end
        
    end)

end
```

### Gameplay/SafeZoneSystem.server.lua

Short description: Handles logic when players reach the EscapeZone (stops their movement).

```lua
local Players = game:GetService("Players")

local safeZone = workspace:WaitForChild("EscapeZone")

local reachedPlayers = {}

safeZone.Touched:Connect(function(hit)

    local character = hit.Parent
    if not character then return end

    local player = Players:GetPlayerFromCharacter(character)
    if not player then return end

    if reachedPlayers[player] then return end
    reachedPlayers[player] = true

    print(player.Name.." reached the safe zone!")

    local humanoid = character:FindFirstChild("Humanoid")

    if humanoid then
        humanoid.WalkSpeed = 0
    end

end)
```

### Gameplay/TileGenerator.server.lua

Short description: Generates road tiles ahead of the player and cleans up old ones.

```lua
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
```

### Setup/MapSetup.server.lua

Short description: Ensures basic workspace objects and folders exist (spawn platform, folders).

```lua
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
```

## ReplicatedStorage

### Modules

Short description: No Lua module scripts present; `ReplicatedStorage/Modules` contains a .gitkeep placeholder.

```
ReplicatedStorage/Modules/.gitkeep
```

## StarterPlayerScripts

### PlayerMovement.client.lua

Short description: Handles local player movement (left/right lanes and jumping), and sets runner speed.

```lua
-- PlayerMovement.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

local humanoid
local moveLeft = false
local moveRight = false


local function setupCharacter(character)

    humanoid = character:WaitForChild("Humanoid")

    -- runner speed
    humanoid.WalkSpeed = 30

    player:SetAttribute("Escaped", false)

end


if player.Character then
    setupCharacter(player.Character)
end


player.CharacterAdded:Connect(function(character)
    setupCharacter(character)
end)


UserInputService.InputBegan:Connect(function(input, processed)

    if processed then return end

    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
        moveLeft = true
    elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
        moveRight = true
    elseif input.KeyCode == Enum.KeyCode.Space then
        
        if humanoid then
            humanoid:ChangeState(Enum.HumanoidStateType.Jumping)
        end
        
    end

end)


UserInputService.InputEnded:Connect(function(input)

    if input.KeyCode == Enum.KeyCode.A or input.KeyCode == Enum.KeyCode.Left then
        moveLeft = false
    elseif input.KeyCode == Enum.KeyCode.D or input.KeyCode == Enum.KeyCode.Right then
        moveRight = false
    end

end)


RunService.RenderStepped:Connect(function()

    if not humanoid then return end

    local lateral = 0

    if moveLeft then
        lateral = -1
    elseif moveRight then
        lateral = 1
    end

    local direction = Vector3.new(lateral,0,1)

    humanoid:Move(direction,false)

end)
```

### HUD.client.lua

Short description: Creates a simple HUD with a timer and progress bar showing distance to escape.

```lua
-- HUD.client.lua

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer

local ESCAPE_DISTANCE = 900
local TOTAL_TIME = 30

local screenGui = Instance.new("ScreenGui")
screenGui.Name = "HUD"
screenGui.Parent = player:WaitForChild("PlayerGui")

----------------------------------------------------
-- TIMER (RIGHT SIDE)
----------------------------------------------------

local timerLabel = Instance.new("TextLabel")

timerLabel.Size = UDim2.new(0,120,0,40)
timerLabel.Position = UDim2.new(1,-140,0.1,0)

timerLabel.BackgroundTransparency = 0.3
timerLabel.BackgroundColor3 = Color3.fromRGB(0,0,0)

timerLabel.TextColor3 = Color3.fromRGB(255,255,255)
timerLabel.TextScaled = true
timerLabel.Font = Enum.Font.SourceSansBold

timerLabel.Text = "30"

timerLabel.Parent = screenGui

----------------------------------------------------
-- PROGRESS BAR (TOP)
----------------------------------------------------

local progressBG = Instance.new("Frame")

progressBG.Size = UDim2.new(0.5,0,0,20)
progressBG.Position = UDim2.new(0.25,0,0.02,0)

progressBG.BackgroundColor3 = Color3.fromRGB(60,60,60)
progressBG.BorderSizePixel = 0

progressBG.Parent = screenGui


local progressFill = Instance.new("Frame")

progressFill.Size = UDim2.new(0,0,1,0)
progressFill.BackgroundColor3 = Color3.fromRGB(0,255,120)
progressFill.BorderSizePixel = 0

progressFill.Parent = progressBG

----------------------------------------------------
-- TIMER LOGIC
----------------------------------------------------

local timeLeft = TOTAL_TIME

task.spawn(function()

    while timeLeft > 0 do
        
        timerLabel.Text = tostring(timeLeft)
        
        task.wait(1)
        
        timeLeft -= 1
        
    end

    timerLabel.Text = "0"

end)

----------------------------------------------------
-- PROGRESS LOGIC
----------------------------------------------------

RunService.RenderStepped:Connect(function()

    local char = player.Character
    if not char then return end

    local root = char:FindFirstChild("HumanoidRootPart")
    if not root then return end

    local distance = root.Position.Z

    local progress = math.clamp(distance / ESCAPE_DISTANCE,0,1)

    progressFill.Size = UDim2.new(progress,0,1,0)

end)
```

## StarterGui

### HUD/EscapeProgress.client.lua

Short description: Updates a UI progress bar, timer, and coin count from player attributes.

```lua
-- EscapeProgress.client.lua

local player = game.Players.LocalPlayer
local RunService = game:GetService("RunService")

local gui = script.Parent

local progressBar = gui:WaitForChild("ProgressBar")
local fill = progressBar:WaitForChild("Fill")

local timerBox = gui:WaitForChild("TimerBox")
local coinsBox = gui:WaitForChild("CoinsBox")

RunService.RenderStepped:Connect(function()

    local progress = player:GetAttribute("Progress") or 0
    fill.Size = UDim2.new(progress,0,1,0)

    local timeLeft = player:GetAttribute("TimeLeft") or 0
    timerBox.Text = tostring(math.floor(timeLeft))

    local coins = player:GetAttribute("Coins") or 0
    coinsBox.Text = "Coins: "..coins

end)
```

## Workspace Scripts

Short description: Workspace currently contains placeholder folders for `Coins`, `Missiles`, and `RoadTiles` (no Lua scripts present).

```
Workspace/Coins/.gitkeep
Workspace/Missiles/.gitkeep
Workspace/RoadTiles/.gitkeep
```

---

If you'd like, I can also:

- Add links to individual files in this document.
- Run a quick search for TODOs or comments to summarize areas for improvement.

## Refactor: New Modules & Services

The codebase was refactored to remove global state and make systems multiplayer-safe. New files added:

### ReplicatedStorage/Modules/GameConfig.lua

Short description: Centralized gameplay constants used by server services and systems.

```lua
local GameConfig = {}

GameConfig.RoundTime = 30
GameConfig.EscapeDistance = 900

GameConfig.Missile = {
    Speed = 120,
    SpawnDistance = 140,
    SpawnInterval = 6,
    Lanes = {-20,0,20},
    ExplosionRadius = 10
}

GameConfig.Coin = {
    SpawnInterval = 3,
    TimeReward = 1
}

return GameConfig
```

### ServerScriptService/Services/TimeService.server.lua

Short description: Server-side TimeService that manages the round timer and exposes `AddTime`, `GetTime`, and `Start`.

```lua
-- TimeService.server.lua
-- Centralized round timer service. Replace previous _G-based timer.

local Players = game:GetService("Players")
local GameConfig = require(game.ReplicatedStorage.Modules.GameConfig)

local TimeService = {}

local timeLeft = GameConfig.RoundTime
local started = false

function TimeService.AddTime(seconds)
    timeLeft = timeLeft + (seconds or 0)
    return timeLeft
end

function TimeService.GetTime()
    return timeLeft
end

function TimeService.Start()
    if started then return end
    started = true
    timeLeft = GameConfig.RoundTime

    spawn(function()
        while timeLeft > 0 do
            task.wait(1)
            timeLeft = timeLeft - 1
        end

        -- time expired: eliminate all players' humanoids
        for _, player in pairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        end
    end)
end

-- TimeService publishes `TimeLeft` to each player's attributes every second
function TimeService.AddTime(seconds)
    timeLeft = timeLeft + (seconds or 0)
    -- immediately publish updated time to players
    for _, player in pairs(Players:GetPlayers()) do
        player:SetAttribute("TimeLeft", timeLeft)
    end
    return timeLeft
end

function TimeService.GetTime()
    return timeLeft
end

local function broadcastTimeLoop()
    while started and timeLeft > 0 do
        task.wait(1)
        timeLeft = timeLeft - 1
        for _, player in pairs(Players:GetPlayers()) do
            player:SetAttribute("TimeLeft", timeLeft)
        end
    end
    if timeLeft <= 0 then
        for _, player in pairs(Players:GetPlayers()) do
            local char = player.Character
            if char then
                local humanoid = char:FindFirstChild("Humanoid")
                if humanoid then
                    humanoid.Health = 0
                end
            end
        end
    end
end

function TimeService.Start()
    if started then return end
    started = true
    timeLeft = GameConfig.RoundTime
    for _, player in pairs(Players:GetPlayers()) do
        player:SetAttribute("TimeLeft", timeLeft)
    end
    spawn(broadcastTimeLoop)
end

return TimeService
```

### ServerScriptService/Services/Init.server.lua

Short description: Bootstrap that starts core server services on load.

```lua
-- Init.server.lua
-- Bootstraps core server services on startup.

local TimeService = require(game.ServerScriptService.Services.TimeService)

-- Start core services
TimeService.Start()

return true
```

### Deleted (replaced) files

- `ServerScriptService/Systems/GameTimer.server.lua` — removed; replaced by `TimeService`.
- `ServerScriptService/Systems/EscapeDistance.server.lua` — removed; distance moved into `GameConfig`.

### Notes

- `CoinSpawner.server.lua`, `MissileSpawner.server.lua`, `EnvironmentSpawner.server.lua`, and `TileGenerator.server.lua` were updated to require `GameConfig` and `TimeService`, remove `_G` usage, and iterate over `Players:GetPlayers()` so they work correctly in multiplayer.
- A bootstrap service was added (`Init.server.lua`) so services can be started centrally. If you prefer a different bootstrap location or explicit ordering, I can adjust.

