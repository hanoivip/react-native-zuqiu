local ActivityModel = require("ui.models.activity.ActivityModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GoldCupModel = class(ActivityModel)

function GoldCupModel:ctor(data)
    assert(type(data) == "table" and next(data), "data error!!!")
    self:CreateSelfVariables()
    GoldCupModel.super.ctor(self, data)
end

function GoldCupModel:CreateSelfVariables()
    self.rankingConditionMap = {}
    self.effectMaskPosition = 0
    self.lastEffectMaskPosition = 0
    self.isFirstEnterActivity = true
end

function GoldCupModel:InitWithProtocol()
    self:InitRankingConditionMap()
    self:RefreshRewardListForContentsCount()
    self:RefreshStageListForContentsCount()
end

function GoldCupModel:RefreshStageListForContentsCount()
    local stageRewardList = self:GetActivitySingleData().list
    assert(type(stageRewardList) == "table" and next(stageRewardList), "data error!!!")
    self:DataListPretreatment(stageRewardList)
end

function GoldCupModel:RefreshRewardListForContentsCount()
    local rewardList = self:GetRewardList()
    self:DataListPretreatment(rewardList)
end

function GoldCupModel:InitRankingConditionMap()
    self.rankingConditionMap = {}
    local rewardList = self:GetRewardList()
    assert(type(rewardList) == "table", "data error!!!")
    for k, v in pairs(rewardList) do
        assert(v.rankHigh and v.rankLow, "data error!!!")
        for i = tonumber(v.rankHigh), tonumber(v.rankLow) do
            self.rankingConditionMap[tostring(i)] = v.condition or 0
        end
    end
end

function GoldCupModel:GetConditionWithRank(rank)
    local condition = self.rankingConditionMap[tostring(rank)] or "-"
    return condition
end

function GoldCupModel:GetRankingList()
    local rankingList = self:GetActivitySingleData().rankBoard or {}
    if type(rankingList) ~= "table" then
        return {}
    end
    return rankingList
end

function GoldCupModel:GetStageRewardDataByIndex(index)
    local stageRewardList = self:GetActivitySingleData().list or {}
    local stageData = stageRewardList[index]
    assert(stageData, "data error!!!")
    return stageData
end

function GoldCupModel:GetRewardList()
    local rewardList = self:GetActivitySingleData().rankConfig or {}
    return rewardList
end

function GoldCupModel:GetMyPointValue()
    local myPoint = self:GetActivitySingleData().value or 0
    return myPoint
end

function GoldCupModel:GetCupPointsValue()
    local pointsValue = self:GetActivitySingleData().totalCount or 0
    return pointsValue
end

--only has a 4 stages 
function GoldCupModel:GetFullCupPointsValue()
    local four = 4
    local fullPointsValue = self:GetStagePointsByIndex(four)
    return fullPointsValue
end

function GoldCupModel:GetStagePointsByIndex(index)
    local stageData = self:GetStageRewardDataByIndex(index)
    local condition1 = stageData.condition1 or 0
    return condition1
end

function GoldCupModel:GetMyRankStr()
    local myRank = self:GetMyRank()
    local str = lang.transstr("peak_rankTitle")
    if not myRank then
        str = str .. lang.transstr("train_rankOut")
    else
        str = str .. myRank
    end
    return str
end

function GoldCupModel:GetMyRank()
    local myPid = PlayerInfoModel.new():GetID()
    local rankingList = self:GetRankingList()
    local myRank = nil
    for k, v in pairs(rankingList) do
        if type(v) == "table" then
            if v.pid and v.pid == myPid then
                myRank = k
                break
            end
        end
    end
    return myRank
end

function GoldCupModel:IsActivityEnd()
    local serverTimeNow = GetServerTimeNow()
    local activityEndTime = self:GetActivityEndTime()
    local isActivityEnd = serverTimeNow >= activityEndTime
    return isActivityEnd
end

function GoldCupModel:GetActivityDuration()
    local str = lang.transstr("activityTime")
    local beginTime = self:GetBeginTime()
    local activityEndTime = self:GetActivityEndTime()
    str = lang.trans("cumulative_pay_time", string.convertSecondToMonth(beginTime), 
                        string.convertSecondToMonth(activityEndTime))
    return str
end

function GoldCupModel:GetRemainTime()
    local activityEndTime = self:GetActivityEndTime()
    local serverTime = GetServerTimeNow()
    local remainTime = activityEndTime - serverTime
    return remainTime
end

function GoldCupModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime or 0
end

function GoldCupModel:GetActivityEndTime()
    return self:GetActivitySingleData().activityEndTime or 0
end

function GoldCupModel:DataListPretreatment(rewardList, coverTableName)
    for k, v in pairs(rewardList) do
        local count = 0
        local contentsTable = {}
        if not coverTableName then
            contentsTable = v.contents
        else
            contentsTable = v[coverTableName].contents
        end
        assert(type(contentsTable) == "table", "data error!!!")
        for key, value in pairs(contentsTable) do
            if type(value) == "table" then
                count = count + table.nums(value)
            else
                count = count + 1
            end
        end
        v.contentsCount = count
    end
end

function GoldCupModel:GetContributeStr(currency)
    local stageRewardList = self:GetActivitySingleData().list
    local consume = stageRewardList[1][currency] or 0
    local count = self:GetActivitySingleData()[currency .. "Count"] or 0
    local str = lang.transstr("goldCup_desc11", consume, consume * count)
    return str
end

function GoldCupModel:SetEffectMaskPosition(pos)
    self.effectMaskPosition = pos or 0
end

function GoldCupModel:GetEffectMaskPosition()
    return self.effectMaskPosition or 0
end
    
function GoldCupModel:SetLastEffetMaskPosition(pos)
    self.lastEffectMaskPosition = pos or 0
    self.isFirstEnterActivity = false 
end

function GoldCupModel:GetLastEffectMaskPosition()
    return self.lastEffectMaskPosition
end

function GoldCupModel:IsFirstEnterActivity()
    return self.isFirstEnterActivity
end

return GoldCupModel