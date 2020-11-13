local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalBenedictionBoardCtrl = class(BaseCtrl)
MedalBenedictionBoardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalBenedictionBoard.prefab"
MedalBenedictionBoardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalBenedictionBoardCtrl:Init()

end

function MedalBenedictionBoardCtrl:Refresh(medalSingleModel, isBenediction)
    MedalBenedictionBoardCtrl.super.Refresh(self)
    self.view:InitView(medalSingleModel, isBenediction)
end

return MedalBenedictionBoardCtrl
