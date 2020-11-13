local Model = require("ui.models.Model")
local DreamLeagueExplain = require("data.DreamLeagueExplain")
local DreamLeagueDailyReward = require("data.DreamLeagueDailyReward")
local DreamLeagueRankReward = require("data.DreamLeagueRankReward")

local DreamRuleModel = class(Model, "DreamRuleModel")

function DreamRuleModel:ctor()
    DreamRuleModel.super.ctor(self)
end

function DreamRuleModel:GetDescByTag(tag)
    if tag == "MainDesc" then
        return self:GetMainDesc()
    elseif tag == "Cards" then
        return self:GetCards()
    elseif tag == "Hall" then
        return self:GetHall()
    elseif tag == "MVPGuess" then
        return self:GetMVPGuess()
    end
end

function DreamRuleModel:GetMainDesc()
    return DreamLeagueExplain["1"].desc
end

function DreamRuleModel:GetCards()
    return DreamLeagueExplain["2"].desc
end

function DreamRuleModel:GetHall()
    return DreamLeagueExplain["3"].desc
end

function DreamRuleModel:GetMVPGuess()
    return DreamLeagueExplain["4"].desc
end

function DreamRuleModel:GetDailyRewardData()
    self.dailyRewardList = {}
    for k, v in pairs(DreamLeagueDailyReward) do
        table.insert(self.dailyRewardList, v)
    end

    table.sort(self.dailyRewardList, function(a, b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)

    return self.dailyRewardList
end

function DreamRuleModel:GetRankRewardData()
    self.rankRewardList = {}
    for k, v in pairs(DreamLeagueRankReward) do
        table.insert(self.rankRewardList, v)
    end

    table.sort(self.rankRewardList, function(a, b)
        if a.id < b.id then
            return true
        else
            return false
        end
    end)

    return self.rankRewardList
end

return DreamRuleModel