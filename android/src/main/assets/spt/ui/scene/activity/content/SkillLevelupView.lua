local SkillLevelupView = class(unity.base)

function SkillLevelupView:ctor()
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.scrollView.onRewardBtnClick = function(subID) self:OnRewardBtnClick(subID) end
end

function SkillLevelupView:start()
end

function SkillLevelupView:InitView(skillLevelupModel)
    self.skillLevelupModel = skillLevelupModel
    self:RefreshContent()
end

function SkillLevelupView:RefreshContent()
    self.activityDes.text = self.skillLevelupModel:GetActivityDesc()
    self.timeTxt.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.skillLevelupModel:GetStartTime()), 
                            string.convertSecondToMonth(self.skillLevelupModel:GetEndTime()))
    self.scrollView:InitView(self.skillLevelupModel)
end

function SkillLevelupView:OnEnterScene()
    self.scrollView:OnEnterScene()
end

function SkillLevelupView:OnExitScene()
    self.scrollView:OnExitScene()
end

function SkillLevelupView:OnRewardBtnClick(subID)
    if self.onRewardBtnClick then
        self.onRewardBtnClick(subID)
    end
end

function SkillLevelupView:OnRefresh()

end

return SkillLevelupView