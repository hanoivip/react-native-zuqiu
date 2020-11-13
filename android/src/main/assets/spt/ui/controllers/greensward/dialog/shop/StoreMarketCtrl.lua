local GreenswardStoreType = require("ui.models.greensward.store.GreenswardStoreType")
local AdventureShopCtrl = require("ui.controllers.greensward.dialog.shop.AdventureShopCtrl")
local StoreMarketCtrl = class(AdventureShopCtrl, "StoreMarketCtrl")

StoreMarketCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Shop/StoreMarketDialog.prefab"

function StoreMarketCtrl:Init(eventModel)
    StoreMarketCtrl.super.Init(self)
    self.eventModel = eventModel
    self:SetShopType(GreenswardStoreType.Store_Market)
    self.view.runOutOfTime = function() self:RunOutOfTime() end
    self:InitView(eventModel)
end

function StoreMarketCtrl:Refresh(eventModel)
    StoreMarketCtrl.super.Refresh(self)
    self:InitView(eventModel)
end

function StoreMarketCtrl:InitView(eventModel)
    self.view:InitView(eventModel)
end

function StoreMarketCtrl:RunOutOfTime()
    self.eventModel:RunOutOfTime()
end

function StoreMarketCtrl:OnEnterScene()
    if self.view.OnEnterScene then
        self.view:OnEnterScene()
    end
end

function StoreMarketCtrl:OnExitScene()
    if self.view.OnExitScene then
        self.view:OnExitScene()
    end
end

function StoreMarketCtrl:GetStatusData()
    return self.eventModel
end

return StoreMarketCtrl
