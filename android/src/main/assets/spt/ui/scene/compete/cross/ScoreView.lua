local ScoreView = class(unity.base)

function ScoreView:ctor()
	self.scollEx = self.___ex.scollEx
	self.btnInfo = self.___ex.btnInfo
	self:RegScrollComp()
    self.btnInfo:regOnButtonClick(function()
        self:OnBtnInfo()
    end)
end

function ScoreView:RegScrollComp()
    self.scollEx:regOnCreateItem(function (scrollSelf, index)
        local obj = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/ScoreGroup.prefab")
        local spt = res.GetLuaScript(obj)
        scrollSelf:resetItem(spt, index)
        return obj, spt
    end)
    
    self.scollEx:regOnResetItem(function (scrollSelf, spt, index)
        spt:InitView(self.matchModel, index)
    end)
end

function ScoreView:InitView(matchModel, index)
	self.matchModel = matchModel
	local teamData = matchModel:GetSortData() or {}
	self.scollEx:refresh(teamData)
end

function ScoreView:OnBtnInfo()
	local crossGroupType = self.matchModel:GetCrossGroupType()
	local teamList = self.matchModel:GetTeamList()
	res.PushScene("ui.controllers.compete.cross.schedule.CompeteScheduleListCtrl", crossGroupType, teamList)
end

return ScoreView