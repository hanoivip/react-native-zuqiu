local GreenswardStoreType = require("ui.models.greensward.store.GreenswardStoreType")
local AdventureShopCtrl = require("ui.controllers.greensward.dialog.shop.AdventureShopCtrl")
local SellLimitShopCtrl = class(AdventureShopCtrl, "SellLimitShopCtrl")

SellLimitShopCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Shop/SellLimitShopDialog.prefab"

function SellLimitShopCtrl:Init(eventModel)
    SellLimitShopCtrl.super.Init(self)
    self.eventModel = eventModel
    self:SetShopType(GreenswardStoreType.Sell_Limit)
    self.view.runOutOfTime = function() self:RunOutOfTime() end
end

function SellLimitShopCtrl:Refresh(eventModel)
    SellLimitShopCtrl.super.Refresh(self)
    self:InitView(eventModel)
end

function SellLimitShopCtrl:InitView(eventModel)
    self.view:InitView(eventModel)
end

function SellLimitShopCtrl:RunOutOfTime()
    self.eventModel:RunOutOfTime()
end

function SellLimitShopCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function SellLimitShopCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

function SellLimitShopCtrl:GetStatusData()
    return self.eventModel
end

return SellLimitShopCtrl
