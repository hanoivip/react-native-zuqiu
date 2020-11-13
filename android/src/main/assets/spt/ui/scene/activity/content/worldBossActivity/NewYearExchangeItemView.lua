local GameObjectHelper = require("ui.common.GameObjectHelper")
local WorldBossItem = require("data.WorldBossItem")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local LimitType = require("ui.scene.itemList.LimitType")
local ItemModel = require("ui.models.ItemModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local UnityEngine = clr.UnityEngine
local Mathf = UnityEngine.Mathf
local ExchangeItemDetailMultiModel = require("ui.models.activity.worldBossActivity.ExchangeItemDetailMultiModel")

local NewYearExchangeItemView = class(unity.base)

function NewYearExchangeItemView:ctor()
    self.buyLimitTxt = self.___ex.buyLimitTxt
    self.exchangeBtn = self.___ex.exchangeBtn
    self.iconAear = self.___ex.iconAear
    self.giftAear = self.___ex.giftAear
    self.addObj = self.___ex.addObj
    self.sumObj = self.___ex.sumObj
    self.exchangeText = self.___ex.exchangeText
    self.gradientText = self.___ex.gradientText
    self.exchangeBtnCompent = self.___ex.exchangeBtnCompent
    self.rewardBtnEffect = self.___ex.rewardBtnEffect
end

function NewYearExchangeItemView:start()
    self.exchangeBtn:regOnButtonClick(function()
        self:OnRewardBtnClick()
    end)
end

function NewYearExchangeItemView:OnRewardBtnClick()
    if self.rewardCount and self.rewardName then
        -- 计算可以兑换的最大数目
        local maxItemHasCount = 0
        for k, v in pairs(self.itemData.itemHasCount) do
            if maxItemHasCount < self.itemData.itemHasCount[k] then
                maxItemHasCount = v
            end
        end

        local canExTable = {}
        for k, v in pairs(self.itemData.itemHasCount) do
            local canExNum = maxItemHasCount
            if self.itemData.exchangeContent[k] > 0 then
                canExNum = Mathf.Floor(self.itemData.itemHasCount[k] / self.itemData.exchangeContent[k])
            end
            table.insert(canExTable, canExNum)
        end
        table.sort(canExTable, function(a, b) return a < b end)
        local canEx = canExTable[1] or maxItemHasCount

        local maxExchangeNum = 1
        if self.itemData.limitType ~= LimitType.NoLimit then -- 有限购
            local hasNum = 0
            if self.exchangeContents[tostring(self.itemData.exchangeId)] then
                hasNum = self.exchangeContents[tostring(self.itemData.exchangeId)].count
            end
            maxExchangeNum = self.itemData.limitAmount - hasNum
            maxExchangeNum = Mathf.Min(maxExchangeNum, canEx)
        else -- 没有限购
            maxExchangeNum = canEx
        end

        if maxExchangeNum == 0 then
            DialogManager.ShowToast(lang.trans("newYearExchange_property_buyMax"))
            return
        end

        local multiData = {}
        multiData.maxExchangeNum = maxExchangeNum
        multiData.rewardName = self.rewardName
        multiData.outContent = self.itemData.outContent
        multiData.exchangeId = self.itemData.exchangeId

        local exchangeModel = ExchangeItemDetailMultiModel.new(multiData)
        res.PushDialog("ui.controllers.activity.content.worldBossActivity.ExchangeItemDetailMultiCtrl", exchangeModel, self.onRewardBtnClick)
    end
end

local MyContents = {exchangeItem = {{id = "", num = 1}}}
function NewYearExchangeItemView:InitView(itemData, exchangeContents)
    self.itemData = itemData
    self.isCanExchange = true
    self.exchangeContents = exchangeContents or {item = {}}
    local exchangeCount =  self.exchangeContents[tostring(itemData.exchangeId)] and (itemData.limitAmount - self.exchangeContents[tostring(itemData.exchangeId)].count) or itemData.limitAmount
    self.buyLimitTxt.text = self:GetLimitTitle(itemData.limitType, exchangeCount, itemData.limitAmount)
    local index = 1
    local haveShow = false
    for k,v in pairs(itemData.exchangeContent) do
        local isShow = not (v == 0)
        self.iconAear[tostring(index)]:SetActive(isShow)
        self.addObj[tostring(index)]:SetActive(isShow)
        if isShow then
            if (self.exchangeContents.item[k] or 0) < v then
                self.isCanExchange = false
            end
            res.ClearChildren(self.iconAear[tostring(index)].transform)
            local contents = MyContents
            contents.exchangeItem[1].num = v
            contents.exchangeItem[1].id = k
            local rewardParams = {
                parentObj = self.iconAear[tostring(index)],
                rewardData = contents,
                isShowName = false,
                isReceive = false,
                isShowBaseReward = true,
                isShowCardReward = true,
                isShowDetail = true,
                hideCount = false
            }
            RewardDataCtrl.new(rewardParams)
            if not haveShow then
                self.addObj[tostring(index)]:SetActive(false)
            end
            haveShow = true
        end
        index = index + 1
    end
    res.ClearChildren(self.giftAear.transform)
    local rewardParams = {
        parentObj = self.giftAear,
        rewardData = itemData.outContent,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = false
    }
    self:GetRewardNameAndCount(itemData.outContent)
    RewardDataCtrl.new(rewardParams)
    self:SetButtonState(self.isCanExchange)
end

function NewYearExchangeItemView:GetLimitTitle(limitType, exchangeCount, limitAmount)
    if limitType == LimitType.NoLimit then
        self.isCanExchange = true
        return ""
    elseif limitType == LimitType.DayLimit then
        self.isCanExchange = exchangeCount > 0
        return lang.trans("newYearExchange_property_day_buyLimit", exchangeCount, limitAmount)
    elseif limitType == LimitType.ForeverLimit then
        self.isCanExchange = exchangeCount > 0
       return lang.trans("newYearExchange_property_buyLimit", exchangeCount, limitAmount)
    end
end

function NewYearExchangeItemView:SetButtonState(isOpen)
    self.exchangeBtn:onPointEventHandle(isOpen)
    self.exchangeBtnCompent.interactable = isOpen
    self.rewardBtnEffect:SetActive(isOpen)
    local r, g, b 
    self.gradientText.enabled = isOpen
    if isOpen then 
        r, g, b = 145, 125, 86
    else
        r, g, b = 125, 125, 125
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    self.exchangeText.color = color
end

function NewYearExchangeItemView:GetRewardNameAndCount(outContent)
    if outContent then
        self.rewardName = ""
        self.rewardCount = ""
        if type(outContent.item) == "table" then
            local itemModel = ItemModel.new(outContent.item[1].id)
            self.rewardName = itemModel:GetName()
            self.rewardCount = outContent.item[1].num
        end

        if type(outContent.cardPiece) == "table" then
            local cardPieceModel = CardPieceModel.new()
            local cardData = outContent.cardPiece[1]
            local newData = {cid = cardData.id}
            cardPieceModel:InitWithCache(newData)
			local name = cardPieceModel:GetName() or ""
            self.rewardName = name .. lang.transstr("piece")
            self.rewardCount = outContent.cardPiece[1].num
        end

        if type(outContent.pasterPiece) == "table" then
            local cardPasterPieceModel = CardPasterPieceModel.new()
            local cardPasterData = outContent.pasterPiece[1]
            local newData = {type = cardPasterData.id}
            cardPasterPieceModel:InitWithCache(newData)
            self.rewardName = cardPasterPieceModel:GetName() -- .. lang.transstr("piece")
            self.rewardCount = outContent.pasterPiece[1].num
        end
    end
end

return NewYearExchangeItemView