local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local CompeteOutTreeBar = class(unity.base)

function CompeteOutTreeBar:ctor()
    self.logo = self.___ex.logo
    self.nameTxt = self.___ex.name
    self.canvasGroup = self.___ex.canvasGroup
	self.board = self.___ex.board
	self.btnCheckFormation = self.___ex.btnCheckFormation
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign

    self.btnCheckFormation:regOnButtonClick(function()
        self:OnBtnCheck(self.pid, self.sid)
    end)
end

local MatchSchedulePicIndex = {
	[MatchScheduleType.ThirtyTwoIntoSixteen] = 32, 
	[MatchScheduleType.SixteenIntoEight] = 16, 
	[MatchScheduleType.EightIntoFour] = 8, 
	[MatchScheduleType.Semi] = 4, 
	[MatchScheduleType.Final] = 2, 
}
-- 主客两场次
function CompeteOutTreeBar:InitView(pid, teamList, playerId, matchScheduleType, index)
    GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    local id = pid
    local hasMatch = false
    if id then 
        hasMatch = true
        self.logo.enabled = true
		local teamInfo = teamList[id] or {}
        local logoData = teamInfo.logo
        TeamLogoCtrl.BuildTeamLogo(self.logo, logoData)
		local name = teamInfo.name or ""
		local sid = teamInfo.sid or ""
        self.nameTxt.text = name .. "(" .. sid .. lang.transstr("server") .. ")"
        self.nameTxt.color = playerId == id and Color.yellow or Color.white
		self.pid = pid
		self.sid = sid
        self:InitCompeteSign(teamInfo.worldTournamentLevel)
    else
        self.logo.enabled = false
    end

	local picIndex = MatchSchedulePicIndex[matchScheduleType] or 32
	self.board.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/Button" .. picIndex .. ".png")

    --self.canvasGroup.alpha = hasMatch and 1 or 0.6
end

function CompeteOutTreeBar:OnBtnCheck(pid, sid)
	if pid and sid then 
		PlayerDetailCtrl.ShowPlayerDetailView(function() return req.competeFormationDetail(pid, sid, "worldTournament") end, pid, sid)
	end
end

function CompeteOutTreeBar:InitCompeteSign(worldTournamentLevel)
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

return CompeteOutTreeBar
