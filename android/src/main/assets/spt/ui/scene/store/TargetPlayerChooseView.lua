local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CardResourceCache = require("ui.common.card.CardResourceCache")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local TargetPlayerChooseView = class(unity.base)

function TargetPlayerChooseView:ctor()
    self.scrollView = self.___ex.scrollView
    self.targetArea = self.___ex.targetArea
    self.btnConfirm = self.___ex.btnConfirm
    self.btnClose = self.___ex.btnClose
    self.confirmButton = self.___ex.confirmButton
    self.confirmGradient = self.___ex.confirmGradient
    self.targetName = self.___ex.targetName
    self.sortMenuView = self.___ex.sortMenuView
    self.posText = self.___ex.posText
    self.btnSearch = self.___ex.btnSearch

    self.cardResourceCache = CardResourceCache.new()
    self:RegScrollViewHandle()
end

function TargetPlayerChooseView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Store/TargetCardFrame.prefab")
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
            if self.selectIndex then
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

function TargetPlayerChooseView:start()
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

function TargetPlayerChooseView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function TargetPlayerChooseView:OnClickConfirm()
    if self.clickConfirm then
        self.clickConfirm()
    end
end

function TargetPlayerChooseView:InitView(targetPcid)
    self.targetPcid = targetPcid
    self.confirmButton.interactable = false
    ButtonColorConfig.SetDisableGradientColor(self.confirmGradient)
    self.targetName.text = lang.trans("target_player")

    if targetPcid then
        for index, cardModel in ipairs(self.scrollView.itemDatas) do
            if cardModel:GetPcid() == targetPcid then 
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

function TargetPlayerChooseView:onDestroy()
    self.cardResourceCache:Clear()
end

function TargetPlayerChooseView:OnCardClick(cardModel)
    if self.cardClick then 
        self.cardClick(cardModel)
    end
end

function TargetPlayerChooseView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function TargetPlayerChooseView:SetChoosePlayer(cardModel)
    self.confirmButton.interactable = true
    ButtonColorConfig.SetNormalGradientColor(self.confirmGradient)
    assert(cardModel)
    if not self.cardView then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        obj.transform:SetParent(self.targetArea.transform, false)
        self.cardView = spt
        self.cardView:IsShowName(false)
    end
    GameObjectHelper.FastSetActive(self.cardView.gameObject, true)
    self.cardView:InitView(cardModel)
    self.targetName.text = cardModel:GetName()
end

function TargetPlayerChooseView:ClearChoosePlayer()
    ButtonColorConfig.SetDisableGradientColor(self.confirmGradient)
    self.confirmButton.interactable = false
    if self.cardView then
        GameObjectHelper.FastSetActive(self.cardView.gameObject, false)
    end
    self.targetName.text = ""
    self.selectIndex = nil
end

function TargetPlayerChooseView:SetSortTxt(isSelected)
    self.posText.text = isSelected and lang.trans("pos_be_selected_title") or lang.trans("cardIndex_select")
end

return TargetPlayerChooseView
