local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local PasterCardChooseView = class(unity.base)

function PasterCardChooseView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnClose = self.___ex.btnClose
    self.btnConfirm = self.___ex.btnConfirm
    self:RegScrollViewHandle()
end

function PasterCardChooseView:RegScrollViewHandle()
    self.scrollView:regOnCreateItem(function(scrollSelf, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Paster/PasterCardNode.prefab")
        scrollSelf:resetItem(spt, index)
        return obj
    end)
    self.scrollView:regOnResetItem(function(scrollSelf, spt, index)
        local cardModel = scrollSelf.itemDatas[index]  -- PlayerCardModel
        spt:InitView(cardModel)
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

function PasterCardChooseView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnConfirm:regOnButtonClick(function()
        self:OnClickConfirm()
    end)
end

function PasterCardChooseView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function PasterCardChooseView:OnClickConfirm()
    if self.clickConfirm then
        self.clickConfirm(self.selectCardModel)
    end
end

function PasterCardChooseView:SortCardsList(cardsMap)
    table.sort(cardsMap, function(aModel, bModel)
        if aModel:GetCardQuality() == bModel:GetCardQuality() then
            return aModel:GetLevel() > bModel:GetLevel()
        else
            return aModel:GetCardQuality() > bModel:GetCardQuality()
        end
    end)
end

function PasterCardChooseView:InitView(pasterModel, cardsMap)
    self:SortCardsList(cardsMap)
    self:RefreshScrollView(cardsMap)
end

function PasterCardChooseView:OnCardClick(cardModel)
    self.selectCardModel = cardModel
end

function PasterCardChooseView:RefreshScrollView(cardModelList)
    self.scrollView:clearData()
    self.scrollView.itemDatas = cardModelList
    self.scrollView:refresh()
end

return PasterCardChooseView
