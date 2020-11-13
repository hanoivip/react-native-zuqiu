local ArenaScheduleListView = class(unity.base)

function ArenaScheduleListView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.btnRule = self.___ex.btnRule
    self.menuScript = self.___ex.menuScript
    self.pageArea = self.___ex.pageArea
end

function ArenaScheduleListView:start()
    local menu = self.menuScript.menu
    for key, page in pairs(menu) do
        page:regOnButtonClick(function()
            self:OnBtnMenu(key)
        end)
    end

    self.btnRule:regOnButtonClick(function()
        self:OnBtnRule()
    end)
end

function ArenaScheduleListView:OnBtnRule()
    if self.clickRule then 
        self.clickRule()
    end
end

function ArenaScheduleListView:OnBtnMenu(key)
    if key == self.currentPageTag then return end
    self.currentPageTag = key
    self:OnBtnPage(key)
    self.menuScript:selectMenuItem(key)
end

function ArenaScheduleListView:InitView(pageTag)
    self.currentPageTag = nil
    self.pageTag = pageTag
    self:OnBtnMenu(self.pageTag)
end

function ArenaScheduleListView:OnBtnPage(key)
    if self.clickPage then 
        self.clickPage(key)
    end
end

function ArenaScheduleListView:EnterScene()

end

function ArenaScheduleListView:ExitScene()
end

function ArenaScheduleListView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

return ArenaScheduleListView