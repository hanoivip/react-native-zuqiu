local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local TargetPlayerChooseModel = require("ui.models.store.TargetPlayerChooseModel")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local ExchangePlayerChooseCtrl = class(BaseCtrl)
ExchangePlayerChooseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/ExchangePlayerChoose.prefab"

ExchangePlayerChooseCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function ExchangePlayerChooseCtrl:Init(targetPcid, exchangePlayerPcid, otherExchangePcid, slot)
    self.view.clickConfirm = function() self:OnClickConfirm() end
    self.view.cardClick = function(cardModel) self:OnCardClick(cardModel) end
    self.view.sortMenuView.clickSort = function(index) self:OnSortClick(index) end
    self.view.clickSearch = function() self:OnSearchClick() end
end

function ExchangePlayerChooseCtrl:OnClickConfirm()
    if self.choosePcid and self.slot then
        self.view:Close()
        EventSystem.SendEvent("Exchange_UpdateChoose", self.choosePcid, self.slot)
    else
        DialogManager.ShowToastByLang("select_exchange_player2")
    end
end

function ExchangePlayerChooseCtrl:Refresh(targetPcid, exchangePlayerPcid, otherExchangePcid, slot)
    ExchangePlayerChooseCtrl.super.Refresh(self)

    self.slot = slot
    local targetModel = PlayerCardModel.new(targetPcid)
    local needQuality = targetModel:GetCardQuality()
    local needSpecialQuality = targetModel:GetCardQualitySpecial()
    self.cardsMapModel = PlayerCardsMapModel.new()
    local cardModelList = {}
    
    local cardList = self.cardsMapModel:GetCardList()
    local tempPcids = {}
    for i, pcid in ipairs(cardList) do
        local tmpCardModel = PlayerCardModel.new(pcid)
        local quality = tmpCardModel:GetCardQuality()
        local specialQuality = tmpCardModel:GetCardQualitySpecial()
        local qualityState = quality == needQuality and specialQuality == needSpecialQuality
        local pcidNum = tonumber(pcid)
        targetPcid = tonumber(targetPcid)
        otherExchangePcid = tonumber(otherExchangePcid)
        if qualityState and pcidNum ~= targetPcid and pcidNum ~= otherExchangePcid then
            table.insert(cardModelList, tmpCardModel)
        end
    end

    self.targetPlayerChooseModel = TargetPlayerChooseModel.new(cardModelList)
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end

    self:RefreshScrollView(cardModelList)
    self.view:InitView(exchangePlayerPcid)
end

function ExchangePlayerChooseCtrl:RefreshScrollView(cardModelList)
    self.view.scrollView:clearData()
    self.view.scrollView.itemDatas = cardModelList
    self.view.scrollView:refresh()
end

function ExchangePlayerChooseCtrl:OnEnterScene()
    EventSystem.AddEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function ExchangePlayerChooseCtrl:OnExitScene()
    EventSystem.RemoveEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function ExchangePlayerChooseCtrl:OnCardClick(cardModel)
    self.choosePcid = cardModel:GetPcid()
    self.view:SetChoosePlayer()
end

function ExchangePlayerChooseCtrl:OnSortClick(selectTypeIndex)
    self.cacheScrollPos = 1
    local typeIndex = self.targetPlayerChooseModel:GetSelectTypeIndex()
    if typeIndex == selectTypeIndex then return end
    local selectPos = self.targetPlayerChooseModel:GetSelectPos()
    local selectQuality = self.targetPlayerChooseModel:GetSelectQuality()
    local selectNationality = self.targetPlayerChooseModel:GetSeletNationality()
    local selectName = self.targetPlayerChooseModel:GetSeletName()
    local selectSkill = self.targetPlayerChooseModel:GetSeletSkill()
    self.targetPlayerChooseModel:SortCardList(selectTypeIndex, selectPos, selectQuality, selectNationality, selectName, selectSkill)
end

function ExchangePlayerChooseCtrl:EventSortCardList()
    self:SetSelectDetail(self.targetPlayerChooseModel)
    self:SortCardListCallBack()
end

function ExchangePlayerChooseCtrl:SortCardListCallBack()
    -- 创建卡牌列表
    local sortCardList = self.targetPlayerChooseModel:GetSortCardList()
    self.selectTypeIndex = self.targetPlayerChooseModel:GetSelectTypeIndex()
    self.selectPos = self.targetPlayerChooseModel:GetSelectPos()
    self.selectQuality = self.targetPlayerChooseModel:GetSelectQuality()
    self.selectName = self.targetPlayerChooseModel:GetSeletName()
    self.selectNationality = self.targetPlayerChooseModel:GetSeletNationality()
    self.selectSkill = self.targetPlayerChooseModel:GetSeletSkill()
    local cardsArray = {}
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.targetPlayerChooseModel:GetCardModel(pcid)
        table.insert(cardsArray, cardModel)
    end
    self.view:ClearChoosePlayer()
    self.choosePcid = nil
    self:RefreshScrollView(cardsArray)
end

function ExchangePlayerChooseCtrl:SetSelectDetail(targetPlayerChooseModel)
    local isSelected = false
    if targetPlayerChooseModel then
        local selectPos = targetPlayerChooseModel:GetSelectPos()
        local selectQuality = targetPlayerChooseModel:GetSelectQuality()
        local selectName = targetPlayerChooseModel:GetSeletName()
        local selectNationality = targetPlayerChooseModel:GetSeletNationality()
        local selectSkill = targetPlayerChooseModel:GetSeletSkill()

        if selectPos and next(selectPos) then
            isSelected = true
        end
        if selectQuality and next(selectQuality) then
            isSelected = true
        end
        if selectSkill and next(selectSkill) then
            isSelected = true
        end
        if selectName ~= "" or selectNationality ~= "" then
            isSelected = true
        end
        self.view:SetSortTxt(isSelected)
    end
end

function ExchangePlayerChooseCtrl:OnSearchClick()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.targetPlayerChooseModel, self.cardIndexViewModel)
end

return ExchangePlayerChooseCtrl