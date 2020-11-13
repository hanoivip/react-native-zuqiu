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
    self.nameTxt = self.___ex.name
    self.redPoint = self.___ex.redPoint
    self.startSign = self.___ex.startSign
    self.benchSign = self.___ex.benchSign
    self.powerSign = self.___ex.powerSign
	self.featureSign = self.___ex.featureSign
    self.powerText = self.___ex.powerText
    self.own = self.___ex.own
    self.message = self.___ex.message
    self.nameBg = self.___ex.nameBg
    -- 传奇记忆标识
    self.memorySign = self.___ex.memorySign
    -- 自定义标签
    self.customTagTxt = self.___ex.customTagTxt
    self.customTagBtn = self.___ex.customTagBtn
    -- 球员助阵标记
    self.supportedSign = self.___ex.supportedSign
    self.supporterSign = self.___ex.supporterSign
end

function PlayerListCardView:start()
    self:regOnButtonClick(function()
        self:OnCardClick()
    end)
    self.customTagBtn:regOnButtonClick(function ()
        self:OnTabClick()
    end)
end

function PlayerListCardView:OnCardClick()
    if self.clickCard then
        self.clickCard()
    end
end

function PlayerListCardView:OnTabClick()
    res.PushDialog("ui.controllers.playerList.CustomTagBoardCtrl", self.tabModel, self.cid, self.customTagTxt)
end

local LetterMessageType = {[SortType.DEFAULT] = true, [SortType.QUALITY_FALL] = true, [SortType.QUALITY_RISE] = true, [SortType.NAME_FALL] = true,
                           [SortType.NAME_RISE] = true,[SortType.OBTAIN_ORDER_FALL] = true, [SortType.OBTAIN_ORDER_FALL] = true,}
function PlayerListCardView:InitView(cardModel, menuType, playerListModel, cardResourceCache, parentCtrl, showCustomTagBtn, tabModel)
    -- Card
    self.cid = cardModel:GetCid()
    if not self.cardView then
        local cardObject = Object.Instantiate(parentCtrl:GetCardRes())
        self.cardView = res.GetLuaScript(cardObject)
        cardObject.transform:SetParent(self.cardParent.transform, false)
        self.cardView:SetCardResourceCache(cardResourceCache)
        self.cardView:IsShowName(false)
    end
    self.cardView:InitView(cardModel)
    self.nameTxt.text = tostring(cardModel:GetName())
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

	local hasCoachFeature = cardModel:HasCoachFeature()
    local isSupporter = cardModel:IsSupportOtherCard()
    local isSupported = cardModel:IsHasSupportCard()
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
    local messageOpen = isInLetterMessage and LetterMessageType[menuTypeIndex]
        and not (lockType == LockType.CourtLock or lockType == LockType.BenchLock)
    GameObjectHelper.FastSetActive(self.message, messageOpen)
    GameObjectHelper.FastSetActive(self.startSign, lockType == LockType.CourtLock)
    GameObjectHelper.FastSetActive(self.benchSign, lockType == LockType.BenchLock)
    GameObjectHelper.FastSetActive(self.memorySign.gameObject, cardModel:IsMemoryLock())
    GameObjectHelper.FastSetActive(self.powerSign, isShowPower)
	GameObjectHelper.FastSetActive(self.featureSign, hasCoachFeature and not isSupported)
    GameObjectHelper.FastSetActive(self.supportedSign, isSupported)
    GameObjectHelper.FastSetActive(self.supporterSign, isSupporter)

    -- 图鉴获取标识
    if playerListModel.__cname == "CardIndexModel" then
        GameObjectHelper.FastSetActive(self.own, playerListModel:IsCardGeted(cardModel:GetCid()))
    end

    -- 在图鉴中有来信时关闭自定义标记按钮
    -- 关闭传奇/SSS品质的自定义标记功能
        local qualityLimit = cardModel:GetCardQuality() < 7
        GameObjectHelper.FastSetActive(self.customTagBtn.gameObject, showCustomTagBtn and not messageOpen and qualityLimit)
    -- 获取自定义标记信息
    if tabModel and not messageOpen then
        self.tabModel = tabModel
        local state = tabModel:GetStateByCid(self.cid)
        GameObjectHelper.FastSetActive(self.customTagTxt.gameObject, state and qualityLimit)
        local msg = tabModel:GetTagByCid(self.cid)
        self.customTagTxt.text = msg
    end
end

function PlayerListCardView:SetLockStateBySellPage(cardModel)
    local isFixedLock = false
    local isOtherLock = false
    --巅峰对决优先级搞
    if cardModel:IsInPeakLock() then
        isOtherLock = true
    elseif cardModel:IsInPlayingLock() or cardModel:IsInPlayingRepLock() then
        isFixedLock = true
    elseif cardModel:IsNotAllowSell() then
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

function PlayerListCardView:SetMessageState(isShow)
    GameObjectHelper.FastSetActive(self.message, isShow)
end

return PlayerListCardView
