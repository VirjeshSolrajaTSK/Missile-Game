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