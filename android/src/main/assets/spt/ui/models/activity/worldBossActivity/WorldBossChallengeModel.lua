local Model = require("ui.models.Model")
local WorldBossItem = require("data.WorldBossItem")
local TeamTotal = require("data.TeamTotal")

local WorldBossChallengeModel = class(Model)

function WorldBossChallengeModel:ctor(data, fatherModel)
    WorldBossChallengeModel.super.ctor(self)
    assert(data)
    self.data = data
    self.fatherModel = fatherModel
    self.buyChallengeInfo = fatherModel:GetBuyChallengeInfo()
end

function WorldBossChallengeModel:InitWithProtocol()
    self.teamData = TeamTotal[self.data.opponentName]
end

function WorldBossChallengeModel:GetTeamData()
    return self.teamData
end

function WorldBossChallengeModel:GetTitle()
    return self.teamData["teamName"]
end

function WorldBossChallengeModel:GetOppendId()
    return self.data.opponentId
end

function WorldBossChallengeModel:GetOppendInfo()
    return self.data.desc
end

function WorldBossChallengeModel:GetScoreInfo()
    return lang.trans("worldBossActivity_challenge_score",self.data.opponentScore)
end

function WorldBossChallengeModel:GetPowerInfo()
    return lang.trans("worldBossActivity_challenge_power",self.data.recommendPower)
end

function WorldBossChallengeModel:GetSweepState()
    return true
end

function WorldBossChallengeModel:UpdateMatchTimes(matchTimes)
    self.buyChallengeInfo.matchTimes = matchTimes
end

function WorldBossChallengeModel:GetRediusCount()
    return self.buyChallengeInfo.matchTimes > 0 and self.buyChallengeInfo.matchTimes or 0
end

function WorldBossChallengeModel:GetCanMatch()
    return self.buyChallengeInfo.canMatch
end

function WorldBossChallengeModel:GetBuyChallengeTimeConsume()
    local count = -self.buyChallengeInfo.matchTimes + 1
    return self.buyChallengeInfo.price[count] or self.buyChallengeInfo.price[#self.buyChallengeInfo.price]
end

function WorldBossChallengeModel:GetDiamondCounts()
    return self.data.opponentDiamond
end

function WorldBossChallengeModel:GetRewardContents()
    local contents = {}
    for k,v in pairs(self.data.outputProbability) do
        table.insert(contents, WorldBossItem[k])
    end
    return contents
end

return WorldBossChallengeModel