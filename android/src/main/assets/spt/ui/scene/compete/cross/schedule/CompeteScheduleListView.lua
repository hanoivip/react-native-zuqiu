local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteScheduleListView = class(unity.base)

function CompeteScheduleListView:ctor()
	self.btnBack = self.___ex.btnBack
    self.pageArea = self.___ex.pageArea
	self.scoreInfoView = self.___ex.scoreInfoView
	self.groupBarInfoView = self.___ex.groupBarInfoView
    self.groupIndex = 1
end

function CompeteScheduleListView:start()
    self.btnBack:regOnButtonClick(function()
        self:OnBtnBack()
    end)

	self.scoreInfoView.onClickCheckFormation = function(id, sid) self:OnClickCheckFormation(id, sid) end
	self.groupBarInfoView.clickVideo = function(vid, version) self:OnClickVideo(vid, version) end
end

function CompeteScheduleListView:OnBtnBack()
    if self.clickBack then 
        self.clickBack()
    end
end

function CompeteScheduleListView:ShowDisplayArea(isVisible)
    GameObjectHelper.FastSetActive(self.pageArea.gameObject, isVisible)
end

function CompeteScheduleListView:InitView(scheduleModel)
    self.groupIndex = scheduleModel:GetMyGroupIndex()
    self.scheduleModel = scheduleModel
    self:ShowTeamInfo(scheduleModel, self.groupIndex)
end

function CompeteScheduleListView:EnterScene()
    EventSystem.AddEvent("CompeteGroupMenuClick", self, self.CompeteGroupMenuClick)
end

function CompeteScheduleListView:ExitScene()
    EventSystem.RemoveEvent("CompeteGroupMenuClick", self, self.CompeteGroupMenuClick)
end

function CompeteScheduleListView:CompeteGroupMenuClick(index)
    self.groupIndex = index
    self:ShowTeamInfo(self.scheduleModel, self.groupIndex)
end

function CompeteScheduleListView:ShowTeamInfo(scheduleModel, groupIndex)
    local scoreData = scheduleModel:GetGroupData(groupIndex)
    self.scoreInfoView:InitView(scoreData, scheduleModel, groupIndex)

    local groupData = scheduleModel:GetScheduleData(groupIndex)
    self.groupBarInfoView:InitView(groupData, scheduleModel, groupIndex)
end

function CompeteScheduleListView:OnClickCheckFormation(id, sid)
    if self.onClickCheckFormation then 
        self.onClickCheckFormation(id, sid)
    end
end

function CompeteScheduleListView:OnClickVideo(vid, version)
    if self.clickVideo then 
        self.clickVideo(vid, version)
    end
end

return CompeteScheduleListView