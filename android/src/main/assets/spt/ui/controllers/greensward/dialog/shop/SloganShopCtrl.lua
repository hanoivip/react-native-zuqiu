local GreenswardStoreType = require("ui.models.greensward.store.GreenswardStoreType")
local AdventureShopCtrl = require("ui.controllers.greensward.dialog.shop.AdventureShopCtrl")
local SloganShopCtrl = class(AdventureShopCtrl, "SloganShopCtrl")

SloganShopCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Shop/SloganShopDialog.prefab"

function SloganShopCtrl:Init(eventModel)
    SloganShopCtrl.super.Init(self)
    self.eventModel = eventModel
    self:SetShopType(GreenswardStoreType.Slogan)
    self:InitView(eventModel)
end

function SloganShopCtrl:Refresh(eventModel)
    SloganShopCtrl.super.Refresh(self)
    self:InitView(eventModel)
end

function SloganShopCtrl:InitView(eventModel)
    self.view:InitView(eventModel)
end

function SloganShopCtrl:GetStatusData()
    return self.eventModel
end

return SloganShopCtrl
