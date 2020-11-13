local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local CardTrainingMedalSelectPageCtrl = class(BaseCtrl)
CardTrainingMedalSelectPageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/MedalSelectPage.prefab"
CardTrainingMedalSelectPageCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function CardTrainingMedalSelectPageCtrl:Init(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.cardTrainingMedalModel = cardTrainingMainModel:GetCardTrainingMedalMode()
    self.view.clickEquip = function(equipMedalModel, isSelectModel) self:OnClickEquip(equipMedalModel, isSelectModel) end
    self.view.helpClick = function() res.PushDialog("ui.controllers.cardTraining.CardTrainingMedalRuleCtrl", self.cardTrainingMedalModel:GetInfoData()) end
    self.view:InitView(self.cardTrainingMedalModel)
end

function CardTrainingMedalSelectPageCtrl:OnClickEquip(equipMedalModel)
    local medalConsum = function()
        clr.coroutine(function()
            local playerMedalsMapModel = PlayerMedalsMapModel.new()

            local pmid = equipMedalModel:GetPmid()

            local pcid = self.cardTrainingMainModel:GetPcid()
            local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
            local subId = self.cardTrainingMainModel:GetSubIdByLevel(trainId)
            local contents = {}
            contents.medal = {pmid}
            local response = req.cardTrainingDemand(pcid, trainId, subId, contents)
            if api.success(response) then
                local data = response.val
                if data.cost and next(data.cost) then
                end
                playerMedalsMapModel:RemoveMedalData(pmid)
                self.cardTrainingMedalModel:ResetMedalList()
                EventSystem.SendEvent("CardTraining_RefreshMainView")
                self.view:Close()
            end
        end)
    end
    local tip = lang.transstr("tips")
    local consumTips = lang.transstr("training_medal_consum_tips", equipMedalModel:GetName())
    DialogManager.ShowConfirmPop(tip, consumTips, medalConsum)
end

return CardTrainingMedalSelectPageCtrl
