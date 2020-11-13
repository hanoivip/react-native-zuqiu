local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local ScoreRankView = class(unity.base)

function ScoreRankView:ctor()
    self.rank = self.___ex.rank
    self.server = self.___ex.server
    self.teamName = self.___ex.teamName
    self.score = self.___ex.score
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign
end

function ScoreRankView:InitView(order, matchModel, data)
	local teamData = data.teamData
	local scoreData = teamData[order] or {}
	local pid = scoreData.pid
	local rank = scoreData.rank
	local score = scoreData.score or 0
	local teamInfo = matchModel:GetTeamInfo(pid)
	local sid = teamInfo.sid or ""
	local name = teamInfo.name or ""
	self.teamName.text = tostring(name)
	self.server.text = tostring(sid)
	self.score.text = tostring(score)
	self.rank.text = tostring(order)

	local roleId = matchModel:GetPlayerRoleId()
	local color =(roleId == pid) and Color.yellow or Color.white
	self.teamName.color = color
	self.server.color = color
	self.score.color = color
	self.rank.color = color

	self:InitCompeteSign(scoreData.worldTournamentLevel)
end

function ScoreRankView:InitCompeteSign(worldTournamentLevel)
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
end

return ScoreRankView