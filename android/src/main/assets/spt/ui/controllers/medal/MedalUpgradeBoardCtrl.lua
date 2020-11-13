local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalUpgradeBoardCtrl = class(BaseCtrl)
MedalUpgradeBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalUpgradeBoard.prefab"
MedalUpgradeBoardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalUpgradeBoardCtrl:Init()

end

function MedalUpgradeBoardCtrl:Refresh(medalSingleModel, bChange)
    MedalUpgradeBoardCtrl.super.Refresh(self)
    self.view:InitView(medalSingleModel, bChange)
end

return MedalUpgradeBoardCtrl
