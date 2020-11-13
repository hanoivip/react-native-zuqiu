local CommonCost = require("data.CommonCost")
local Model = require("ui.models.Model")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local ExchangeModel = class(Model, "ExchangeModel")

local specialQuality = {["6+"] = true}

function ExchangeModel:ctor()
    ExchangeModel.super.ctor(self)
    local mysterySSExchange = CommonCost.mysterySSExchange 
    local ssExchangePrice = mysterySSExchange and mysterySSExchange.price[1] or {}
    self.mysterySSExchangeItemId = ssExchangePrice.id
    self.mysterySSExchangeItemNum = ssExchangePrice.num
    self.itemMapsModel = ItemsMapModel.new()
end

function ExchangeModel:Init(data)
    self.data = data or {}
end

function ExchangeModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function ExchangeModel:IsOpen()
    return self.data.isOpen
end

function ExchangeModel:GetBeExchangedCount()
    return self.data.e_cnt or 0
end

function ExchangeModel:GetMaxExchangeCount()
    return self.data.exchangeMaxCount or 0
end

function ExchangeModel:SetBeExchangedCount(beExchangedCount)
    self.data.e_cnt = beExchangedCount
end

function ExchangeModel:GetExchangeCount()
    local maxExchangeCount = self:GetMaxExchangeCount()
    local beExchangedCount = self:GetBeExchangedCount()
    local exchangeCount = maxExchangeCount - beExchangedCount
    if exchangeCount < 0 then exchangeCount = 0 end
    return exchangeCount
end

function ExchangeModel:HasExchangeCount()
    local exchangeCount = self:GetExchangeCount()
    return tobool(exchangeCount > 0)
end

function ExchangeModel:CanExchange(targetPcid)
    local cardModel = SimpleCardModel.new(targetPcid)
    local quality = cardModel:GetCardQuality()
    local qualitySpecial = cardModel:GetCardQualitySpecial()
    local fixedQuality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
    -- 特殊处理 6+ 品质需要道具
    if specialQuality[fixedQuality] then
        local count = self:GetExchangeItemCount()
        local needCount = self:GetNeedExchangeItemCount()
        return  count >= needCount
    end
    return true
end

function ExchangeModel:IsSpecialCard(targetPcid)
    local cardModel = SimpleCardModel.new(targetPcid)
    local quality = cardModel:GetCardQuality()
    local qualitySpecial = cardModel:GetCardQualitySpecial()
    local fixedQuality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
    -- 特殊处理 6+ 品质需要道具
    if specialQuality[fixedQuality] then
        return true
    end
    return false
end

function ExchangeModel:GetNeedExchangeItemName()
    local rewardTable = {}
    rewardTable.item = CommonCost.mysterySSExchange.price
    return  RewardNameHelper.GetSingleContentName(rewardTable)
end

function ExchangeModel:GetNeedExchangeItemCount()
    return self.mysterySSExchangeItemNum or 1
end

function ExchangeModel:GetExchangeItemCount()
    local count = self.itemMapsModel:GetItemNum(self.mysterySSExchangeItemId)
    return count or 0
end

function ExchangeModel:SetBeExchangedCost(cost)
    self.itemMapsModel:UpdateFromReward(cost)
end

return ExchangeModel