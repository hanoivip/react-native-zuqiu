local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local TeamRankView = class(unity.base)

function TeamRankView:ctor()
    self.team1 = self.___ex.team1
    self.team2 = self.___ex.team2
    self.team3 = self.___ex.team3
    self.team4 = self.___ex.team4
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
end

local TeamGroup = 4
function TeamRankView:InitView(order, matchModel, data)
	local teamData = data.teamData
	for i = 1, TeamGroup do
		local pid = teamData[order + i - 1]
		local teamInfo = matchModel:GetTeamInfo(pid)
		local sid = teamInfo.sid or ""
		local name = teamInfo.name or ""
		self["team" .. i].text = sid .. lang.transstr("server") .. "(" .. name .. ")"

		local roleId = matchModel:GetPlayerRoleId()
		local color = (roleId == pid) and Color.yellow or Color(218 / 255, 218 / 255, 218 / 255, 1)
		self["team" .. i].color = color
        self:InitCompeteSign(teamInfo.worldTournamentLevel, i)
	end
end

function TeamRankView:InitCompeteSign(worldTournamentLevel, i)
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign[tostring(i)].gameObject, true)
            self.competeSign[tostring(i)].overrideSprite = AssetFinder.GetCompeteSign(signData.path)
        else
            GameObjectHelper.FastSetActive(self.competeSign[tostring(i)].gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign[tostring(i)].gameObject, false)
    end
end

return TeamRankView