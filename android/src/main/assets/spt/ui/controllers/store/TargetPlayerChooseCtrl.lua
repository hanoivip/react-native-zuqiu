local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CardIndexViewModel = require("ui.models.cardIndex.CardIndexViewModel")
local TargetPlayerChooseModel = require("ui.models.store.TargetPlayerChooseModel")
local TargetPlayerChooseCtrl = class(BaseCtrl)
TargetPlayerChooseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/TargetPlayerChoose.prefab"

TargetPlayerChooseCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function TargetPlayerChooseCtrl:Init(targetPcid)
    self.view.clickConfirm = function() self:OnClickConfirm() end
    self.view.cardClick = function(cardModel) self:OnCardClick(cardModel) end
    self.view.sortMenuView.clickSort = function(index) self:OnSortClick(index) end
    self.view.clickSearch = function() self:OnSearchClick() end
end

-- 目标球员仅限A、S、SS、SS+ 品质                                                                         `
local OnlyTargetPlayer = 
{
    ['4'] = true, ['5'] = true, ['6'] = true, ["6+"] = true

}

local function matchQualityConditionSort(aModel, bModel)
    local aq = aModel:GetCardQuality()
    local bq = bModel:GetCardQuality()
    if aq == bq then
        local asq = aModel:GetCardQualitySpecial()
        local bsq = bModel:GetCardQualitySpecial()
        return asq > bsq
    else
        return aq > bq
    end
end

function TargetPlayerChooseCtrl:OnClickConfirm()
    if self.choosePcid then
        self.view:Close()
        EventSystem.SendEvent("Exchange_UpdateTarget", self.choosePcid)
    else
        DialogManager.ShowToastByLang("select_exchange_player2")
    end
end

function TargetPlayerChooseCtrl:Refresh(targetPcid)
    TargetPlayerChooseCtrl.super.Refresh(self)

    self.cardsMapModel = PlayerCardsMapModel.new()
    local cardModelList = {}
    local cardList = self.cardsMapModel:GetDifferenceCardList()
    for i, pcid in ipairs(cardList) do
        local tmpCardModel = PlayerCardModel.new(pcid)
        local ascend = tmpCardModel:GetAscend()
        local maxAscend = tmpCardModel:GetMaxAscendNum()
        local quality = tmpCardModel:GetCardQuality()
        local qualitySpecial = tmpCardModel:GetCardQualitySpecial()
        local fixedQuality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
        if OnlyTargetPlayer[fixedQuality] and ascend < maxAscend then
            table.insert(cardModelList, tmpCardModel)
        end
    end
    self.targetPlayerChooseModel = TargetPlayerChooseModel.new(cardModelList)
    if not self.cardIndexViewModel then
        self.cardIndexViewModel = CardIndexViewModel.new()
    end
    -- 符合条件的球员排序
    table.sort(cardModelList, matchQualityConditionSort)

    self:RefreshScrollView(cardModelList)
    self.view:InitView(targetPcid)
end

function TargetPlayerChooseCtrl:RefreshScrollView(cardModelList)
    self.view.scrollView:clearData()
    self.view.scrollView.itemDatas = cardModelList
    self.view.scrollView:refresh()
end

function TargetPlayerChooseCtrl:OnEnterScene()
    EventSystem.AddEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function TargetPlayerChooseCtrl:OnExitScene()
    EventSystem.RemoveEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
end

function TargetPlayerChooseCtrl:OnCardClick(cardModel)
    self.choosePcid = cardModel:GetPcid()
    self.view:SetChoosePlayer(cardModel)
end

function TargetPlayerChooseCtrl:OnSortClick(selectTypeIndex)
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

function TargetPlayerChooseCtrl:EventSortCardList()
    self:SetSelectDetail(self.targetPlayerChooseModel)
    self:SortCardListCallBack()
end

function TargetPlayerChooseCtrl:SortCardListCallBack()
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

function TargetPlayerChooseCtrl:SetSelectDetail(targetPlayerChooseModel)
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

function TargetPlayerChooseCtrl:OnSearchClick()
    res.PushDialog("ui.controllers.playerList.PlayerSearchCtrl", self.targetPlayerChooseModel, self.cardIndexViewModel)
end

return TargetPlayerChooseCtrl
