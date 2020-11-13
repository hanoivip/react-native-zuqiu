local ActivityParentView = class(unity.base)

function ActivityParentView:ctor()
end

function ActivityParentView:OnEnterScene()
    if type(self.RefreshContent) == "function" then
        self:RefreshContent()
    end
    EventSystem.AddEvent("Money_Tag_Changed", self, self.RefreshRewardContent)
end

function ActivityParentView:OnExitScene()
    EventSystem.RemoveEvent("Money_Tag_Changed", self, self.RefreshRewardContent)
end

function ActivityParentView:ResetCousume()
    if type(self.resetCousume) == "function" then
        if type(self.RefreshContent) == "function" then
            self.resetCousume(function() self:RefreshContent() end)
        else
            self.resetCousume(nil)
        end
    end
end

return ActivityParentView