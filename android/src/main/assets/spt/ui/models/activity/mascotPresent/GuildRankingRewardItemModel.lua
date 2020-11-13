local RewardItemViewModel = require("ui.models.quest.RewardItemViewModel")

local GuildRankingRewardItemModel = class(RewardItemViewModel, "GuildRankingRewardItemModel")

function GuildRankingRewardItemModel:ctor(data)
    GuildRankingRewardItemModel.super.ctor(self, data)
    self.data = data
end

function GuildRankingRewardItemModel:GetRankStr()
    assert(self.data.rankHigh and self.data.rankLow, "server data error!!!")
    local rankStr = ""
    if self.data.rankHigh == self.data.rankLow then
        rankStr = lang.transstr("guildwar_rank", tostring(self.data.rankHigh))
    elseif tonumber(self.data.rankLow) > tonumber(self.data.rankHigh) then
        local addStr = tostring(self.data.rankHigh) .. "—" .. tostring(self.data.rankLow)
        rankStr = lang.transstr("guildwar_rank", addStr)
    end

    return rankStr
end

return GuildRankingRewardItemModel