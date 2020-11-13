local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteOutTeamBar = class(unity.base)

function CompeteOutTeamBar:ctor()
    self.bar1 = self.___ex.bar1
    self.bar2 = self.___ex.bar2
    self.lineX = self.___ex.lineX
    self.lineY = self.___ex.lineY
    self.lineImageX = self.___ex.lineImageX
    self.lineImageY = self.___ex.lineImageY
	self.checkImage = self.___ex.checkImage
	self.btnCheck = self.___ex.btnCheck
	self.winnerLine = self.___ex.winnerLine
	self.winnerSign = self.___ex.winnerSign

    self.btnCheck:regOnButtonClick(function()
        self:OnBtnCheck(self.teamData, self.teamList)
    end)
end

-- 第一场先客后主的球队。第二场先主后客的球队。(按照服务器顺序t1为第一支队伍，t2为第二支队伍)
function CompeteOutTeamBar:InitView(teamData, teamList, playerId, matchScheduleType, index, matchModel)
	self.teamData = teamData
	self.teamList = teamList
	local hPid = teamData.player1
	local vPid = teamData.player2
    self.bar1:InitView(hPid, teamList, playerId, matchScheduleType, index)
    self.bar2:InitView(vPid, teamList, playerId, matchScheduleType, index)

	local winnerPid = teamData.winner
	local isWinnerByHome = winnerPid and tobool(winnerPid == hPid)
	local isWinnerByVisit = winnerPid and tobool(winnerPid == vPid)
	local posY = isWinnerByHome and 6.5 or -6.5
	local scaleY = isWinnerByHome and 1 or -1
	self.winnerLine.anchoredPosition = Vector2(self.winnerLine.anchoredPosition.x, posY)
	self.winnerLine.localScale = Vector3(1, scaleY, 1)
	self.winnerSign.localScale = Vector3(1, scaleY, 1)
	GameObjectHelper.FastSetActive(self.winnerLine.gameObject, winnerPid)
end

function CompeteOutTeamBar:OnBtnCheck(teamData, teamList)
	local match = teamData.match
	local pid1 = teamData.player1
	local pid2 = teamData.player2
	if not pid1 or not pid2 or not match then 
		DialogManager.ShowToastByLang("compete_match_desc")
	else
		res.PushDialog("ui.controllers.compete.cross.GoalDisplayCtrl", teamData, teamList)
	end
end

return CompeteOutTeamBar
