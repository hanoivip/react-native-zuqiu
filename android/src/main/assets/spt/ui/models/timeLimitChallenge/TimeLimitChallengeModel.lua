local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local TimeLimitChallengeModel = class(Model)

function TimeLimitChallengeModel:ctor()
    TimeLimitChallengeModel.super.ctor(self)
end

function TimeLimitChallengeModel:InitWithProtocol(data)
    self.data = data.list
end

function TimeLimitChallengeModel:GetDataList()
    return self.data.list
end

function TimeLimitChallengeModel:GetDataByLevelIndex(levelIndex)
    local list = self:GetDataList()
    return list[tonumber(levelIndex)]
end

function TimeLimitChallengeModel:GetSubIDByLevelIndex(levelIndex)
    local currentLevelData = self:GetDataByLevelIndex(levelIndex)
    return currentLevelData.subID
end

function TimeLimitChallengeModel:GetStateByLevelIndex(levelIndex)
    local currentLevelData = self:GetDataByLevelIndex(levelIndex)
    return currentLevelData.status
end

function TimeLimitChallengeModel:GetPlayerPowerLimitByLevelIndex(levelIndex)
    local currentLevelData = self:GetDataByLevelIndex(levelIndex)
    return currentLevelData.value
end

function TimeLimitChallengeModel:GetContentsByLevelIndex(levelIndex)
    local currentLevelData = self:GetDataByLevelIndex(levelIndex)
    return currentLevelData.contents
end

function TimeLimitChallengeModel:GetCooldownTime()
    return self.data.cd
end

function TimeLimitChallengeModel:GetRemainTime()
    return self.data.remainTime
end

function TimeLimitChallengeModel:GetCurrentLevelIndexToShow()
    local maxIndex = 7
    for index, levelData in ipairs(self.data.list) do
        if levelData.status == -1 then
            return index
        end
    end
    return maxIndex
end

return TimeLimitChallengeModel