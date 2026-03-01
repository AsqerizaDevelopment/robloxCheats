local Bloxstrike = {}
local baseURL = "https://raw.githubusercontent.com/AsqerizaDevelopment/robloxCheats/main/Bloxstrike/src/utils/"

Bloxstrike.utils = {}
Bloxstrike.utils.ESP = loadstring(game:HttpGet(baseURL .. "BloxstrikeESP.lua"))()
Bloxstrike.UI = loadstring(game:HttpGet(baseURL .. "BloxstrikeUI.lua"))()

return Bloxstrike