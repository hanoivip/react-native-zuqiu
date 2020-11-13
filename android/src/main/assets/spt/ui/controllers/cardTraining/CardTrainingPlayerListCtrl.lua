local BaseCtrl = require("ui.controllers.BaseCtrl")
local MenuType = require("ui.controllers.playerList.MenuType")
local CardTrainingPlayerListModel = require("ui.models.cardTraining.CardTrainingPlayerListModel")
local SortType = require("ui.controllers.playerList.SortType")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local DialogManager = require("ui.control.manager.DialogManager")

local CardTrainingPlayerListCtrl = class(BaseCtrl)

CardTrainingPlayerListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardTraining/Prefabs/CardTrainingPlayerList.prefab"

CardTrainingPlayerListCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function CardTrainingPlayerListCtrl:ctor(cardTrainingMainModel)
    self.playerListModel = CardTrainingPlayerListModel.new()
    self.playerListModel:SortCardList(SortType.QUALITY_FALL)
end

function CardTrainingPlayerListCtrl:Init(cardTrainingMainModel)
    self.cardTrainingMainModel = cardTrainingMainModel
    self.cardResourceCache = CardResourceCache.new()

    -- 选中卡牌之后的事件回调（球员出售）
    self.view.selectCardCallBack = function(pcid, isSelected)
        self:SelectCardCallBack(pcid, isSelected)
    end

    self.view.confirmBtnClick = function () self:OnConfirmBtnClick() end
    self:InitScrollView(cardTrainingMainModel:GetPcid(), cardTrainingMainModel:GetCid())
end

function CardTrainingPlayerListCtrl:InitScrollView(selfPcid, cid)
    self.view.scrollView:regOnCreateItem(function (scrollSelf, index)
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab"
        local obj, spt = res.Instantiate(prefab)
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    
    self.view.scrollView:regOnResetItem(function (scrollSelf, spt, index)
        local cardModel = scrollSelf.itemDatas[index]
        spt.clickCard = function() self:OnCardClick(cardModel:GetPcid()) end
        spt:InitView(cardModel, MenuType.SELL, self.playerListModel, self.cardResourceCache, self)
        spt:SetSellState(self.playerListModel:IsCardSelected(cardModel:GetPcid()))
    end)

    local cardsArray = {}
    local sortCardList = self.playerListModel:GetSortCardList()
    for i, pcid in ipairs(sortCardList) do
        local cardModel = self.playerListModel:GetCardModel(pcid)
        if tonumber(selfPcid) ~= tonumber(pcid) and cardModel:GetCid() == cid then
            table.insert(cardsArray, cardModel)
        end
    end

    self.view.scrollView:refresh(cardsArray)
end

function CardTrainingPlayerListCtrl:SelectCardCallBack(pcid, isSelected)
    local index
    for i, v in ipairs(self.view.scrollView.itemDatas) do
        if tostring(v:GetPcid()) == tostring(pcid) then
            index = i
        end
        local cardView = self.view.scrollView:getItem(i)
        if cardView then
            cardView:SetSellState(false)
        end
    end
    if index then
        local cardView = self.view.scrollView:getItem(index)
        if cardView then
            cardView:SetSellState(isSelected)
        end
    end
end

function CardTrainingPlayerListCtrl:OnCardClick(pcid)
    local cardModel = self.playerListModel:GetCardModel(pcid)
    if cardModel:IsNotAllowSell() then return end
    if not self.playerListModel:IsCardSelected(pcid) then
        if cardModel:HasMedal() then
            DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip8", cardModel:GetName()), nil)
        elseif cardModel:HasPaster() then 
            DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip9", cardModel:GetName()), nil)
        elseif not PlayerLetterInsidePlayerModel.new():IsBelongToLetterCard(cardModel:GetCid()) then
            self.playerListModel:ToggleSelectCard(pcid)
        else
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("player_sell_tip", cardModel:GetName()), function ()
                self.playerListModel:ToggleSelectCard(pcid)
            end, nil)
        end
    else
        self.playerListModel:ToggleSelectCard(pcid)
    end
end

function CardTrainingPlayerListCtrl:OnConfirmBtnClick()
    local pcid = self.cardTrainingMainModel:GetPcid()
    
    local cardConsum = function()
        clr.coroutine(function ()
            local trainId = self.cardTrainingMainModel:GetCurrLevelSelected()
            local subId = self.cardTrainingMainModel:GetSubIdByLevel(trainId)
            local contents = {}
            local selectedCardList = self.playerListModel:GetSelectedCardList()
            contents.card = selectedCardList
            local response = req.cardTrainingDemand(pcid, trainId, subId, contents)
            if api.success(response) then
                -- 这里需要传入一个数组，只保存pcid
                PlayerCardsMapModel.new():RemoveCardData(selectedCardList)
                self.view:Close()
                EventSystem.SendEvent("CardTraining_RefreshMainView")
            end
        end)
    end

    local selectCardModel = self.playerListModel:GetCardModel(pcid)
    local m_name = selectCardModel:GetName()
    local tip = lang.transstr("tips")
    local consumTips = lang.transstr("training_medal_consum_tips", m_name)
    if next(self.playerListModel:GetSelectedCardList()) == nil then 
        DialogManager.ShowToast(lang.transstr("training_medal_consum_err_tips", m_name))
    else
        DialogManager.ShowConfirmPop(tip, consumTips, cardConsum)
    end
end

function CardTrainingPlayerListCtrl:GetPlayerRes()
    if not self.playerRes then
        self.playerRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/PlayerList/Player.prefab")
    end
    return self.playerRes
end

function CardTrainingPlayerListCtrl:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    end
    return self.cardRes
end

function CardTrainingPlayerListCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function CardTrainingPlayerListCtrl:OnExitScene()
    self.view:OnExitScene()
end

return CardTrainingPlayerListCtrl