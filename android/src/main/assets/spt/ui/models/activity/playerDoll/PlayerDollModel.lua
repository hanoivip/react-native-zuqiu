local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local PlayerDollModel = class(ActivityModel, "PlayerDollModel")

-- 任务状态
PlayerDollModel.RewardState = {
    CanNotReceive = "CanNotReceive",
    CanReceive = "CanReceive",
    Received = "Received"
}

local rewardImgMaxCount = 7

function PlayerDollModel:ctor(data)
    PlayerDollModel.super.ctor(self, data)
end

function PlayerDollModel:InitWithProtocol()
    if table.isEmpty(self.singleData) then return end
    self.requestTime = Time.realtimeSinceStartup
end

-- 是否从未启动娃娃机
function PlayerDollModel:IsFirstTime()
    return self.singleData.first == 0
end

-- 设置是否从未启动娃娃机
function PlayerDollModel:SetFirstTime(value)
    self.singleData.first = value
end

-- 获取活动类型
function PlayerDollModel:GetActivityType()
    return self.singleData.activityType
end

-- 获取活动档位信息
function PlayerDollModel:GetChoseRewardCount()
    return self.singleData.baseInfo.choseRewardCount
end

-- 获取活动档位所需奖品数量
function PlayerDollModel:GetChoseRewardCountByGrade(grade)
    local choseRewardCount = self:GetChoseRewardCount()
    return choseRewardCount[grade]
end

-- 获取当前档位
function PlayerDollModel:GetCurGrade()
    return self.curGrade or 1
end

-- 修改当前档位
function PlayerDollModel:SetCurGrade(grade)
    self.curGrade = grade
end

-- 获取消耗类型（钻石/豪门币...）
function PlayerDollModel:GetCurrencyType()
    return self.singleData.baseInfo.currencyType
end

-- 获取抽奖一次的消耗
function PlayerDollModel:GetOnePrice()
    return self.singleData.baseInfo.onePrice
end

-- 获取抽奖五次的消耗
function PlayerDollModel:GetFivePrice()
    return self.singleData.baseInfo.fivePrice
end

-- 获取活动开始时间
function PlayerDollModel:GetBeginTime()
    return self.singleData.beginTime
end

-- 获取活动结束时间
function PlayerDollModel:GetEndTime()
    return self.singleData.endTime
end

-- 获取活动剩余时间
function PlayerDollModel:GetRemainTime()
    local serverTime = self.singleData.serverTime
    local realtimeSinceStartup = Time.realtimeSinceStartup
    local nowTime = serverTime + realtimeSinceStartup - self.requestTime
    local endTime = self:GetEndTime()
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

--获取累计次数奖励信息
function PlayerDollModel:GetCountRewardList()
    return self.singleData.countRewardList
end

--获取累计次数奖励信息(按次数排列)
function PlayerDollModel:GetCountRewardListSorted()
    local sortedList = {}
    local rewardList = self:GetCountRewardList()
    for id, reward in pairs(rewardList) do
        table.insert(sortedList, {id = id, reward = reward})
    end
    table.sort(sortedList, function (a, b) return a.reward.count < b.reward.count end)
    return sortedList
end

-- 获得累计使用的次数
function PlayerDollModel:GetDollCnt()
    return self.singleData.dollCnt or {}
end

-- 设置累计使用的次数
function PlayerDollModel:SetDollCnt(num)
    self.singleData.dollCnt = num
end

-- 获取期数
function PlayerDollModel:GetPeriodId()
    return self.singleData.id
end

-- 获取所有奖品信息
function PlayerDollModel:GetRewardList()
    return self.singleData.rewardList
end

-- 检查奖品所属档位
function PlayerDollModel:GetRewardGrad(rewardId)
    local rewardList = self:GetRewardList()
    return rewardList[rewardId].rewardType
end

-- 设置心仪奖品
function PlayerDollModel:SetWantedReward(id, isWanted)
    local rewardList = self:GetRewardList()
    rewardList[id].select = isWanted
end

-- 获取奖品选择状态
function PlayerDollModel:IsRewardWanted(id)
    local rewardList = self:GetRewardList()
    return rewardList[id].select
end

-- 检查任务是否可领取
function PlayerDollModel:CanGetCountReward(countRewardId)
    local countRewardList = self:GetCountRewardList()
    local countReward = countRewardList[countRewardId]
    local canReceive = self:IsCountRewardFinished(countRewardId)
    return not countReward.receive and canReceive
end

-- 检查任务是否完成
function PlayerDollModel:IsCountRewardFinished(countRewardId)
    local countRewardList = self:GetCountRewardList()
    local countReward = countRewardList[countRewardId]
    local dollCnt = self:GetDollCnt()
    return dollCnt >= countReward.count
end

-- 获取任务状态
function PlayerDollModel:GetCountRewardState(countRewardId)
    local rewardState = self.RewardState.CanNotReceive
    if self:CanGetCountReward(countRewardId) then
        rewardState = self.RewardState.CanReceive
    elseif self:IsCountRewardFinished(countRewardId) then
        rewardState = self.RewardState.Received
    end
    return rewardState
end

-- 设置任务状态-已完成
function PlayerDollModel:SetCountRewardFinished(countRewardId)
    local countRewardList = self:GetCountRewardList()
    local countReward = countRewardList[countRewardId]
    countReward.receive = true
end

-- 获取奖池档位奖品
function PlayerDollModel:GetGradeRewardList(grade)
    local gradeRewardList = {}
    local rewardList = self:GetRewardList()
    for id, detail in pairs(rewardList) do
        if detail.rewardType == grade then
            gradeRewardList[id] = rewardList[id]
        end
    end
    return gradeRewardList
end

-- 获取奖池所需奖品数量
function PlayerDollModel:GetRewardsNum()
    local totalNum = 0
    local defaultRewardList = self:GetGradeRewardList(0)
    for id, defaultReward in pairs(defaultRewardList) do
        totalNum = totalNum + 1
    end
    local choseRewardCount = self:GetChoseRewardCount()
    for grade, count in pairs(choseRewardCount) do
        totalNum = totalNum + count
    end
    return totalNum
end

-- 获取档位中选择的奖品
function PlayerDollModel:GetGradeRewardsSelected(grade)
    local rewardSelectList = {}
    local rewardList = self:GetGradeRewardList(grade)
    for id, reward in pairs(rewardList) do
        if reward.select then
            rewardSelectList[id] = reward
        end
    end
    return rewardSelectList
end

-- 获取选中的ID
function PlayerDollModel:GetSelectedIdArr()
    local sortedList = {}
    local rewardList = self:GetRewardList()
    for id, reward in pairs(rewardList) do
        if reward.select and reward.rewardType ~= 0 then
            table.insert(sortedList, {id = id, reward = reward})
        end
    end 
    table.sort(sortedList, function (a, b) return a.reward.order < b.reward.order end)
    local selectedIdArr = {}
    local i = 0
    for index, reward in pairs(sortedList) do
        i = i + 1
        selectedIdArr[i] = reward.id
    end
    return selectedIdArr
end

-- 档位中选取的奖品数量是否已满
function PlayerDollModel:IsRewardsFullFilledById(rewardId)
    local selectedNum = 0
    local grade = self:GetRewardGrad(rewardId)
    local gradeRewardList = self:GetGradeRewardList(grade)
    for id, detail in pairs(gradeRewardList) do
        if detail.select then
            selectedNum = selectedNum +1
        end
    end
    local countNum = self:GetChoseRewardCountByGrade(tostring(grade))
    return selectedNum == tonumber(countNum)
end

-- 奖池中的奖品是否选取足够
function PlayerDollModel:IsRewardsFullFilled()
    local needNum = self:GetRewardsNum()
    local rewardList = self:GetSortedRewardList()
    local num = #rewardList
    return  needNum == num
end

-- 获取奖池中排序好的奖品
function PlayerDollModel:GetSortedRewardList()
    local sortedList = {}
    local rewardList = self:GetRewardList()
    for id, reward in pairs(rewardList) do
        if reward.select then
            table.insert(sortedList, {id = id, reward = reward})
        end
    end 
    table.sort(sortedList, function (a, b) return a.reward.order < b.reward.order end)
    return sortedList
end

-- 获得玩法说明
function PlayerDollModel:GetIntro()
    return 17, "TimeLimitPlayerDoll"
end

function PlayerDollModel:GetRewardImgMaxCount()
    return rewardImgMaxCount
end

return PlayerDollModel
