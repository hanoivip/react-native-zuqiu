local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtDisplayView = class(unity.base)

function CourtDisplayView:ctor()
    self.btnClose = self.___ex.btnClose
    self.pageArea = self.___ex.pageArea
end

function CourtDisplayView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function CourtDisplayView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function CourtDisplayView:InitView(courtBuildModel)
    self:ShowCourt()
end

function CourtDisplayView:EnterScene()
    EventSystem.AddEvent("DisableTechnologyHall", self, self.DisableTechnologyHall)
    EventSystem.AddEvent("ShowTechnologyHall", self, self.ShowTechnologyHall)
end

function CourtDisplayView:ExitScene()
    EventSystem.RemoveEvent("DisableTechnologyHall", self, self.DisableTechnologyHall)
    EventSystem.RemoveEvent("ShowTechnologyHall", self, self.ShowTechnologyHall)
end

function CourtDisplayView:DisableTechnologyHall()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function CourtDisplayView:ShowTechnologyHall()
    GameObjectHelper.FastSetActive(self.gameObject, true)
    self:ShowCourt()
end

function CourtDisplayView:ShowCourt()
    if self.showCourt then 
        self.showCourt()
    end
end

return CourtDisplayView