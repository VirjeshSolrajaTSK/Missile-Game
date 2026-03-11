-- Init.server.lua
-- Bootstraps core server services on startup.

local TimeService = require(game.ServerScriptService.Services.TimeService)

-- Start core services
TimeService.Start()

return true
