local Model = require("ui.models.Model")

local GuildChallengeEnterModel = class(Model, "GuildChallengeEnterModel")

function GuildChallengeEnterModel:ctor()
    self.ID = 1
    self.diffStarList = {}
    self.currentDiff = 1
    self.maxDiff = 7
end

function GuildChallengeEnterModel:InitWithProtocol(data)
    self.data = data
    self.ID = data.index
    for k, v in pairs(data.star) do
        self.diffStarList[tonumber(k)] = v
    end
    self.currentDiff = tonumber(data.recommandDiff)
end

function GuildChallengeEnterModel:GetCurrentDiff()
    return self.currentDiff
end

function GuildChallengeEnterModel:SetCurrentDiff(diff)
    self.currentDiff = diff
end

function GuildChallengeEnterModel:GetCostStrength()
    return 10
end

function GuildChallengeEnterModel:GetSingleDiffStar(index)
    return self.diffStarList[index]
end

function GuildChallengeEnterModel:GetCurrentLevelIndex()
    return self.ID
end

function GuildChallengeEnterModel:GetCurrentID()
    return "G" .. self.ID
end

function GuildChallengeEnterModel:SetSingleDiffStar(diff, star)
    if star > self.diffStarList[diff] then
        self.diffStarList[diff] = star
    end
end

function GuildChallengeEnterModel:GetDiffStrList()
    return self.diffStarList
end

function GuildChallengeEnterModel:ReduceLeftCount()
    if self.data.count > 0 then
        self.data.count = self.data.count - 1
    end
end

function GuildChallengeEnterModel:GetDiffEquipList(diff)
    return self.data.eqsList["G"..self.ID.."0"..diff]
end

function GuildChallengeEnterModel:GetDiffItemList(diff)
    return self.data.itemList["G"..self.ID.."0"..diff]
end

function GuildChallengeEnterModel:GetMoney(diff)
    return self.data.moneyList["G"..self.ID.."0"..diff]
end

function GuildChallengeEnterModel:GetDiamond(diff)
    return self.data.diamondList["G"..self.ID.."0"..diff]
end

function GuildChallengeEnterModel:GetPower(diff)
    return self.data.powerList["G"..self.ID.."0"..diff]
end

function GuildChallengeEnterModel:GetLeftCount()
    return self.data.count
end

function GuildChallengeEnterModel:SetMaxOpenedDiff(diff)
    if diff <= self.maxDiff then
        self.data.diff = diff
    end
end

function GuildChallengeEnterModel:GetMaxOpenedDiff()
    return self.data.diff
end

function GuildChallengeEnterModel:GetSweepInfo()
    return self.data.sweep
end

function GuildChallengeEnterModel:GetVipAddition()
    return self.data.vipAddition
end

function GuildChallengeEnterModel:GetWar()
    return self.data.war
end

function GuildChallengeEnterModel:GetIsDouble()
    return self.data.isDouble
end

function GuildChallengeEnterModel:GetImgSprite()
    local path = "Assets/CapstonesRes/Game/UI/Scene/Guild/Image/GuildInstance/GuildInsBg_".. self.ID .. ".png"
    return res.LoadRes(path)
end

function GuildChallengeEnterModel:GetTitle()
    return lang.trans("guild_challenge_tilte_" .. self.ID)
end

return GuildChallengeEnterModel