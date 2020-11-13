local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PasterQueueModel = require("ui.models.paster.PasterQueueModel")
local SkillShowType = require("ui.scene.skill.SkillShowType")
local DialogManager = require("ui.control.manager.DialogManager")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local PasterQueueCtrl = class(BaseCtrl)

PasterQueueCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Paster/PasterQueue.prefab"

PasterQueueCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PasterQueueCtrl:Init(cardModel, selectCardAppendPasterModel)
    self.pasterQueueModel = PasterQueueModel.new(cardModel, selectCardAppendPasterModel)
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.cardModel = cardModel
    self.selectCardAppendPasterModel = selectCardAppendPasterModel
    self.view.clickUse = function(cardAppendPasterModel) self:OnClickUse(cardAppendPasterModel) end
    self.view.clickAppend = function() self:OnClickAppend() end
    self.view.clickCardPaster = function(cardAppendPasterModel) self:OnClickCardPaster(cardAppendPasterModel) end
    self.view.clickSkill = function(cardAppendPasterModel) self:OnClickSkill(cardAppendPasterModel) end
    self.view.onBtnOneClickUnloadClick = function() self:OnBtnOneClickUnloadClick() end
    self.view.onClickActivateExPaster = function() self:OnBtnActivateExPaster() end
end

function PasterQueueCtrl:Refresh()
    PasterQueueCtrl.super.Refresh(self)
    self.view:InitView(self.pasterQueueModel)
end

function PasterQueueCtrl:GetStatusData()
    return self.cardModel, self.selectCardAppendPasterModel
end

function PasterQueueCtrl:OnBtnActivateExPaster()
    local hasMonthPaster = self.cardModel:HasMonthPaster()
    if hasMonthPaster then
        self.view:coroutine(function()
            local pcid = self.cardModel:GetPcid()
            local respone = req.cardLegendActivateExPaster(pcid)
            if api.success(respone) then
                local data = respone.val
                local card = data.card
                local CardsMapModel = self.cardModel:GetCardsMapModel()
                CardsMapModel:ResetCardData(card.pcid, card)
                self.cardModel:InitPasterModel()
                self.view:EventPasterUpdate(self.cardModel)
            end
        end)
    else
        DialogManager.ShowToast(lang.trans("not_find_month_paster"))
    end
end

function PasterQueueCtrl:OnClickUse(cardAppendPasterModel)
    local skillValid = cardAppendPasterModel:GetSkillValid()
    local pasterType = cardAppendPasterModel:GetPasterType()
    local pcid = cardAppendPasterModel:GetPcid()
    local newPtid = cardAppendPasterModel:GetId()
    local oldPtid = self.cardModel:GetUsePasterId()
    local isMonthPaster = cardAppendPasterModel:IsMonthPaster()
    if isMonthPaster and skillValid ~= 1 then
        self.view:coroutine(function()
            local respone = req.pasterUseSkill(pcid, oldPtid, newPtid)
            if api.success(respone) then
                local data = respone.val
                local card = data.card
                local CardsMapModel = self.cardModel:GetCardsMapModel()
                CardsMapModel:ResetCardData(card.pcid, card)
                EventSystem.SendEvent("Paster_Replace", self.cardModel)
            end
        end)
    end
end

function PasterQueueCtrl:OnClickCardPaster(cardAppendPasterModel)
    res.PushDialog("ui.controllers.paster.PasterDetailCtrl", cardAppendPasterModel)
end

function PasterQueueCtrl:OnClickSkill(cardAppendPasterModel)
    if cardAppendPasterModel:GetIsPasterPokedex() then
        return
    end

    if cardAppendPasterModel:IsCompetePaster() then
        return
    end

    self.selectCardAppendPasterModel = cardAppendPasterModel
    local skills = self.cardModel:GetSkills()
    local pasterId = cardAppendPasterModel:GetId()
    local slot
    for i, v in ipairs(skills) do
        if tostring(v.ptid) == tostring(pasterId) then 
            slot = i
            break
        end
    end
    res.PushDialog("ui.controllers.skill.SkillDetailCtrl", slot, self.cardModel, SkillShowType.IsPaster)
end

function PasterQueueCtrl:OnClickAppend()
    res.PushDialog("ui.controllers.paster.PasterAvailableCtrl", self.cardModel)
end

function PasterQueueCtrl:OnEnterScene()
    self.view:EnterScene()
end

function PasterQueueCtrl:OnExitScene()
    self.view:ExitScene()
end

-- 一键卸下
function PasterQueueCtrl:OnBtnOneClickUnloadClick()
    local confirmCallback = function()
        self.view:coroutine(function()
            local pcid = self.cardModel:GetPcid()
            local respone = req.pasterUnEquip(pcid, -1)
            if api.success(respone) then
                local data = respone.val
                local card = data.card
                local pasters = data.paster
                for k, paster in pairs(pasters) do
                    self.cardPastersMapModel:AddPasterData(paster.ptid, paster)
                end
                self.playerCardsMapModel:ResetCardData(card.pcid, card)
                self.cardModel:InitPasterModel()
                self.view:EventPasterUpdate(self.cardModel)
            end
        end)
    end

    local title = lang.trans("auto_unload")
    local content = lang.trans("paster_queue_oneclick_tip")
    DialogManager.ShowConfirmPop(title, content, confirmCallback)
end

return PasterQueueCtrl
