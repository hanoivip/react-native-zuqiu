local Model = require("ui.models.Model")
local GuildChallengeTeam = require("data.GuildChallengeTeam")
local GuildChallengeBase = require("data.GuildChallengeBase")
local GuildChallengeModel = class(Model, "GuildChallengeModel")

function GuildChallengeModel:ctor()
    self.guildChallengeLevelInfo = {}
    self.vipAddition = 0
    self.sweep = nil
    self.maxLevelCount = 5
end

function GuildChallengeModel:InitWithProtocol(data)
    self.data = data
    self.vipAddition = data.extraReward.vip
    self.sweep = data.sweep
    local war = self.data.extraReward.war
    local today = self.data.today
    local isDouble = false
    if war ~= nil and today ~= nil then
        for k, v in pairs(war.weeks) do
            if tonumber(today) == tonumber(v) then
                isDouble = true
                break
            end
        end
    end

    for i = 1, self.maxLevelCount do
        local qid = "G" .. i
        self.guildChallengeLevelInfo[qid] = {}
        self.guildChallengeLevelInfo[qid].isOpen = false
        self.guildChallengeLevelInfo[qid].vipAddition = self.vipAddition
        self.guildChallengeLevelInfo[qid].sweep = self.sweep
        self.guildChallengeLevelInfo[qid].count = 0
        self.guildChallengeLevelInfo[qid].eqsList = {}
        self.guildChallengeLevelInfo[qid].itemList = {}
        self.guildChallengeLevelInfo[qid].moneyList = {}
        self.guildChallengeLevelInfo[qid].diamondList = {}
        self.guildChallengeLevelInfo[qid].powerList = {}
        self.guildChallengeLevelInfo[qid].isDouble = isDouble
        self.guildChallengeLevelInfo[qid].war = war
        for k, v in pairs(GuildChallengeTeam) do
            if v.type == qid then
                self.guildChallengeLevelInfo[qid].eqsList[v.ID] = v.eqsID
                self.guildChallengeLevelInfo[qid].itemList[v.ID] = v.itemReward
                self.guildChallengeLevelInfo[qid].moneyList[v.ID] = v.m
                self.guildChallengeLevelInfo[qid].diamondList[v.ID] = v.d
                self.guildChallengeLevelInfo[qid].powerList[v.ID] = v.power
            end
        end
        self.guildChallengeLevelInfo[qid].openTime = GuildChallengeBase[qid].openTime
        self.guildChallengeLevelInfo[qid].name = GuildChallengeBase[qid].name
        self.guildChallengeLevelInfo[qid].name2 = GuildChallengeBase[qid].name2
    end

    for i = 1, #data.list do 
        local levelInfo = self.guildChallengeLevelInfo[data.list[i].qid]
        levelInfo.diff = data.list[i].diff
        levelInfo.count = data.list[i].count
        levelInfo.star = data.list[i].star
        levelInfo.recommandDiff = data.list[i].recommandDiff
        levelInfo.isOpen = true
    end
end

function GuildChallengeModel:GetWarReward()
    return self.data.extraReward.war
end

function GuildChallengeModel:GetToday()
    return self.data.today
end

function GuildChallengeModel:GetVipAddition()
    return self.vipAddition
end

function GuildChallengeModel:GetSweepState()
    return self.sweep
end

function GuildChallengeModel:GetGuildChallengeLevelInfo()
    return self.guildChallengeLevelInfo
end

function GuildChallengeModel:GetChallengeSingleLevel(levelID)
    return self.guildChallengeLevelInfo[levelID]
end

return GuildChallengeModel