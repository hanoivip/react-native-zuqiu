local Model = require("ui.models.Model")
local EventSystem = require("EventSystem")

local TransferMarketModel = class(Model)

function TransferMarketModel:ctor()
    TransferMarketModel.super.ctor(self)
end

function TransferMarketModel:InitWithProtocol(transferData)
    local data = cache.getTransferInfo()
    if not data then
        cache.setTransferInfo(transferData.info)
        self:Init(transferData.info)
    else 
        self.cacheData = data
        for k, v in pairs(self.cacheData) do
            self.cacheData[k] = transferData.info[k]
        end
        for i, v in ipairs(self.cacheData.cards) do
            v.pos = i
        end
    end
end

function TransferMarketModel:Init(data)
    if not data then
        data = cache.getTransferInfo()
    end
    self.cacheData = data

    if self.cacheData then
        for i, v in ipairs(self.cacheData.cards) do
            v.pos = i
        end
    end
end

-- 设置免费刷新剩余次数
function TransferMarketModel:SetFreeRefreshRemainCount(count)
    self.cacheData.cnt = count
end

-- 获取免费刷新剩余次数
function TransferMarketModel:GetFreeRefreshRemainCount()
    return self.cacheData.cnt
end

-- 刷新钻石价格
function TransferMarketModel:GetRefreshDiamondCost()
    return self.cacheData.diamondRefreshCost
end

-- 设置免费次数获得倒计时
function TransferMarketModel:SetRefreshRecoverTime(recoverTime)
    self.cacheData.recoverTime = recoverTime
end

-- 获取免费次数获得倒计时
function TransferMarketModel:GetRefreshRecoverTime()
    return self.cacheData.recoverTime
end

function TransferMarketModel:GetChargeResfreshTime()
    return self.cacheData.diamondRefreshMax - self.cacheData.dCnt
end

-- 球员列表
function TransferMarketModel:GetPlayerList()
    return self.cacheData.cards
end

-- 球员卡cid
function TransferMarketModel:GetPlayerCardCid(pos)
    for i, cardData in ipairs(self.cacheData.cards) do
        if cardData.pos == pos then
            return cardData.cid
        end
    end
end

-- 球员卡价格
function TransferMarketModel:GetPlayerCardPrice(pos)
    for i, cardData in ipairs(self.cacheData.cards) do
        if cardData.pos == pos then
            return cardData.price
        end
    end
end

-- 球员来信   1来信，0没有
function TransferMarketModel:GetPlayerCardLetter(pos)
    for i, cardData in ipairs(self.cacheData.cards) do
        if cardData.pos == pos then
            return tonumber(cardData.activityLetter) == 1
        end
    end
end

-- 球员卡签约状态
function TransferMarketModel:GetPlayerCardSign(pos)
    for i, cardData in ipairs(self.cacheData.cards) do
        if cardData.pos == pos then
            if cardData.sign == 1 then
                return true
            else
                return false
            end
        end
    end
end

function TransferMarketModel:UpdateCacheData()
    EventSystem.SendEvent("TransferMarketModel_UpdateCacheData")
end

return TransferMarketModel