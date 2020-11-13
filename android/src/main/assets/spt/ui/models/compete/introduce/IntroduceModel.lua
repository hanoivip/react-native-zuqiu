local RewardContentData = require("data.WorldTournamentReward")
local Model = require("ui.models.Model")
local IntroduceConstants = require("ui.models.compete.introduce.IntroduceConstants")
local IntroduceModel = class(Model)

function IntroduceModel:ctor()
	IntroduceModel.super.ctor(self)
    self.rewardData = {}
    local numIndex = nil
    for k, v in pairs(RewardContentData) do
        numIndex = tonumber(k)
        self.rewardData[numIndex] = v
    end
end

function IntroduceModel:GetLeagueName(tag)
    local strInlangPack = "compete_introduce_leagueName"..tag
    local str = lang.transstr(strInlangPack)
    return str
end

function  IntroduceModel:GetLeagueTags()
    local leagueTags = {IntroduceConstants.BIG_EAR_CUP,
            IntroduceConstants.SMALL_EAR_CUP,
            IntroduceConstants.SUPER_LEAGUE,
            IntroduceConstants.CHAMPION_LEAGUE,
            IntroduceConstants.FIRST_LEVEL_LEAGUE,
            IntroduceConstants.SECOND_LEVEL_LEAGUE,
            IntroduceConstants.DISTRICT_LEAGUE}      ---modifiable
    return leagueTags
end

function IntroduceModel:GetRewardDataOfTag(tag)
    local data = {}
    local up = nil
    local down = nil
    if tonumber(tag) == tonumber(IntroduceConstants.BIG_EAR_CUP) then
        down = tonumber(IntroduceConstants.BIG_EAR_CUP)
        up = tonumber(IntroduceConstants.BIG_EAR_CUP_PRELININARY)
    elseif tonumber(tag) == tonumber(IntroduceConstants.SMALL_EAR_CUP) then
        down = tonumber(IntroduceConstants.SMALL_EAR_CUP)
        up = tonumber(IntroduceConstants.SMALL_EAR_CUP_PRELIMINARY)
    else
        up = tonumber(tag)
        down = tonumber(tag)
    end
    if self.rewardData == nil then
        self:ctor()
    end
    for k, v in ipairs(self.rewardData) do
        for key,value in pairs(v.matchType) do
            if self:IsMatchType(value, up, down) then
                table.insert(data, v)
                break
            end
        end
    end
    return data
end

function IntroduceModel:IsMatchType(typeTag, up, down)
    typeTag = tonumber(typeTag)
    up = tonumber(up)
    down = tonumber(down)

    if typeTag >= down and typeTag <= up then
        return true
    else
        return false
    end
end

return IntroduceModel