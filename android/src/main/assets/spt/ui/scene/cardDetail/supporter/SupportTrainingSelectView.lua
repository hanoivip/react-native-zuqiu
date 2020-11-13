local CardHelper = require("ui.scene.cardDetail.CardHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local SupportTrainingSelectView = class(unity.base, "SupportTrainingSelectView")

function SupportTrainingSelectView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.scrollSpt = self.___ex.scrollSpt
    self.cardParentTrans = self.___ex.cardParentTrans
    self.nameTxt = self.___ex.nameTxt
    self.selectBtn = self.___ex.selectBtn
    self.selectGo = self.___ex.selectGo
    self.confirmBtn = self.___ex.confirmBtn
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
end

function SupportTrainingSelectView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
    self.confirmBtn:regOnButtonClick(function ()
        self:OnConfirmClick()
    end)
end

function SupportTrainingSelectView:InitView(cardModel, lockData)
    self.lockData = lockData
    self.cardModel = cardModel
    self.cardList = self:GetCardList(cardModel)
    self.scrollSpt:InitView(self.cardList, function(index) self:OnCardClick(index) end)
end

function SupportTrainingSelectView:GetCardList(cardModel)
    local playerCardsMapModel = PlayerCardsMapModel.new()
    local cid = cardModel:GetCid()
    local pcid = tonumber(cardModel:GetPcid())
    local sameCard = playerCardsMapModel:GetSameCardList(cid)
    local cardList = {}
    local index = 1
    for i, v in pairs(sameCard) do
        if i ~=  pcid then -- 本卡除外
            local playerCardModel = PlayerCardModel.new(i)
            local hasPaster = playerCardModel:HasPaster()
            local hasMedal = playerCardModel:HasMedal()
            local canAdd = (not playerCardModel:IsNotAllowSell()) and (not hasPaster) and (not hasMedal)
            if canAdd then
                playerCardModel.index = index
                index = index + 1
                table.insert(cardList, playerCardModel)
            end
        end
    end
    return cardList
end

function SupportTrainingSelectView:OnCardClick(index)
    for i, v in ipairs(self.scrollSpt.itemDatas) do
        local scrollItem = self.scrollSpt:getItem(i)
        scrollItem:SetChooseState(index == i)
    end
    self.selectCardModel = self.scrollSpt.itemDatas[index]
end

function SupportTrainingSelectView:OnConfirmClick()
    if self.selectCardModel then
        local title = lang.trans("tips")
        local quality = self.selectCardModel:GetCardQuality()
        local qualitySpecial = self.selectCardModel:GetCardQualitySpecial()
        local qualitySuffix = CardHelper.GetQualityNameConfigFixed(quality, qualitySpecial)
        local cardName = self.selectCardModel:GetName()
        cardName = qualitySuffix .. cardName
        local selectPcid = self.selectCardModel:GetPcid()
        local selfPcid = self.cardModel:GetPcid()
        local content = lang.trans("coach_gacha_consume_tip", cardName, 1, lang.transstr("unlock"))
        local consumeData = {}
        consumeData.pcid = selfPcid
        consumeData.trainId = self.lockData.chapter
        consumeData.subId = self.lockData.stage
        consumeData.pcids = {selectPcid}
        DialogManager.ShowConfirmPop(title, content, function()
            EventSystem.SendEvent("TrainingSupporter_ConsumeCard", consumeData)
        end)
    else
        DialogManager.ShowToastByLang("coach_guide_select_card")
    end
    self:Close()
end

function SupportTrainingSelectView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
            self.closeDialog()
        end)
    end
end

return SupportTrainingSelectView
