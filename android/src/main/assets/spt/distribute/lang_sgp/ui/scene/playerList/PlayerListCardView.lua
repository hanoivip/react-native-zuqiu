local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local MenuType = require("ui.controllers.playerList.MenuType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local LockType = require("ui.common.lock.LockType")
local SortType = require("ui.controllers.playerList.SortType")
local LuaButton = require("ui.control.button.LuaButton")
local PlayerLetterInsidePlayerModel = require("ui.models.playerLetter.PlayerLetterInsidePlayerModel")
local PlayerListCardView = class(LuaButton)

function PlayerListCardView:ctor()
    PlayerListCardView.super.ctor(self)
    self.value = self.___ex.value
    self.cardParent = self.___ex.cardParent
    self.valueBottom = self.___ex.valueBottom
    self.info = self.___ex.info
    self.sell = self.___ex.sell
    self.lock = self.___ex.lock
    self.fixedLock = self.___ex.fixedLock
    self.img = self.___ex.img
    self.mask = self.___ex.mask
    self.desc = self.___ex.desc
    self.nametxt = self.___ex.name
    self.redPoint = self.___ex.redPoint
    self.startSign = self.___ex.startSign
    self.benchSign = self.___ex.benchSign
    self.powerSign = self.___ex.powerSign
    self.powerText = self.___ex.powerText
    self.own = self.___ex.own
    self.message = self.___ex.message
    self.nameBg = self.___ex.nameBg
end

function PlayerListCardView:start()
    self:regOnButtonClick(function()
        self:OnCardClick()
    end)
end

function PlayerListCardView:OnCardClick()
    if self.clickCard then
        self.clickCard()
    end
end

local LetterMessageType = {[SortType.DEFAULT] = true, [SortType.QUALITY_FALL] = true, [SortType.QUALITY_RISE] = true, [SortType.NAME_FALL] = true,
                           [SortType.NAME_RISE] = true,[SortType.OBTAIN_ORDER_FALL] = true, [SortType.OBTAIN_ORDER_FALL] = true,}
function PlayerListCardView:InitView(cardModel, menuType, playerListModel, cardResourceCache, parentCtrl)
    -- Card
    if not self.cardView then
        local cardObject = Object.Instantiate(parentCtrl:GetCardRes())
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:SetCardResourceCache(cardResourceCache)
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
    self.nametxt.text = tostring(cardModel:GetName())
    if menuType == MenuType.LIST then
        GameObjectHelper.FastSetActive(self.valueBottom, false)
        GameObjectHelper.FastSetActive(self.info, false)
        GameObjectHelper.FastSetActive(self.mask, false)
    elseif menuType == MenuType.LOCK then
        GameObjectHelper.FastSetActive(self.sell, false)
        GameObjectHelper.FastSetActive(self.info, true)
        GameObjectHelper.FastSetActive(self.redPoint, false)
        self:SetLockStateByLockPage(cardModel)
    elseif menuType == MenuType.SELL then
        GameObjectHelper.FastSetActive(self.sell, false)
        GameObjectHelper.FastSetActive(self.info, true)
        GameObjectHelper.FastSetActive(self.redPoint, false)
        self:SetLockStateBySellPage(cardModel)
    end


    local menuTypeIndex = playerListModel:GetSelectTypeIndex()
    local lockType = nil
    local isShowPower = false
    if menuTypeIndex == SortType.DEFAULT then 
        local isLock, lockData = cardModel:GetLockState()
        if isLock then
            lockType = lockData.getKey()
        end
    elseif menuTypeIndex == SortType.POWER_FALL or menuTypeIndex == SortType.POWER_RISE then 
        isShowPower = true
        local power = cardModel:GetPower()
        self.powerText.text = lang.transstr("formation_power") .. "\n" .. power
    end
    local isInLetterMessage = PlayerLetterInsidePlayerModel.new():IsBelongToLetterCard(cardModel:GetCid())
    GameObjectHelper.FastSetActive(self.message, isInLetterMessage and LetterMessageType[menuTypeIndex]
        and not (lockType == LockType.CourtLock or lockType == LockType.BenchLock))
    GameObjectHelper.FastSetActive(self.startSign, lockType == LockType.CourtLock)
    GameObjectHelper.FastSetActive(self.benchSign, lockType == LockType.BenchLock)
    GameObjectHelper.FastSetActive(self.powerSign, isShowPower)

    -- 图鉴获取标识
    if playerListModel.__cname == "CardIndexModel" then
        GameObjectHelper.FastSetActive(self.own, playerListModel:IsCardGeted(cardModel:GetCid()))
    end
end

function PlayerListCardView:SetLockStateBySellPage(cardModel)
    local isLock, lockData = cardModel:GetLockState()
    local isFixedLock = false
    local isOtherLock = false
    --巅峰对决优先级搞
    if cardModel:IsInPeakLock() then
        isOtherLock = true
    elseif cardModel:IsInPlayingLock() or cardModel:IsInPlayingRepLock() then
        isFixedLock = true
    elseif cardModel:IsInPlayerLock() or cardModel:IsInCwarLock() 
        or cardModel:IsInSilverLock() or cardModel:IsInGoldLock()
        or cardModel:IsInBlackGoldLock() or cardModel:IsInPlatinumLock()
        or cardModel:IsInSpecialEventsLock() or cardModel:IsInBenchFormationPlayingLock() 
        or cardModel:IsInBenchFormationBenchLock() then
        isOtherLock = true
    end
    GameObjectHelper.FastSetActive(self.valueBottom, true)
    GameObjectHelper.FastSetActive(self.mask, isFixedLock or isOtherLock)
    GameObjectHelper.FastSetActive(self.fixedLock, isFixedLock)
    GameObjectHelper.FastSetActive(self.lock, isOtherLock)
    self.value.text = lang.transstr("saleValue") .. string.formatNumWithUnit(cardModel:GetValue())
    self.desc.text = ""
end

function PlayerListCardView:SetLockStateByLockPage(cardModel)
    local desc = ""
    local isLock, lockData = cardModel:GetLockState()
    local isFixedLock = false
    local isOtherLock = false
    if isLock then
        local lockId = lockData.getKey()
        if lockId == LockType.CourtLock or lockId == LockType.BenchLock then
            isFixedLock = true
        else
            isOtherLock = true
        end
        desc = lockData.desc
    end
    GameObjectHelper.FastSetActive(self.mask, isFixedLock)
    GameObjectHelper.FastSetActive(self.valueBottom, isLock)
    GameObjectHelper.FastSetActive(self.fixedLock, isFixedLock)
    GameObjectHelper.FastSetActive(self.lock, isOtherLock)
    self.desc.text = desc
    self.value.text = ""
end

function PlayerListCardView:SetCardTip(hasSign)
    GameObjectHelper.FastSetActive(self.redPoint, hasSign)
end

function PlayerListCardView:SetSellState(isSelected)
    GameObjectHelper.FastSetActive(self.info, true)
    GameObjectHelper.FastSetActive(self.sell, isSelected)
end

function PlayerListCardView:SetLockState(isLock)
    GameObjectHelper.FastSetActive(self.lock, isLock)
    GameObjectHelper.FastSetActive(self.lock, not isLock)
end

function PlayerListCardView:SetNameBg(isShow)
    GameObjectHelper.FastSetActive(self.nameBg, isShow)
end

return PlayerListCardView
