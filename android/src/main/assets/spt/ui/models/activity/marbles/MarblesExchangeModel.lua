local LimitType = require("ui.scene.itemList.LimitType")
local Model = require("ui.models.Model")
local MarblesExchangeModel = class(Model)
MarblesExchangeModel.RewardState = {}
MarblesExchangeModel.RewardState.Disable = 1
MarblesExchangeModel.RewardState.Enable = 2
MarblesExchangeModel.RewardState.Received = 3
local RewardState = MarblesExchangeModel.RewardState

function MarblesExchangeModel:ctor(marblesModel)
    self.marblesModel = marblesModel
end

function MarblesExchangeModel:InitWithProtocol(exchangeData)
    self.exchangeData = exchangeData
    self:InitExchangeList()
end

function MarblesExchangeModel:InitExchangeList()
    self.exchangeList = {}
    local ownItemsOrigin = self:GetOwnItemOrigin()
    for k, v in pairs(self.exchangeData.rewardList) do
        table.insert(self.exchangeList, v)
        local isLimit = false
        if v.limitType ~= LimitType.NoLimit then
            isLimit = v.receiveTimes >= v.limitAmount
        end
        if v.exchangeItemCumulative then
            local t = {}
            t.mei = {}
            v.rewardState = RewardState.Enable
            for itemID, num in pairs(v.exchangeItemCumulative) do
                local ti = {}
                local itemNum = tonumber(num)
                ti.id = tostring(itemID)
                ti.num = itemNum
                table.insert(t.mei, ti)
                if not isLimit then
                    if ownItemsOrigin[itemID] < itemNum then
                        v.rewardState = RewardState.Disable
                    end
                else
                    v.rewardState = RewardState.Received
                end
            end
            v.fixExchangeItem = t
        end
    end
    table.sort(self.exchangeList, function(a, b) return a.rewardID < b.rewardID end)
end

function MarblesExchangeModel:GetExchangeList()
    return self.exchangeList or {}
end

function MarblesExchangeModel:GetMarblesModel()
    return self.marblesModel
end

function MarblesExchangeModel:GetOwnItemOrigin()
    local ownItem = self.marblesModel:GetOwnItemOrigin()
    return ownItem
end

function MarblesExchangeModel:GetOwnItem()
    local ownItem = self.marblesModel:GetOwnItem()
    return ownItem
end

function MarblesExchangeModel:GetPeriodId()
    local periodId = self.marblesModel:GetPeriodId()
    return periodId
end

function MarblesExchangeModel:RefreshData(data)
    local rewardId = tostring(data.rewardId)
    local rewardList = self.exchangeData.rewardList
    local reward = rewardList[rewardId]
    local receiveTimes = reward.receiveTimes
    self.exchangeData.rewardList[rewardId].receiveTimes = receiveTimes + 1
    self:InitExchangeList()
end

return MarblesExchangeModel
