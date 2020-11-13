local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local FreshPlayerLevelModel = require("ui.models.freshPlayerLevel.FreshPlayerLevelModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local FreshPlayerLevelBuyCtrl = class(BaseCtrl, "FreshPlayerLevelBuyCtrl")

FreshPlayerLevelBuyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/FreshPlayerLevelBox/FreshPlayerLevelBuy.prefab"

function FreshPlayerLevelBuyCtrl:Init(id, buyBtnClick)
    self.id = id
    self.buyBtnClick = buyBtnClick
end

function FreshPlayerLevelBuyCtrl:Refresh(id, buyBtnClick)
    FreshPlayerLevelBuyCtrl.super.Refresh(self)
    self.view:InitView(id, buyBtnClick)
end

function FreshPlayerLevelBuyCtrl:GetStatusData()
    return self.id, self.buyBtnClick
end

return FreshPlayerLevelBuyCtrl
