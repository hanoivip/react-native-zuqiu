local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local ShowGirlModel = require("ui.models.showgirl.ShowGirlModel")

local UnityEngine = clr.UnityEngine

local ShowGirlCtrl = class(BaseCtrl)

ShowGirlCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ShowGirl/ShowGirl.prefab"

ShowGirlCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false
}

function ShowGirlCtrl:Init()
    self.view.chargeBtnClick = function()
        self:ChargeBtnClick()
    end

    self.view.contactBtnClick = function()
        self:ContactBtnClick()
    end
end

function ShowGirlCtrl:Refresh()
    ShowGirlCtrl.super.Refresh(self)
    self.model = ShowGirlModel.GetCache()
    self.view:InitView(self.model)
end

function ShowGirlCtrl:OnEnterScene()
    EventSystem.AddEvent("ShowGirl_UpdateState", self, self.Refresh)
end

function ShowGirlCtrl:OnExitScene()
    EventSystem.RemoveEvent("ShowGirl_UpdateState", self, self.Refresh)
end

function ShowGirlCtrl:ChargeBtnClick()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

function ShowGirlCtrl:ContactBtnClick()
    UnityEngine.Application.OpenURL(self.model.data.GsSetting.url)
end

return ShowGirlCtrl
