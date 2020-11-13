local CardPowerCtrl = class()

function CardPowerCtrl:ctor(powerParent, totalTime, powerNums, intervalValue, crossTime, maxValue)
    local powerObj, powerSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Power.prefab")
    powerObj.transform:SetParent(powerParent, false)
    self.view = powerSpt
    self:InitWithProtocol(totalTime, powerNums, intervalValue, crossTime, maxValue)
end

local TotalTime = 3 -- @param TotalTime 战力翻动最大时间
local PowerNums = 6 -- @param PowerNums 战力使用个数
local IntervalValue = 5 -- @param IntervalValue 每位战力值翻5个数
local MaxValue = 10 -- @param MaxValue 0-9 共十位数
local CrossTime = 0.03 -- @param CrossTime 动画单次循环时间
function CardPowerCtrl:InitWithProtocol(totalTime, powerNums, intervalValue, crossTime, maxValue)
    local totalTime = totalTime or TotalTime
    local powerNums = powerNums or PowerNums
    local intervalValue = intervalValue or IntervalValue
    local crossTime = crossTime or CrossTime
    local maxValue = maxValue or MaxValue
    local time = totalTime / powerNums
    local intervalTime = time / 2

    self.view:InitPowerEffect(powerNums, intervalValue, maxValue, crossTime, time, intervalTime)
end

function CardPowerCtrl:InitPower(power, isInit)
    self.view:InitPower(power, isInit)
end

return CardPowerCtrl
