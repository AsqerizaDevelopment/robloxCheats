local base = "https://raw.githubusercontent.com/AsqerizaDevelopment/robloxCheats/main/Bloxstrike/src/"

_G.Bloxstrike = {}

_G.Bloxstrike.utils = {
    ESP = loadstring(game:HttpGet(base.."utils/BloxstrikeESP.lua", true))(),
    -- add more utils here later
}

_G.Bloxstrike.UI = loadstring(game:HttpGet(base.."BloxstrikeUI.lua", true))()

return _G.Bloxstrike