local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamGroupView = class(unity.base)

function TeamGroupView:ctor()
    self.teamView1 = self.___ex.teamView1
    self.teamView2 = self.___ex.teamView2
    self.teamView3 = self.___ex.teamView3
    self.teamView4 = self.___ex.teamView4
	self.icon = self.___ex.icon
	self.teamName = self.___ex.teamName
	self.title = self.___ex.title
	self.animator = self.___ex.animator

	EventSystem.AddEvent("CompeteCrossPageChange", self, self.CompeteCrossPageChange)
end

local TeamGroup = 4
function TeamGroupView:InitView(matchModel, index)
	self.matchModel = matchModel
	local data = matchModel:GetAppointData(index)
	local order = 1
	for i = 1, TeamGroup do
		self["teamView" .. i]:InitView(order, matchModel, data)
		order = order + 4
	end
	self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/Flag" .. index .. ".png")
	self.title.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/Title_" .. index .. ".png")
	self.teamName.text = lang.trans("compete_team_desc" .. index)
end

-- 在每次滑动到界面时播放动画
local TeamGroupIndex = 2
function TeamGroupView:CompeteCrossPageChange(pageIndex, crossGroupType)
	local selfCrossGroupType = self.matchModel:GetCrossGroupType()
	if crossGroupType == selfCrossGroupType and  pageIndex == TeamGroupIndex then 
		self.animator:Play("TeamGroup", 0, 0)
	end
end

function TeamGroupView:onDestroy()
	EventSystem.RemoveEvent("CompeteCrossPageChange", self, self.CompeteCrossPageChange)
end

return TeamGroupView