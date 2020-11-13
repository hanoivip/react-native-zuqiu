local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SortType = require("ui.controllers.playerList.SortType")
local SupporterListSortView = class(unity.base)

function SupporterListSortView:ctor()
--------Start_Auto_Generate--------
    self.defaultBtn = self.___ex.defaultBtn
    self.pasterBtn = self.___ex.pasterBtn
    self.pasterArrowGo = self.___ex.pasterArrowGo
    self.pasterTxt = self.___ex.pasterTxt
    self.trainBtn = self.___ex.trainBtn
    self.trainArrowGo = self.___ex.trainArrowGo
    self.trainTxt = self.___ex.trainTxt
    self.legendBtn = self.___ex.legendBtn
    self.legendArrowGo = self.___ex.legendArrowGo
    self.legendTxt = self.___ex.legendTxt
--------End_Auto_Generate----------
    -- sign
    self.pasterUpSign = self.___ex.pasterUpSign
    self.pasterDownSign = self.___ex.pasterDownSign
    self.trainUpSign = self.___ex.trainUpSign
    self.trainDownSign = self.___ex.trainDownSign
    self.legendUpSign = self.___ex.legendUpSign
    self.legendDownSign = self.___ex.legendDownSign
end

function SupporterListSortView:start()
    self.defaultBtn:regOnButtonClick(function()
        self:OnSortClick(SortType.DEFAULT)
    end)
    self.pasterBtn:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.pasterIndex then  
            sortIndex = (self.pasterIndex == SortType.PASTER_NUM_FALL) and SortType.PASTER_NUM_RISE or SortType.PASTER_NUM_FALL
        else    
            sortIndex = self.pasterIndex or SortType.PASTER_NUM_FALL
        end
        self:OnSortClick(sortIndex)
    end)
    self.trainBtn:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.trainIndex then 
            sortIndex = (self.trainIndex == SortType.TRAIN_PROGRESS_FALL) and SortType.TRAIN_PROGRESS_RISE or SortType.TRAIN_PROGRESS_FALL
        else
            sortIndex = self.trainIndex or SortType.TRAIN_PROGRESS_FALL
        end
        self:OnSortClick(sortIndex)
    end)
    self.legendBtn:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.legendIndex then 
            sortIndex = (self.legendIndex == SortType.LEGEND_PROGRESS_FALL) and SortType.LEGEND_PROGRESS_RISE or SortType.LEGEND_PROGRESS_FALL
        else
            sortIndex = self.legendIndex or SortType.LEGEND_PROGRESS_FALL
        end
        self:OnSortClick(sortIndex)
    end)
end

function SupporterListSortView:SetButtonState(buttonScript, isSelect)
    local selected = buttonScript.___ex.selected
    for k, v in pairs(selected) do
        GameObjectHelper.FastSetActive(v, isSelect)
    end
end

function SupporterListSortView:RestoreButton()
    if self.sortIndex == SortType.PASTER_NUM_FALL or self.sortIndex == SortType.PASTER_NUM_RISE then 
        self:DisableButtonSign(self.pasterArrowGo, self.pasterTxt)
    elseif self.sortIndex == SortType.TRAIN_PROGRESS_FALL or self.sortIndex == SortType.TRAIN_PROGRESS_RISE then 
        self:DisableButtonSign(self.trainArrowGo, self.trainTxt)
    elseif self.sortIndex == SortType.LEGEND_PROGRESS_FALL or self.sortIndex == SortType.LEGEND_PROGRESS_RISE then 
        self:DisableButtonSign(self.legendArrowGo, self.legendTxt)
    end
    if self.sortTarget then
        self:SetButtonState(self.sortTarget, false)
    end
end

function SupporterListSortView:OnSelectSortItem(index)
    self:RestoreButton()
    self.sortIndex = index

    if index == SortType.DEFAULT then
        self.sortTarget = self.defaultBtn
    elseif index == SortType.PASTER_NUM_FALL then
        self.sortTarget = self.pasterBtn
        self:SetPasterSign(true)
    elseif index == SortType.PASTER_NUM_RISE then
        self.sortTarget = self.pasterBtn
        self:SetPasterSign(false)
    elseif index == SortType.TRAIN_PROGRESS_FALL then
        self.sortTarget = self.trainBtn
        self:SetTrainSign(true)
    elseif index == SortType.TRAIN_PROGRESS_RISE then
        self.sortTarget = self.trainBtn
        self:SetTrainSign(false)
    elseif index == SortType.LEGEND_PROGRESS_FALL then
        self.sortTarget = self.legendBtn
        self:SetLegendSign(true)
    elseif index == SortType.LEGEND_PROGRESS_RISE then
        self.sortTarget = self.legendBtn
        self.legendIndex = SortType.LEGEND_PROGRESS_RISE
        self:SetLegendSign(false)
    end
    self:SetButtonState(self.sortTarget, true)
end

-- 点击的时候进行偏移防止挡住箭头
local MovePos = {0, -5, -5, -5, -9}
local DefaultPos = 0
function SupporterListSortView:SetPasterSign(isFall)
    GameObjectHelper.FastSetActive(self.pasterArrowGo, true)
    self.pasterDownSign.interactable = not isFall
    self.pasterUpSign.interactable = isFall
    self.pasterTxt.transform.anchoredPosition = Vector2(MovePos[2], 0)
    self.pasterIndex = isFall and SortType.PASTER_NUM_FALL or SortType.PASTER_NUM_RISE
end

function SupporterListSortView:SetTrainSign(isFall)
    GameObjectHelper.FastSetActive(self.trainArrowGo, true)
    self.trainDownSign.interactable = not isFall
    self.trainUpSign.interactable = isFall
    self.trainTxt.transform.anchoredPosition = Vector2(MovePos[3], 0)
    self.trainIndex = isFall and SortType.TRAIN_PROGRESS_FALL or SortType.TRAIN_PROGRESS_RISE
end

function SupporterListSortView:SetLegendSign(isFall)
    GameObjectHelper.FastSetActive(self.legendArrowGo, true)
    self.legendDownSign.interactable = not isFall
    self.legendUpSign.interactable = isFall
    self.legendTxt.transform.anchoredPosition = Vector2(MovePos[5], 0)
    self.legendIndex = isFall and SortType.LEGEND_PROGRESS_FALL or SortType.LEGEND_PROGRESS_RISE
end

function SupporterListSortView:DisableButtonSign(arrow, text)
    GameObjectHelper.FastSetActive(arrow, false)
    text.transform.anchoredPosition = Vector2(DefaultPos, 0)
end

function SupporterListSortView:InitialData(index)
    self.sortIndex = nil
    self.sortTarget = nil
    self:SetButtonState(self.defaultBtn, false)
    self:SetButtonState(self.pasterBtn, false)
    self:SetButtonState(self.trainBtn, false)
    self:SetButtonState(self.legendBtn, false)
    self:DisableButtonSign(self.pasterArrowGo, self.pasterTxt)
    self:DisableButtonSign(self.trainArrowGo, self.trainTxt)
    self:DisableButtonSign(self.legendArrowGo, self.legendTxt)
    self.pasterIndex = SortType.PASTER_NUM_FALL
    self.trainIndex = SortType.TRAIN_PROGRESS_FALL
    self.legendIndex = SortType.LEGEND_PROGRESS_FALL

    self:OnSelectSortItem(index)
end

function SupporterListSortView:OnSortClick(index)
    self:OnSelectSortItem(index)
    if self.clickSort then
        self.clickSort(index)
    end
end

return SupporterListSortView
