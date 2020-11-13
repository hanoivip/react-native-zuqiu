local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteOutPageView = class(unity.base)

function CompeteOutPageView:ctor()
    self.scrollView = self.___ex.scrollView
	self.content = self.___ex.content

	self:RegEvent()
end

local MatchScheduleTypeIndex = {
	[1] = MatchScheduleType.ThirtyTwoIntoSixteen, 
	[2] = MatchScheduleType.SixteenIntoEight, 
	[3] = MatchScheduleType.EightIntoFour, 
	[4] = MatchScheduleType.Semi, 
	[5] = MatchScheduleType.Final, 
}
local Teams = 5
function CompeteOutPageView:InitView(matchModel, index)
    self.matchModel = matchModel	
	local playerId = matchModel:GetPlayerRoleId()
	for i = 1, Teams do
		self:ShowSchedule(MatchScheduleTypeIndex[i], self.scrollView.stages[i].teams, matchModel, playerId)
	end
	local last = table.nums(self.scrollView.stages)
	local cupScript = self.scrollView.stages[last].cupScript
	cupScript:InitView(matchModel)
end

function CompeteOutPageView:ShowSchedule(matchScheduleType, scheduleMap, matchModel, playerId)
    local scheduleData = matchModel:GetMatchScheduleData(matchScheduleType) or {}
	local teamList = matchModel:GetTeamList()
    for index, view in pairs(scheduleMap) do
        local teamData = scheduleData and scheduleData[index] or {}
        view:InitView(teamData, teamList, playerId, matchScheduleType, index, matchModel)
    end
end

function CompeteOutPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

-- 共用一个mask减少dc，淘汰赛会在向左移动时 盖住左边界面
function CompeteOutPageView:CompeteCrossKnockoutResetPos()
    self.content.anchoredPosition = Vector2(0, self.content.anchoredPosition.y)
	self.scrollView:ResetLineColor()
end

function CompeteOutPageView:RegEvent()
	EventSystem.AddEvent("CompeteCrossKnockoutResetPos", self, self.CompeteCrossKnockoutResetPos)
end

function CompeteOutPageView:UnRegEvent()
	EventSystem.RemoveEvent("CompeteCrossKnockoutResetPos", self, self.CompeteCrossKnockoutResetPos)
end

function CompeteOutPageView:onDestroy()
	self:UnRegEvent()
end

return CompeteOutPageView