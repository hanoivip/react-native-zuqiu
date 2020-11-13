local BaseCtrl = require("ui.controllers.BaseCtrl")
local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local CoachMainPageModel = require("ui.models.coach.coachMainPage.CoachMainPageModel")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local DialogManager = require("ui.control.manager.DialogManager")

local CoachMainPageCtrl = class(BaseCtrl, "CoachMainPageCtrl")

CoachMainPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/CoachMainPage/CoachMainPage.prefab"

function CoachMainPageCtrl:AheadRequest()
    local response = req.coachBaseInfo()
    if api.success(response) then
        local data = response.val
        if not self.coachMainPageModel then
            self.coachMainPageModel = CoachMainPageModel.new()
        end
        self.coachMainPageModel:InitWithProtocol(data)
    end
end

function CoachMainPageCtrl:ctor()
    CoachMainPageCtrl.super.ctor(self)
end

function CoachMainPageCtrl:Init()
    self.view:RegOnDynamicLoad(function (child)
        local infoBarCtrl = InfoBarCtrl.new(child, self)
        infoBarCtrl:RegOnBtnBack(function ()
            clr.coroutine(function()
                unity.waitForEndOfFrame()
                res.PopSceneImmediate()
            end)
        end)
    end)
end

function CoachMainPageCtrl:Refresh()
    CoachMainPageCtrl.super.Refresh(self)
    if self.coachMainPageModel then
        self.view:InitView(self.coachMainPageModel)
    end
    GuideManager.Show(self)
end

function CoachMainPageCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CoachMainPageCtrl:OnExitScene()
    self.view:OnExitScene()
end

return CoachMainPageCtrl
