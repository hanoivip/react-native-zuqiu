local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local TechnologyHallPageType = require("ui.scene.court.technologyHall.TechnologyHallPageType")
local TechnologyHallView = class(unity.base)

function TechnologyHallView:ctor()
    self.btnClose = self.___ex.btnClose
    self.pageArea = self.___ex.pageArea
    self.menuScript = self.___ex.menuScript
end

function TechnologyHallView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)

    local menu = self.menuScript.menu
    for key, page in pairs(menu) do
        page:regOnButtonClick(function()
            self:OnBtnMenu(key)
        end)
    end

    self.currentPageTag = TechnologyHallPageType.CourtPage
end

function TechnologyHallView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            EventSystem.SendEvent("BuildDialogClose", CourtBuildType.TechnologyHallBuild)
            self.closeDialog()
        end
    end)
end

function TechnologyHallView:InitView(courtBuildModel)
    self:OnBtnPage(self.currentPageTag)
    self.menuScript:selectMenuItem(self.currentPageTag)
end

function TechnologyHallView:EnterScene()
    EventSystem.AddEvent("DisableTechnologyHall", self, self.DisableTechnologyHall)
    EventSystem.AddEvent("ShowTechnologyHall", self, self.ShowTechnologyHall)
end

function TechnologyHallView:ExitScene()
    EventSystem.RemoveEvent("DisableTechnologyHall", self, self.DisableTechnologyHall)
    EventSystem.RemoveEvent("ShowTechnologyHall", self, self.ShowTechnologyHall)
end

function TechnologyHallView:DisableTechnologyHall()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function TechnologyHallView:ShowTechnologyHall()
    GameObjectHelper.FastSetActive(self.gameObject, true)
    self:OnBtnPage(self.currentPageTag)
end

function TechnologyHallView:OnBtnMenu(key)
    if key == self.currentPageTag then return end
    self:OnBtnPage(key)
end

function TechnologyHallView:OnBtnPage(key)
    self.currentPageTag = key
    if self.clickPage then 
        self.clickPage(key)
    end
end

return TechnologyHallView