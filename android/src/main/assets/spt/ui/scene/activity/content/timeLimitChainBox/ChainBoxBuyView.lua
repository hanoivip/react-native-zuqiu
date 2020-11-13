local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ChainBoxState = require("ui.scene.activity.content.timeLimitChainBox.ChainBoxState")
local ChainBoxLimitType = require("ui.scene.activity.content.timeLimitChainBox.ChainBoxLimitType")

local ChainBoxBuyView = class(unity.base)

function ChainBoxBuyView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.contentTrans = self.___ex.contentTrans
    self.itemCountGo = self.___ex.itemCountGo
    self.minusBtn = self.___ex.minusBtn
    self.addBtn = self.___ex.addBtn
    self.buyCountTxt = self.___ex.buyCountTxt
    self.discountDiamondGo = self.___ex.discountDiamondGo
    self.discountBkdGo = self.___ex.discountBkdGo
    self.discountPriceTxt = self.___ex.discountPriceTxt
    self.diamondGo = self.___ex.diamondGo
    self.bkdGo = self.___ex.bkdGo
    self.priceTxt = self.___ex.priceTxt
    self.limitTypeTxt = self.___ex.limitTypeTxt
    self.buyBtn = self.___ex.buyBtn
--------End_Auto_Generate----------
    self.buyButton = self.___ex.buyButton
    self.boardTrans = self.___ex.boardTrans
    self.buyCount = 1  -- 实际购买次数
    self.minCount = 0  -- 最小购买次数
    self.maxCount = 0  -- 最大购买次数
end

function ChainBoxBuyView:start()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    self.buyBtn:regOnButtonClick(function()
        if self.onBuy then
            self.onBuy()
        end
    end)
    local pressAddData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:AddBuyCount()
        end,
        durationCallback = function(count)
            self:AddBuyCount()
        end,
    }
    self.addBtn:regOnButtonPressing(pressAddData)
    self.addBtn:regOnButtonUp(function()
        self.hasShownDiamondNotEnough = false
    end)
    local pressMinusData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:MinusBuyCount()
        end,
        durationCallback = function(count)
            self:MinusBuyCount()
        end,
    }
    self.minusBtn:regOnButtonPressing(pressMinusData)
end

function ChainBoxBuyView:InitView(chainBoxData)
    self.chainBoxData = chainBoxData
    self:InitMinAndMaxArea()
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.contentTrans)
    local rewardParams = {
        parentObj = self.contentTrans,
        rewardData = chainBoxData.contents,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    GameObjectHelper.FastSetActive(self.diamondGo, chainBoxData.currencyType == CurrencyType.Diamond)
    GameObjectHelper.FastSetActive(self.bkdGo, chainBoxData.currencyType == CurrencyType.BlackDiamond)
    GameObjectHelper.FastSetActive(self.discountDiamondGo, chainBoxData.currencyType == CurrencyType.Diamond)
    GameObjectHelper.FastSetActive(self.discountBkdGo, chainBoxData.currencyType == CurrencyType.BlackDiamond)
    self.buyButton.interactable = chainBoxData.clientBoxState == ChainBoxState.Buy
    self.priceTxt.text = "x" .. chainBoxData.price
    self.discountPriceTxt.text = "x" .. chainBoxData.originPrice
    self.buyCountTxt.text = tostring(self.buyCount)
end

function ChainBoxBuyView:InitMinAndMaxArea()
    local itemCountGoState = false
    local sizeDelta = Vector2(622, 468)
    if self.chainBoxData.limitType == ChainBoxLimitType.None then
        self.minCount = 1
        self.maxCount = 99
        itemCountGoState = true
        self.limitTypeTxt.text = lang.trans("limit_type0")
    else
        local buyCount = self.chainBoxData.buyCount
        local limitAmount = self.chainBoxData.limitAmount
        if buyCount >= limitAmount then
            itemCountGoState = false
            self.buyCount = 0
            self.minCount = 0
            self.maxCount = 0
            sizeDelta = Vector2(622, 396)
        else
            itemCountGoState = true
            self.buyCount = 1
            self.minCount = 1
            self.maxCount = limitAmount - buyCount
        end
        local leftCount = limitAmount - buyCount
        if self.chainBoxData.limitType == ChainBoxLimitType.Day then
            self.limitTypeTxt.text = lang.transstr("limit_type1") .. ":" .. leftCount .. "/" .. limitAmount
        else
            self.limitTypeTxt.text = lang.transstr("limit_type2") .. ":" .. leftCount .. "/" .. limitAmount
        end
    end
    if self.maxCount <= 1 then
        sizeDelta = Vector2(622, 396)
        itemCountGoState = false
    end
    if self.chainBoxData.clientBoxState ~= ChainBoxState.Buy then
        itemCountGoState = false
    end
    GameObjectHelper.FastSetActive(self.itemCountGo, itemCountGoState)
    self.boardTrans.sizeDelta = sizeDelta
end

function ChainBoxBuyView:MinusBuyCount()
    if self.buyCount > self.minCount then
        self.buyCount = self.buyCount - 1
    end
    self.priceTxt.text = "x" .. self.chainBoxData.price * self.buyCount
    self.discountPriceTxt.text = "x" .. self.chainBoxData.originPrice * self.buyCount
    self.buyCountTxt.text = tostring(self.buyCount)
end

function ChainBoxBuyView:AddBuyCount()
    if self.buyCount < self.maxCount then
        self.buyCount = self.buyCount + 1
    end
    self.priceTxt.text = "x" .. self.chainBoxData.price * self.buyCount
    self.discountPriceTxt.text = "x" .. self.chainBoxData.originPrice * self.buyCount
    self.buyCountTxt.text = tostring(self.buyCount)
end

function ChainBoxBuyView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return ChainBoxBuyView
