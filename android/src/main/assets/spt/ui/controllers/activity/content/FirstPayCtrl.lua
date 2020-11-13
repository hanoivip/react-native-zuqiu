local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local GiftBoxModel = require("ui.models.store.GiftBoxModel")

local FirstPayCtrl = class(ActivityContentBaseCtrl)

function FirstPayCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view.clickPay = function() self:ClickPay() end
    self.view.initPayButtonState = function(status)
        self:InitPayButtonState(status)
    end
    self.view:InitView(self.activityModel)
    self.model = GiftBoxModel.new()
    self.model:Init(self.activityModel:GetProduct())
end

function FirstPayCtrl:InitPayButtonState(status)
    if status == 1 then
        GameObjectHelper.FastSetActive(self.view.finishIcon, true)
    end
end

--点击首充按钮的回调方法  直接显示详情
function FirstPayCtrl:ClickPay()
    res.PushDialog("ui.controllers.store.GiftBoxItemPopCtrl", self.model)
end

function FirstPayCtrl:OnRefresh()
    self.view:OnRefresh()
end

return FirstPayCtrl
