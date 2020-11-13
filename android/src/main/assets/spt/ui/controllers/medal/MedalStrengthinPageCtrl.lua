local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MedalStrengthinPageCtrl = class(BaseCtrl)
MedalStrengthinPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Medal/Prefab/MedalStrengthinPage.prefab"
MedalStrengthinPageCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MedalStrengthinPageCtrl:Init()
    self.view.clickUpgrade = function(medalSingleModel) self:OnBtnUpgrade(medalSingleModel) end
    self.view.clickBenedictionUpgrade = function(medalSingleModel) self:OnBtnBenedictionUpgrade(medalSingleModel) end
    self.view.clickBenedictionReplace = function(medalSingleModel) self:OnBtnBenedictionReplace(medalSingleModel) end
    self.view.clickAttributeBreak = function(medalSingleModel) self:OnBtnAttributeBreak(medalSingleModel) end
end

function MedalStrengthinPageCtrl:Refresh(medalSingleModel)
    self.medalSingleModel = medalSingleModel
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:InitView(medalSingleModel)
    MedalStrengthinPageCtrl.super.Refresh(self)
end

function MedalStrengthinPageCtrl:OnBtnUpgrade(medalSingleModel)
    res.PushDialog("ui.controllers.medal.MedalUpgradeCtrl", medalSingleModel, self.playerInfoModel)
    self.view:DisablePage()
end

function MedalStrengthinPageCtrl:OnBtnBenedictionUpgrade(medalSingleModel)
    res.PushDialog("ui.controllers.medal.MedalBenedictionCtrl", medalSingleModel, self.playerInfoModel)
    self.view:DisablePage()
end

function MedalStrengthinPageCtrl:OnBtnBenedictionReplace(medalSingleModel)
    res.PushDialog("ui.controllers.medal.MedalBenedictionReplaceCtrl", medalSingleModel, self.playerInfoModel)
    self.view:DisablePage()
end

function MedalStrengthinPageCtrl:OnBtnAttributeBreak(medalSingleModel)
    res.PushDialog("ui.controllers.medal.MedalAttributeBreakCtrl", medalSingleModel, self.playerInfoModel)
    self.view:DisablePage()
end

function MedalStrengthinPageCtrl:OnEnterScene()
    self.view:EnterScene()
end

function MedalStrengthinPageCtrl:OnExitScene()
    self.view:ExitScene()
end

function MedalStrengthinPageCtrl:GetStatusData()
    return self.medalSingleModel
end

return MedalStrengthinPageCtrl
