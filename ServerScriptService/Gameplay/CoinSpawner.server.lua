local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TimeService = require(game.ServerScriptService.Services.TimeService)
local GameConfig = require(ReplicatedStorage.Modules.GameConfig)

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

    coin.Touched:Connect(function(hit)

        local character = hit.Parent
        local player = game.Players:GetPlayerFromCharacter(character)

        if player then

            TimeService.AddTime(GameConfig.Coin.TimeReward)

            coin:Destroy()

        end

    end)

end

while true do
    task.wait(GameConfig.Coin.SpawnInterval)
    spawnCoin()
end