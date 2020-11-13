local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SortType = require("ui.controllers.playerList.SortType")
local PlayerListSortView = class(unity.base)

function PlayerListSortView:ctor()
    -- button
    self.btnDefault = self.___ex.btnDefault
    self.btnPower = self.___ex.btnPower
    self.btnQuality = self.___ex.btnQuality
    self.btnName = self.___ex.btnName
    self.btnObtainOrder = self.___ex.btnObtainOrder

    -- sign
    self.powerUpSign = self.___ex.powerUpSign
    self.powerDownSign = self.___ex.powerDownSign
    self.qualityUpSign = self.___ex.qualityUpSign
    self.qualityDownSign = self.___ex.qualityDownSign
    self.nameUpSign = self.___ex.nameUpSign
    self.nameDownSign = self.___ex.nameDownSign
    self.obtainOrderUpSign = self.___ex.obtainOrderUpSign
    self.obtainOrderDownSign = self.___ex.obtainOrderDownSign

    self.powerArrow = self.___ex.powerArrow
    self.qualityArrow = self.___ex.qualityArrow
    self.nameArrow = self.___ex.nameArrow
    self.obtainOrderArrow = self.___ex.obtainOrderArrow

    self.powerText = self.___ex.powerText
    self.qualityText = self.___ex.qualityText
    self.nameText = self.___ex.nameText
    self.obtainOrderText = self.___ex.obtainOrderText

    self.sortIndex = nil
    self.sortTarget = self.btnDefault
end

function PlayerListSortView:start()
    self.btnDefault:regOnButtonClick(function()
        self:OnSortClick(SortType.DEFAULT)
    end)
    self.btnPower:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.powerIndex then  
            sortIndex = (self.powerIndex == SortType.POWER_FALL) and SortType.POWER_RISE or SortType.POWER_FALL
        else    
            sortIndex = self.powerIndex or SortType.POWER_FALL
        end
        self:OnSortClick(sortIndex)
    end)
    self.btnQuality:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.qualityIndex then 
            sortIndex = (self.qualityIndex == SortType.QUALITY_FALL) and SortType.QUALITY_RISE or SortType.QUALITY_FALL
        else
            sortIndex = self.qualityIndex or SortType.QUALITY_FALL
        end
        self:OnSortClick(sortIndex)
    end)
    self.btnName:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.nameIndex then 
            sortIndex = (self.nameIndex == SortType.NAME_FALL) and SortType.NAME_RISE or SortType.NAME_FALL
        else
            sortIndex = self.nameIndex or SortType.NAME_FALL
        end
        self:OnSortClick(sortIndex)
    end)
    self.btnObtainOrder:regOnButtonClick(function()
        local sortIndex
        if self.sortIndex == self.obtainOrderIndex then 
            sortIndex = (self.obtainOrderIndex == SortType.OBTAIN_ORDER_FALL) and SortType.OBTAIN_ORDER_RISE or SortType.OBTAIN_ORDER_FALL
        else
            sortIndex = self.obtainOrderIndex or SortType.OBTAIN_ORDER_FALL
        end
        self:OnSortClick(sortIndex)
    end)
end

function PlayerListSortView:SetButtonState(buttonScript, isSelect)
    local selected = buttonScript.___ex.selected
    for k, v in pairs(selected) do
        GameObjectHelper.FastSetActive(v, isSelect)
    end
end

function PlayerListSortView:RestoreButton()
    if self.sortIndex == SortType.POWER_FALL or self.sortIndex == SortType.POWER_RISE then 
        self:DisableButtonSign(self.powerArrow, self.powerText)
    elseif self.sortIndex == SortType.QUALITY_FALL or self.sortIndex == SortType.QUALITY_RISE then 
        self:DisableButtonSign(self.qualityArrow, self.qualityText)
    elseif self.sortIndex == SortType.NAME_FALL or self.sortIndex == SortType.NAME_RISE then 
        self:DisableButtonSign(self.nameArrow, self.nameText)
    elseif self.sortIndex == SortType.OBTAIN_ORDER_FALL or self.sortIndex == SortType.OBTAIN_ORDER_RISE then 
        self:DisableButtonSign(self.obtainOrderArrow, self.obtainOrderText)
    end
    if self.sortTarget then
        self:SetButtonState(self.sortTarget, false)
    end
end

function PlayerListSortView:OnSelectSortItem(index)
    self:RestoreButton()
    self.sortIndex = index

    if index == SortType.DEFAULT then
        self.sortTarget = self.btnDefault
    elseif index == SortType.POWER_FALL then
        self.sortTarget = self.btnPower
        self:SetPowerSign(true)
    elseif index == SortType.POWER_RISE then
        self.sortTarget = self.btnPower
        self:SetPowerSign(false)
    elseif index == SortType.QUALITY_FALL then
        self.sortTarget = self.btnQuality
        self:SetQualitySign(true)
    elseif index == SortType.QUALITY_RISE then
        self.sortTarget = self.btnQuality
        self:SetQualitySign(false)
    elseif index == SortType.NAME_FALL then
        self.sortTarget = self.btnName
        self:SetNameSign(true)
    elseif index == SortType.NAME_RISE then
        self.sortTarget = self.btnName
        self.nameIndex = SortType.NAME_RISE
        self:SetNameSign(false)
    elseif index == SortType.OBTAIN_ORDER_FALL then
        self.sortTarget = self.btnObtainOrder
        self:SetObtainOrderSign(true)
    elseif index == SortType.OBTAIN_ORDER_RISE then
        self.sortTarget = self.btnObtainOrder
        self:SetObtainOrderSign(false)
    end

    self:SetButtonState(self.sortTarget, true)
end

-- 点击的时候进行偏移防止挡住箭头
local MovePos = {0, -5, -5, -5, -9}
local DefaultPos = 0
function PlayerListSortView:SetPowerSign(isFall)
    GameObjectHelper.FastSetActive(self.powerArrow, true)
    self.powerDownSign.interactable = not isFall
    self.powerUpSign.interactable = isFall
    self.powerText.transform.anchoredPosition = Vector2(MovePos[2], 0)
    self.powerIndex = isFall and SortType.POWER_FALL or SortType.POWER_RISE
end

function PlayerListSortView:SetQualitySign(isFall)
    GameObjectHelper.FastSetActive(self.qualityArrow, true)
    self.qualityDownSign.interactable = not isFall
    self.qualityUpSign.interactable = isFall
    self.qualityText.transform.anchoredPosition = Vector2(MovePos[3], 0)
    self.qualityIndex = isFall and SortType.QUALITY_FALL or SortType.QUALITY_RISE
end

function PlayerListSortView:SetNameSign(isFall)
    GameObjectHelper.FastSetActive(self.nameArrow, true)
    self.nameDownSign.interactable = not isFall
    self.nameUpSign.interactable = isFall
    self.nameText.transform.anchoredPosition = Vector2(MovePos[4], 0)
    self.nameIndex = isFall and SortType.NAME_FALL or SortType.NAME_RISE
end

function PlayerListSortView:SetObtainOrderSign(isFall)
    GameObjectHelper.FastSetActive(self.obtainOrderArrow, true)
    self.obtainOrderDownSign.interactable = not isFall
    self.obtainOrderUpSign.interactable = isFall
    self.obtainOrderText.transform.anchoredPosition = Vector2(MovePos[5], 0)
    self.obtainOrderIndex = isFall and SortType.OBTAIN_ORDER_FALL or SortType.OBTAIN_ORDER_RISE
end

function PlayerListSortView:DisableButtonSign(arrow, text)
    GameObjectHelper.FastSetActive(arrow, false)
    text.transform.anchoredPosition = Vector2(DefaultPos, 0)
end

function PlayerListSortView:InitialData(index)
    self.sortIndex = nil
    self.sortTarget = nil
    self:SetButtonState(self.btnDefault, false)
    self:SetButtonState(self.btnPower, false)
    self:SetButtonState(self.btnQuality, false)
    self:SetButtonState(self.btnName, false)
    self:SetButtonState(self.btnObtainOrder, false)
    self:DisableButtonSign(self.powerArrow, self.powerText)
    self:DisableButtonSign(self.qualityArrow, self.qualityText)
    self:DisableButtonSign(self.nameArrow, self.nameText)
    self:DisableButtonSign(self.obtainOrderArrow, self.obtainOrderText)
    self.powerIndex = SortType.POWER_FALL
    self.qualityIndex = SortType.QUALITY_FALL
    self.nameIndex = SortType.NAME_FALL
    self.obtainOrderIndex = SortType.OBTAIN_ORDER_FALL

    self:OnSelectSortItem(index)
end

function PlayerListSortView:OnSortClick(index)
    self:OnSelectSortItem(index)
    if self.clickSort then
        self.clickSort(index)
    end
end

return PlayerListSortView
