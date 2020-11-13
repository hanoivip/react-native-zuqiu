local Model = require("ui.models.Model")
local LotteryBettingModel = class(Model, "LotteryBettingModel")

function LotteryBettingModel:ctor(listData)
    self.listData = listData
    self.moneyType = "money"
    self.diamondType = "diamond"
end

-- 获取赔率
function LotteryBettingModel:GetOdds(matchResult)
    if self:GetLotteryType() == self.diamondType then
        return self.listData.globalStakeInfo.d.odds[tostring(matchResult)]
    else
        return self.listData.globalStakeInfo.odds[tostring(matchResult)]
    end
end

-- 获取通过钻石和欧元选择面板 选择的钻石投注 或 欧元投注
function LotteryBettingModel:GetLotteryType()
    return self.listData.currentType
end

-- 获取自己的投注数
function LotteryBettingModel:GetSelfStakeInfo(matchResult)
    if self:GetLotteryType() == self.diamondType then
        return self.listData.selfStakeInfo.stake[tostring(matchResult)].stakeDiamondNumber or 0
    else
        return self.listData.selfStakeInfo.stake[tostring(matchResult)].stakeNumber or 0
    end
end

-- 检查当前选择项自己是否投注
function LotteryBettingModel:CheckCurrentStake(matchResult)
    return self.listData.selfStakeInfo and self.listData.selfStakeInfo.stake[tostring(matchResult)]
end

-- 检查自己是否投注三个选择项的任意一个
function LotteryBettingModel:CheckSelfStakeInfo()
    local selfStakeInfo = self.listData.selfStakeInfo
    if selfStakeInfo then
        return true
    else 
        return false
    end
end

-- 获取自己所有投注项投注的总和
function LotteryBettingModel:GetSelfStakeTotal()
    local selfStakeInfo = self.listData.selfStakeInfo.stake
    local matchStake = 0
    for k, v in pairs(selfStakeInfo) do
        if self:GetLotteryType() == self.diamondType then
            matchStake = matchStake + (v.stakeDiamondNumber or 0)
        elseif self:GetLotteryType() == self.moneyType then
            matchStake = matchStake + (v.stakeNumber or 0)
        end
    end
    return tonumber(matchStake)
end

-- 获取当前的 matchId
function LotteryBettingModel:GetMatchID()
    return self.listData.matchId
end

return LotteryBettingModel