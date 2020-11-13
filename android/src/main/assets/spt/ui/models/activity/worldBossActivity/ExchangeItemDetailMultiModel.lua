local Model = require("ui.models.Model")

local ExchangeItemDetailMultiModel = class(Model, "ExchangeItemDetailMultiModel")

--[[ data = {
    maxExchangeNum：最大兑换数量
    rewardName：兑换物品的名称
    outContent: 兑换出的物品列表
    exchangeId：兑换事件id，服务器用

    outContent = {      -- 一般是一个
        item = {
            {
                id = 25001,
                num = "1"
            }
        }
    }
}
--]]

function ExchangeItemDetailMultiModel:ctor(data)
    self.data = data
    self.exchangeCount = 1
    if tonumber(self.data.maxExchangeNum) > 9999 then self.data.maxExchangeNum = 9999 end
end

function ExchangeItemDetailMultiModel:GetExchangeId()
    return self.data.exchangeId
end

function ExchangeItemDetailMultiModel:GetExchangeCount()
    return self.exchangeCount
end

function ExchangeItemDetailMultiModel:SetExchangeCount(exchangeCount)
    self.exchangeCount = exchangeCount
end

function ExchangeItemDetailMultiModel:GetItemMaxExchangeNum()
    return self.data.maxExchangeNum or 1
end

function ExchangeItemDetailMultiModel:GetItemName()
    return self.data.rewardName
end

function ExchangeItemDetailMultiModel:GetOutContent()
    return self.data.outContent
end

return ExchangeItemDetailMultiModel