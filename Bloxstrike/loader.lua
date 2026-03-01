local Bloxstrike = {}
local baseURL = "https://raw.githubusercontent.com/AsqerizaDevelopment/robloxCheats/main/Bloxstrike/src/"

local ESP = loadstring(game:HttpGet(baseURL .. "utils/BloxstrikeESP.lua"))()
local UI = loadstring(game:HttpGet(baseURL .. "BloxstrikeUI.lua"))(ESP)

Bloxstrike.utils = { ESP = ESP }
Bloxstrike.UI = UI

return Bloxstrike