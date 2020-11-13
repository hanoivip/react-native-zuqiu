local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local ActivityModel = require("ui.models.activity.ActivityModel")
local TimeLimitExploreModel = class(ActivityModel)

function TimeLimitExploreModel:InitWithProtocol()
    self:SetGachaRewardList()
    self:SetRankRewardList()
    self:SetPointRewardList()
    self:SetRule()
    self:SetGachaFreeTime(self:GetActivitySingleData().freeTime - self:GetActivitySingleData().oneGachaCount)
    self.requestTime = Time.realtimeSinceStartup
end

--- 活动期数
function TimeLimitExploreModel:GetPeriodID()
    return self:GetActivitySingleData().ID
end

function TimeLimitExploreModel:GetBeginTime()
    return self:GetActivitySingleData().beginTime
end

function TimeLimitExploreModel:GetEndTime()
    return self:GetActivitySingleData().activityEndTime
end

function TimeLimitExploreModel:GetServerTime()
    return self:GetActivitySingleData().serverTime
end

function TimeLimitExploreModel:GetRemainTime()
    local serverTime = self:GetServerTime()
    local realtimeSinceStartup = Time.realtimeSinceStartup
    local nowTime = serverTime + realtimeSinceStartup - self.requestTime
    local endTime = self:GetEndTime()
    local remainTime = endTime - nowTime
    if remainTime < 0 then
        remainTime = 0
    end
    return remainTime
end

function TimeLimitExploreModel:GetTotalTime()
    return self:GetEndTime() - self:GetBeginTime()
end

function TimeLimitExploreModel:GetDescription()
    return self:GetActivitySingleData().desc
end

function TimeLimitExploreModel:GetGachaFreeInfo()
    return self.freeGachaTime
end

function TimeLimitExploreModel:SetGachaFreeTime(freeTime)
    self.freeGachaTime = freeTime < 0 and 0 or freeTime
    EventSystem.SendEvent("TimeLimitExplore.UpdateGachaFreeInfo")
end

function TimeLimitExploreModel:GetGachaOnePrice()
    return self:GetActivitySingleData().oneGachaPrice
end

function TimeLimitExploreModel:GetGachaOnePoint()
    return self:GetActivitySingleData().oneGachaPoint
end

function TimeLimitExploreModel:GetGachaTenPrice()
    return self:GetActivitySingleData().tenGachaPrice
end

function TimeLimitExploreModel:GetGachaTenPoint()
    return self:GetActivitySingleData().tenGachaPoint
end

function TimeLimitExploreModel:GetPlayerInfo()
    return self:GetActivitySingleData().player
end

function TimeLimitExploreModel:GetPlayerRank()
    return self.rankData ~= nil and self.rankData.rank or self:GetPlayerInfo().rank
end

function TimeLimitExploreModel:GetPlayerPoint()
    return self.rankData ~= nil and self.rankData.visitPoint or self:GetPlayerInfo().visitPoint
end

function TimeLimitExploreModel:GetFreeTime()
    return self.freeGachaTime
end

function TimeLimitExploreModel:GetPictureType()
    return self:GetActivitySingleData().pictureType
end

function TimeLimitExploreModel:GetPictureID()
    return self:GetActivitySingleData().pictureID
end

function TimeLimitExploreModel:SetRule()    
    self.ruleTable = {}
    table.insert(self.ruleTable, lang.trans("visit_rule_text1"))
    for i, v in ipairs(self.rankMap) do
        if v.topLimit == v.downLimit then
            table.insert(self.ruleTable, lang.trans("visit_rule_rankRule", v.topLimit, v.visitThreshold))
        else
            local num = tostring(v.topLimit) .. "—" .. tostring(v.downLimit)
            table.insert(self.ruleTable, lang.trans("visit_rule_rankRule", num, v.visitThreshold))
        end
    end
    table.insert(self.ruleTable, lang.trans("visit_rule_text2"))
end

function TimeLimitExploreModel:GetRule()
    return self.ruleTable
end

function TimeLimitExploreModel:GetShowCardData()
    local type = self:GetPictureType()
    local showData = {}
    if type == 1 then
        showData.card = {}
        table.insert(showData.card, {id = self:GetPictureID(), num = 1,})
    end
    return showData
end

function TimeLimitExploreModel:GetGachaRewardList()
    return self.gachaRewardList
end

function TimeLimitExploreModel:GetRankRewardList()
    return self.rankRewardList
end

function TimeLimitExploreModel:GetPointRewardList()
    return self.pointRewardList
end

function TimeLimitExploreModel:GetRankList()
    return self.rankList
end

function TimeLimitExploreModel:SetGachaRewardList()
    self.gachaRewardList = self:GetActivitySingleData().gacha

    -- TODO: 显示顺序暂时不处理，按照服务器返回顺序显示
    -- self.gachaRewardList = {
    --     {cardPiece = {},},
    --     {},
    --     {item = {},},
    -- }
    -- local rewards = self:GetActivitySingleData().gacha
    -- for k, v in pairs(rewards) do
    --     if v.contents.cardPiece then
    --         table.imerge(self.gachaRewardList[1].cardPiece, v.contents.cardPiece)
    --     elseif v.contents.item then
    --         table.imerge(self.gachaRewardList[3].item, v.contents.item)
    --     else
    --         for key, value in pairs(v.contents) do
    --             self.gachaRewardList[2][key] = value
    --         end
    --     end
    -- end
    -- table.sort(self.gachaRewardList[1].cardPiece, function(a, b)
    --     return not (a.id ~= b.id and a.id == "generalPiece")
    -- end)
end

function TimeLimitExploreModel:SetRankRewardList()
    self.rankRewardList = {}
    self.rankMap = {}
    local rankRewards = self:GetActivitySingleData().rankReward
    for k, v in pairs(rankRewards) do
        table.insert(self.rankRewardList, v)
        table.insert(self.rankMap, {
            downLimit = v.downLimit,
            topLimit = v.topLimit,
            visitThreshold = v.visitThreshold,
        })
    end
    table.sort(self.rankMap, function(a, b) return a.topLimit < b.topLimit end)
    table.sort(self.rankRewardList, function(a, b) return a.topLimit < b.topLimit end)
end

function TimeLimitExploreModel:SetPointRewardList()
    self.pointRewardList = {}
    local pointRewards = self:GetActivitySingleData().chestReward
    for k, v in pairs(pointRewards) do
        table.insert(self.pointRewardList, v)
    end
    table.sort(self.pointRewardList, function(a, b) return a.condition < b.condition end)
end

function TimeLimitExploreModel:UpdatePointRewardInfo(rewardId)
    for i, v in ipairs(self.pointRewardList) do
        if v.subID == rewardId and v.status == 0 then
            v.status = 1
        end
    end
end

function TimeLimitExploreModel:UpdateRankInfo(data)
    self.rankData = data
    self.rankList = {}
    for i = 1, 50 do
        if self.rankData.rankInfo[i] and self.rankData.rankInfo[i].visitPoint and self.rankData.rankInfo[i].visitPoint >= self:GetLimitPoint(i) then
            self.rankData.rankInfo[i].rank = i
        else
            self.rankData.rankInfo[i] = {}
            self.rankData.rankInfo[i].rank = i
            self.rankData.rankInfo[i].visitPoint = self:GetLimitPoint(i)
        end
        table.insert(self.rankList, self.rankData.rankInfo[i])
    end
    self:UpdateExplorePointInfo(self.rankData.visitPoint)
end

function TimeLimitExploreModel:UpdateExplorePointInfo(currentPoint)
    for i, v in ipairs(self.pointRewardList) do
        if v.condition <= currentPoint and v.status == -1 then
            v.status = 0
        end
    end
end

function TimeLimitExploreModel:GetLimitPoint(rank)
    for i, v in ipairs(self.rankMap) do
        if rank <= v.downLimit and rank >= v.topLimit then
            return v.visitThreshold
        end
    end
end

function TimeLimitExploreModel:SendUpdatePointRewardInfoEvent()
    EventSystem.SendEvent("TimeLimitExplore.UpdatePointRewardInfo")
end

function TimeLimitExploreModel:SendUpdateRankInfoEvent()
    EventSystem.SendEvent("TimeLimitExplore.UpdateRankInfo")
end

return TimeLimitExploreModel