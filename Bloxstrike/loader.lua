local Bloxstrike = {}
local baseURL = "https://raw.githubusercontent.com/AsqerizaDevelopment/robloxCheats/main/Bloxstrike/src/"

Bloxstrike.utils = {}
Bloxstrike.utils.ESP = loadstring(game:HttpGet(baseURL .. "utils/BloxstrikeESP.lua"))()
Bloxstrike.UI = loadstring(game:HttpGet(baseURL .. "BloxstrikeUI.lua"))()

return Bloxstrike