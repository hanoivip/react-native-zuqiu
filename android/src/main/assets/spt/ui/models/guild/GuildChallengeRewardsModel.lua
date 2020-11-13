local Model = require("ui.models.Model")

local GuildChallengeRewardsModel = class(Model, "GuildChallengeRewardsModel")

function GuildChallengeRewardsModel:ctor()
    self.data = cache.getMatchResult()
end

function GuildChallengeRewardsModel:GetMatchResultData()
    return self.data
end

function GuildChallengeRewardsModel:GetSettlementData()
    return self.data.settlement
end

function GuildChallengeRewardsModel:GetSettlementDataContents()
    return self.data.settlement.contents
end

function GuildChallengeRewardsModel:GetStarNum()
    return self.data.settlement.star
end

function GuildChallengeRewardsModel:GetSweepConsume()
    return self.data.sweepConsume
end

function GuildChallengeRewardsModel:GetSp()
    return self.data.settlement.info.sp
end

function GuildChallengeRewardsModel:GetIsPass()
    return tonumber(self.data.settlement.star) > 0
end

return GuildChallengeRewardsModel