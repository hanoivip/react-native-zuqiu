local DialogManager = require("ui.control.manager.DialogManager")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterAvailableCtrl = class(BaseCtrl)
PasterAvailableCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Paster/PasterAvailable.prefab"
PasterAvailableCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PasterAvailableCtrl:Init(cardModel)
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.cardModel = cardModel
    self.view.clickUse = function(cardPasterModel) self:OnClickUse(cardPasterModel) end
end

function PasterAvailableCtrl:Refresh()
    PasterAvailableCtrl.super.Refresh(self)
    self.view:InitView(self.cardModel)
end

function PasterAvailableCtrl:GetStatusData()
    return self.cardModel
end

function PasterAvailableCtrl:OnClickUse(cardPasterModel)
    local ptid = cardPasterModel:GetId()
    local ptcid = cardPasterModel:GetPasterId()
    local pcid = self.cardModel:GetPcid()
    local hasSamePaster = self.cardModel:HasSamePaster(ptcid)
    if cardPasterModel:IsCompetePaster() then
        if self.cardModel:GetWorldPasterNum() >= self.cardModel:GetWorldPasterLimit() then
            DialogManager.ShowToast(lang.trans("paster_compete_limit_content"))
            return
        end
    elseif hasSamePaster then
        DialogManager.ShowToast(lang.trans("paster_same_content"))
        return
    elseif cardPasterModel:IsWeekPaster() then
        if self.cardModel:GetWeekPasterNum() >= self.cardModel:GetWeekPasterLimit() then
            DialogManager.ShowToast(lang.trans("paster_week_limit_content"))
            return
        end
    end

    clr.coroutine(function()
        local respone = req.pasterAppend(pcid, ptid)
        if api.success(respone) then
            local data = respone.val
            local card = data.card
            self.cardPastersMapModel:RemovePasterData(ptid)
            local CardsMapModel = self.cardModel:GetCardsMapModel()
            CardsMapModel:ResetCardData(card.pcid, card)
            EventSystem.SendEvent("Paster_AppendToCard", self.cardModel)
        end
    end)
end

function PasterAvailableCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PasterAvailableCtrl:OnExitScene()
    self.view:ExitScene()
end

return PasterAvailableCtrl