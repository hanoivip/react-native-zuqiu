local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local GeneralEventModel = require("ui.models.greensward.event.GeneralEventModel")
local LotteryEventModel = class(GeneralEventModel, "LotteryEventModel")

local RewardTitle = {
    "lottery_first",
    "lottery_second",
    "lottery_third",
}

function LotteryEventModel:ctor()
    LotteryEventModel.super.ctor(self)
end

function LotteryEventModel:SetRewardData(rewardData)
    self.rewardData = rewardData.cellResult
    self.level = rewardData.level
end

function LotteryEventModel:GetRewardLevel()
    return self.level
end

function LotteryEventModel:GetRewardData()
    return self.rewardData
end

function LotteryEventModel:GetRewardTitle()
    local rewardData = self:GetRewardData()
    if next(rewardData.contents) then
        local level = self:GetRewardLevel()
        return RewardTitle[level]
    end
end

function LotteryEventModel:GetRewardContent()
    local rewardData = self:GetRewardData()
    if next(rewardData.contents) then
        return self:GetLotteryContentNames(rewardData.contents)
    end
end

function LotteryEventModel:InitWithProtocolLottery(data)
    self.lotteryData = data
end

function LotteryEventModel:GetLotteryList()
    return self.lotteryData
end

-- 拼出来个符合策划要求的物品描述字符
function LotteryEventModel:GetLotteryRewardDesc()
    local lotteryData = self:GetLotteryList()
    local sortLottery = {}
    for i, v in pairs(lotteryData) do
        sortLottery[tonumber(i)] = v
    end
    local rewardStr = ""
    for i, v in ipairs(sortLottery) do
        local contents = v.contents
        local title = RewardTitle[i]
        if title then
            title = lang.transstr(title)
        else
            title = ""
        end
        rewardStr = rewardStr .. title
        local names = self:GetLotteryContentNames(contents)
        rewardStr = rewardStr .. names .. "\n"
    end
    return rewardStr
end

function LotteryEventModel:GetLotteryContentNames(contents)
    local rewardStr = ""
    if type(contents) then
        for itemType, value in pairs(contents) do
            if type(value) == "number" then
                local n = RewardNameHelper.GetTypeName(nil, itemType)
                rewardStr = rewardStr .. n .. " *" .. value .. "  "
            else
                if type(value) == "table" then
                    for t, itemDetail in ipairs(value) do
                        local n = RewardNameHelper.GetTypeName(itemDetail, itemType)
                        if n then
                            local num = itemDetail.add or itemDetail.num or ""
                            rewardStr = rewardStr .. n .. " *" .. num .. "  "
                        end
                    end
                end
            end
        end
    end
    return rewardStr
end

function LotteryEventModel:HasTweenExtension()
    return true
end

return LotteryEventModel
