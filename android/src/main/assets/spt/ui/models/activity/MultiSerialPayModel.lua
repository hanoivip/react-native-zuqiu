local ActivityModel = require("ui.models.activity.ActivityModel")
local MultiSerialPayModel = class(ActivityModel)

function MultiSerialPayModel:InitWithProtocol()
end

function MultiSerialPayModel:GetRewardSubIdByIndex(index)
    return self:GetActivitySingleData().list[index].subID
end

function MultiSerialPayModel:GetRewardStatusByIndex(index)
    return self:GetActivitySingleData().list[index].status
end

function MultiSerialPayModel:SetRewardStatusByIndex(index, value)
    self:GetActivitySingleData().list[index].status = value
end

function MultiSerialPayModel:GetCurrMoneyTag()
    if self.moneyTag == nil then
        self.moneyTag = self:GetDataList()[1].condition1
    end
    return self.moneyTag
end

function MultiSerialPayModel:SetCurrMoneyTag(tag)
    self.moneyTag = tag
    EventSystem.SendEvent("Money_Tag_Changed")
end

function MultiSerialPayModel:GetRewardData()
    local list = clone(self:GetDataList())
    local tag = self:GetCurrMoneyTag()
    local rewardList = {}

    for k, v in pairs(list) do
        if v.condition1 == tag then
            table.insert(rewardList, v)
        end
    end

    return rewardList
end

function MultiSerialPayModel:GetDataList()
    return self:GetActivitySingleData().list
end

function MultiSerialPayModel:GetActivityDesc()
    return self:GetActivitySingleData().desc
end

function MultiSerialPayModel:GetCurrentConsumeDiamondNumber()
    return self:GetActivitySingleData().value
end

function MultiSerialPayModel:GetConsumeDiamondNumberByIndex(index)
    return self:GetActivitySingleData().list[index].value
end

function MultiSerialPayModel:GetRewardConditionByIndex(index)
    return self:GetActivitySingleData().list[index].condition
end

function MultiSerialPayModel:GetPayDescByIndex(index)
    return self:GetActivitySingleData().list[index].conditionDesc
end

function MultiSerialPayModel:GetStartTime()
    return self:GetActivitySingleData().beginTime
end

function MultiSerialPayModel:GetEndTime()
    return self:GetActivitySingleData().endTime
end

function MultiSerialPayModel:GetServerTime()
    return self:GetActivitySingleData().currTime
end

function MultiSerialPayModel:GetPayPrice()
    return self:GetActivitySingleData().list[1].condition1
end

function MultiSerialPayModel:GetCostByIndex(index)
    return self:GetActivitySingleData().param[index]
end

function MultiSerialPayModel:GetMoneyList()
    local list = clone(self:GetDataList())
    local moneyList = {}
    for k, v in pairs(list) do
        local isHave = false
        local subList = {}
        subList.price = v.condition1

        for i, sub in ipairs(moneyList) do
            if sub.price == v.condition1 then
                isHave = true
            end
        end
        if not isHave then
            table.insert(moneyList, subList)
        end
    end

    for i, v in pairs(moneyList) do
        local index = self:GetTodayIndex()
        v.isFinish = self:GetCostByIndex(index) >= v.price
        v.isShowRedPoint = self:IsShowRedPointByMoney(v.price)
    end

    return moneyList
end

-- 获得活动期间，今日在params中的下标
function MultiSerialPayModel:GetTodayIndex()
    local currTime = self:GetServerTime()
    local beginTime = self:GetStartTime()
    local index = (currTime - beginTime) / (24 * 60 * 60)
    return math.floor(index) + 1
end

-- 当前价位是否显示可领奖的红点
function MultiSerialPayModel:IsShowRedPointByMoney(money)
    local list = clone(self:GetDataList())
    for k, v in pairs(list) do
        if money == v.condition1 then
            if v.status == 0 then
                return true
            end
        end
    end

    return false
end

function MultiSerialPayModel:GetHistoryTxt()
    local second = 24 * 60 * 60
    local startTime = self:GetStartTime()
    local txt = ""
    for i = 0, self:GetTodayIndex() - 1, 1 do
        local timeTable = string.convertSecondToYearAndMonthAndDay(startTime + i * second)
        txt = txt .. lang.transstr("multi_serial_pay_history", timeTable.year, string.format("%02d", timeTable.month), string.format("%02d", timeTable.day), i + 1, self:GetCostByIndex(i+1))
    end
    return txt
end


return MultiSerialPayModel