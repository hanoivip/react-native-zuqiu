local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local DialogManager = require("ui.control.manager.DialogManager")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local ExchangePlayerChooseView = class(unity.base)

function ExchangePlayerChooseView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnConfirm = self.___ex.btnConfirm
    self.btnClose = self.___ex.btnClose
    self.confirmButton = self.___ex.confirmButton
    self.confirmGradient = self.___ex.confirmGradient
    self.sortMenuView = self.___ex.sortMenuView
    self.posText = self.___ex.posText
    self.btnSearch = self.___ex.btnSearch

    self.cardResourceCache = CardResourceCache.new() 
    self:RegScrollViewHandle()
end

function ExchangePlayerChooseView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/ExchangeCardFrame.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local cardModel = scrollSelf.itemDatas[index]  -- PlayerCardModel
        spt:InitView(cardModel, self.cardResourceCache)
        if index ~= self.selectIndex then
            spt:OnCancel()
        else
            spt:OnChoose()
        end
        spt.clickCard = function()
            local isLock, lockData = cardModel:GetLockState()
            if isLock then return end
            if cardModel:HasMedal() then 
                DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip7"), nil)
                return
            elseif cardModel:HasPaster() then 
                DialogManager.ShowAlertPop(lang.trans("tips"), lang.trans("player_sell_tip4"), nil)
                return
            elseif self.selectIndex then
                local selectSpt = scrollSelf:getItem(self.selectIndex)
                if selectSpt then
                    selectSpt:OnCancel()
                end
            end
            self.selectIndex = index
            spt:OnChoose()
            self:OnCardClick(cardModel) 
        end
        scrollSelf:updateItemIndex(spt, index)
    end)
end

function ExchangePlayerChooseView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:OnClickConfirm()
    end)
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
end

function ExchangePlayerChooseView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function ExchangePlayerChooseView:OnClickConfirm()
    if self.clickConfirm then
        self.clickConfirm()
    end
end

function ExchangePlayerChooseView:onDestroy()
    self.cardResourceCache:Clear()
end

function ExchangePlayerChooseView:InitView(exchangePlayerPcid)
    self.exchangePlayerPcid = exchangePlayerPcid
    self.confirmButton.interactable = false
    ButtonColorConfig.SetDisableGradientColor(self.confirmGradient)

    if exchangePlayerPcid then
        for index, cardModel in ipairs(self.scrollView.itemDatas) do
            if cardModel:GetPcid() == exchangePlayerPcid then 
                local targetSpt = self.scrollView:getItem(index)
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

function ExchangePlayerChooseView:OnCardClick(cardModel)
    if self.cardClick then 
        self.cardClick(cardModel)
    end
end

function ExchangePlayerChooseView:SetChoosePlayer()
    self.confirmButton.interactable = true
    ButtonColorConfig.SetNormalGradientColor(self.confirmGradient)
end

function ExchangePlayerChooseView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function ExchangePlayerChooseView:ClearChoosePlayer()
    ButtonColorConfig.SetDisableGradientColor(self.confirmGradient)
    self.confirmButton.interactable = false
    self.selectIndex = nil
end

function ExchangePlayerChooseView:SetSortTxt(isSelected)
    self.posText.text = isSelected and lang.trans("pos_be_selected_title") or lang.trans("cardIndex_select")
end

return ExchangePlayerChooseView
