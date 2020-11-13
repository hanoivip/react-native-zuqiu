local GameObjectHelper = require("ui.common.GameObjectHelper")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LoginPlateModel = require("ui.models.loginPlate.LoginPlateModel")
local GiftBoxModel = require("ui.models.store.GiftBoxModel")

local FirstPaySingleCtrl = class(BaseCtrl, 'FirstPaySingleCtrl')
FirstPaySingleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Calendar/FirstPayBoard.prefab"

function FirstPaySingleCtrl:Init()
    self.activityModel = cache.getFirstPayInfo()
    self.model = GiftBoxModel.new()
    self.model:Init(self.activityModel:GetProduct())
    self.view.clickPay = function() self:ClickPay() end
    self.view.initPayButtonState = function(status)
        self:InitPayButtonState(status)
    end
    self.view:InitView(self.activityModel, true)
end

function FirstPaySingleCtrl:InitPayButtonState(status)
    if status == 1 then
        GameObjectHelper.FastSetActive(self.view.finishIcon, true)
        self.view.closeBtn.enable = false
    end
end

--点击首充按钮的回调方法  直接显示详情
function FirstPaySingleCtrl:ClickPay()
    res.PushDialog("ui.controllers.store.GiftBoxItemPopCtrl", self.model)
end

function FirstPaySingleCtrl:Refresh()
end

return FirstPaySingleCtrl