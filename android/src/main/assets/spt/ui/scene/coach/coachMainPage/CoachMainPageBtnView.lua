local GameObjectHelper = require("ui.common.GameObjectHelper")
local CoachMainPageConfig = require("ui.scene.coach.coachMainPage.CoachMainPageConfig")

local CoachMainPageBtnView = class(unity.base, "CoachMainPageBtnView")

function CoachMainPageBtnView:ctor()
    self.state = self.___ex.state
    self.btn = self.___ex.btn
    self.btnName = self.___ex.btnName
    self.disable = self.___ex.disable
end

function CoachMainPageBtnView:SetButtonState()
    local openState = CoachMainPageConfig.GetOpenStateByTag(self.btnName)
    GameObjectHelper.FastSetActive(self.state, openState)
    GameObjectHelper.FastSetActive(self.disable, not openState)
end

function CoachMainPageBtnView:regOnButtonClick(func)
    self.btn:regOnButtonClick(function()
        if type(func) == "function" then
            func()
        end
    end)
end

return CoachMainPageBtnView
