local DialogManager = require("ui.control.manager.DialogManager")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterCardChooseCtrl = class(BaseCtrl)
PasterCardChooseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Paster/PasterPlayerChoose.prefab"

PasterCardChooseCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PasterCardChooseCtrl:Init()
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.view.clickConfirm = function(selectCardModel) self:OnClickConfirm(selectCardModel) end
end

function PasterCardChooseCtrl:Refresh(pasterModel, cardsMap)
    PasterCardChooseCtrl.super.Refresh(self)
    self.pasterModel = pasterModel
    self.view:InitView(pasterModel, cardsMap)
end

function PasterCardChooseCtrl:OnEnterScene()
end

function PasterCardChooseCtrl:OnExitScene()
end

function PasterCardChooseCtrl:OnClickConfirm(selectCardModel)
    if selectCardModel then 
        local ptid = self.pasterModel:GetId()
        local ptcid = self.pasterModel:GetPasterId()
        local pcid = selectCardModel:GetPcid()
        local hasSamePaster = selectCardModel:HasSamePaster(ptcid)

        if self.pasterModel:IsCompetePaster() then
            if selectCardModel:GetWorldPasterNum() >= selectCardModel:GetWorldPasterLimit() then
                DialogManager.ShowToast(lang.trans("paster_compete_limit_content"))
                return
            end
        elseif self.pasterModel:IsWeekPaster() then
            if selectCardModel:GetWeekPasterNum() >= selectCardModel:GetWeekPasterLimit() then
                DialogManager.ShowToast(lang.trans("paster_week_limit_content"))
                return
            end
        elseif hasSamePaster then
            DialogManager.ShowToast(lang.trans("paster_same_content"))
            return
        end

        clr.coroutine(function()
            local respone = req.pasterAppend(pcid, ptid)
            if api.success(respone) then
                local data = respone.val
                local card = data.card
                self.cardPastersMapModel:RemovePasterData(ptid)
                local CardsMapModel = selectCardModel:GetCardsMapModel()
                CardsMapModel:ResetCardData(card.pcid, card)
                EventSystem.SendEvent("Paster_AppendToCard", selectCardModel)
                self.view:Close()
            end
        end)
    else
        DialogManager.ShowToast(lang.trans("paster_choose_content"))
    end
end

return PasterCardChooseCtrl