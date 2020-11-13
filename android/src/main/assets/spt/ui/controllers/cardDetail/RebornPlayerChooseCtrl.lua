local BaseCtrl = require("ui.controllers.BaseCtrl")
local RebornPlayerChooseCtrl = class(BaseCtrl)
local CardBuilder = require("ui.common.card.CardBuilder")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local RebornPlayerChooseModel = require("ui.models.cardDetail.RebornPlayerChooseModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

RebornPlayerChooseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/RebornPlayerChoose.prefab"

RebornPlayerChooseCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

local function matchRebornConditionSort(aModel, bModel)
    return aModel:getMatchRebornConditionOrder() > bModel:getMatchRebornConditionOrder()
end

function RebornPlayerChooseCtrl:Init(upgradeLimit, pcid, isAllowChangeScene, targetPcid)
    self.view.clickConfirm = function()
        if self.playerChooseModel:GetChooseCardPcid() then
            self.playerChooseModel:ConfirmChooseCard()
            self.view:Close()
        end
    end

    self.view.onScrollCreateItem = function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/RebornCardFrame.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end
    self.view.onScrollResetItem = function(scrollSelf, spt, index)
        local itemData = scrollSelf.itemDatas[index]  -- PlayerCardModel
        spt:InitView(itemData, self.upgradeLimit, self.cardModel:GetAscend())
        if index ~= self.selectIndex then
            spt:OnCancel()
        else
            spt:OnChoose()
        end
        spt.clickCard = function()
            local selectPcid = itemData:GetPcid()
            local tmpCardModel = PlayerCardModel.new(selectPcid)
            if tmpCardModel:IsNotAllowSell() or tmpCardModel:GetAscend() > self.cardModel:GetAscend() then
                return
            elseif tmpCardModel:HasMedal() then 
                DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip6", tmpCardModel:GetName()), nil)
                return 
            elseif tmpCardModel:HasPaster() then 
                DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip3", tmpCardModel:GetName()), nil)
                return
            elseif tmpCardModel:GetUpgrade() < self.upgradeLimit then 
                local callback = function()
                    local currentModel = CardBuilder.GetOwnCardModel(selectPcid)
                    local CardDetailMainCtrl = res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", { selectPcid }, 1, currentModel)
                end
                local titleText = lang.trans("card_ascend_title")
                local contentText = lang.trans("card_ascend_content", self.upgradeLimit)
                DialogManager.ShowMessageBox(titleText, contentText, callback) 
                return 
            end

            if self.selectIndex then
                local selectSpt = scrollSelf:getItem(self.selectIndex)
                if selectSpt then
                    selectSpt:OnCancel()
                end
            end
            self.selectIndex = index
            spt:OnChoose()
            self:OnCardClick(tmpCardModel) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end

    self.playerChooseModel = RebornPlayerChooseModel.new()
end

function RebornPlayerChooseCtrl:Refresh(upgradeLimit, pcid, isAllowChangeScene, targetPcid)
    RebornPlayerChooseCtrl.super.Refresh(self)

    self.upgradeLimit = upgradeLimit
    self.pcid = pcid
    self.isAllowChangeScene = isAllowChangeScene

    self.cardsMapModel = PlayerCardsMapModel.new()
    self.cardModel = PlayerCardModel.new(pcid)
    self.playerLevel = PlayerInfoModel.new():GetLevel()

    self:InitView()

    if targetPcid then
        for index, cardModel in ipairs(self.view.scroll.itemDatas) do
            if cardModel:GetPcid() == targetPcid then 
                local targetSpt = self.view.scroll:getItem(index)
                self.selectIndex = index
                if targetSpt then 
                    targetSpt:OnChoose()
                end
                self:OnCardClick(cardModel) 
                break
            end
        end
    end
end

function RebornPlayerChooseCtrl:GetStatusData()
    return self.upgradeLimit, self.pcid, self.isAllowChangeScene
end

function RebornPlayerChooseCtrl:OnEnterScene()
end

function RebornPlayerChooseCtrl:OnExitScene()
end

function RebornPlayerChooseCtrl:InitView()
    -- 找到cid相同的卡牌
    local cardList = self.cardsMapModel:GetCardList()
    local cardModelList = {}

    for i, pcid in ipairs(cardList) do
        local tmpCardModel = PlayerCardModel.new(pcid)
        if tostring(tmpCardModel:GetCid()) == tostring(self.cardModel:GetCid()) 
            and tostring(tmpCardModel:GetPcid()) ~= tostring(self.cardModel:GetPcid()) then
            tmpCardModel.getMatchRebornConditionOrder = function()
                if tmpCardModel:GetUpgrade() < self.upgradeLimit or tmpCardModel:IsNotAllowSell() or tmpCardModel:GetAscend() > self.cardModel:GetAscend() then
                    return 0
                end
                return 1
            end
            table.insert(cardModelList, tmpCardModel)
        end
    end
    
    -- 符合条件的球员排序
    table.sort(cardModelList, matchRebornConditionSort)

    self.view:InitView(cardModelList, self.isAllowChangeScene, self.playerLevel)
    self:RefreshScrollView(cardModelList)
end

function RebornPlayerChooseCtrl:RefreshScrollView(cardModelList)
    self.view.scroll:clearData()

    self.view.scroll.itemDatas = cardModelList
    
    self.view.scroll:refresh()
end

function RebornPlayerChooseCtrl:OnCardClick(tmpCardModel)
    self.playerChooseModel:SetChooseCard(tmpCardModel:GetPcid())
    self.view:SetChoosePlayer(tmpCardModel)
end

return RebornPlayerChooseCtrl
