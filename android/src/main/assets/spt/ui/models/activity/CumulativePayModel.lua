local ActivityModel = require("ui.models.activity.ActivityModel")
local CumulativePayModel = class(ActivityModel)

function CumulativePayModel:InitWithProtocol()
end

local SPECIAL_SHOW_VALUE = 2
function CumulativePayModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function CumulativePayModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function CumulativePayModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function CumulativePayModel:GetRemainTime()
    return self:GetActivitySingleData().remainTime
end

function CumulativePayModel:GetRewardData()
    return self:GetActivitySingleData().list
end

function CumulativePayModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function CumulativePayModel:GetCurrentConsumeDiamondNumber()
    return self:GetActivitySingleData().value
end

function CumulativePayModel:GetConsumeDiamondNumberByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function CumulativePayModel:GetRewardConditionByIndex(index)
    return self:GetActivitySingleData().list[index].condition
end

function CumulativePayModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function CumulativePayModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function CumulativePayModel:GetSpecialShowByIndex(index)
    local specialShow = self:GetActivitySingleData().list[index].specialShow or defaultSpecialShow
    return specialShow
end

function CumulativePayModel:IsShowDefaultItemBg(index)
    local specialShow = tonumber(self:GetSpecialShowByIndex(index))
    local isDefaultBg = specialShow ~= SPECIAL_SHOW_VALUE
    return isDefaultBg
end

function CumulativePayModel:GetCornerTipByIndex(index)
    local cornerTip = self:GetActivitySingleData().list[index].tabShow or ""
    return cornerTip
end

-- 特殊奖励的展示
function CumulativePayModel:GetDisplayReward()
    local data = self:GetActivitySingleData()
    local list = data.list
    local rewardList = {}
    for i,v in ipairs(list) do
        if v.display and type(v.display) == "table" then
            for itemType,itemValue in pairs(v.display) do
                if type(itemValue) == "table" then
                    for index,itemContent in ipairs(itemValue) do
                        local temp = {}
                        temp.condition = v.condition
                        temp.display = {}
                        temp.display[itemType] = {itemContent}
                        table.insert(rewardList, temp)
                    end
                else
                    local temp = {}
                    temp.condition = v.condition
                    temp.display = {}
                    temp.display[itemType] = itemValue
                    table.insert(rewardList, temp)
                end
            end
        end
    end
    return rewardList
end

return CumulativePayModel
