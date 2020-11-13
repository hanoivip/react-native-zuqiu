local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local Model = require("ui.models.Model")

local CompeteSupportPageModel = class(Model, "CompeteSupportPageModel")

function CompeteSupportPageModel:ctor()
    -- 玩家数据
    self.playerData = playerData
    -- 比赛类型
    self.matchType = matchType
    -- 比赛在列表中的索引
    self.combatIndex = combatIndex
    -- 奖励列表
    self.stageReward = nil
    self.rewards = nil
    -- 当前选择的奖励
    self.currRewardIdx = 1
end

function CompeteSupportPageModel:InitWithProtocol(data)
end

-- playerData中包含logo、name、pid、sid、serverName、worldTournamentLevel、guessPlayer
-- matchType {string} 比赛类型，大耳朵杯bigEar，小耳朵杯smallEar
-- combatIndex {number} 比赛在列表中的索引
-- stageReward {table} 档位奖励
function CompeteSupportPageModel:InitWithParentScene(playerData, matchType, combatIndex, stageReward)
    self.playerInfoModel = PlayerInfoModel.new()

    self.playerData = playerData
    self.matchType = matchType
    self.combatIndex = combatIndex
    self.stageReward = stageReward
    self.rewards = {}
    self.currRewardIdx = 1
    for k, v in pairs(stageReward) do
        v.idx = tonumber(k)
        v.choosed = tobool(v.idx == self.currRewardIdx)
        table.insert(self.rewards, v)
    end
    table.sort(self.rewards, function(a, b) return a.idx < b.idx end)
end

function CompeteSupportPageModel:GetStatusData()
    return self.playerData, self.matchType, self.combatIndex, self.stageReward
end

function CompeteSupportPageModel:GetLogo()
    return self.playerData.logo
end

function CompeteSupportPageModel:GetName()
    return self.playerData.name
end

function CompeteSupportPageModel:GetPid()
    return self.playerData.pid
end

function CompeteSupportPageModel:GetSid()
    return self.playerData.sid
end

function CompeteSupportPageModel:GetServerName()
    return self.playerData.serverName or ""
end

function CompeteSupportPageModel:GetCompeteSign()
    return self.playerData.worldTournamentLevel
end

function CompeteSupportPageModel:GetLvl()
    return self.playerData.lvl
end

function CompeteSupportPageModel:GetMatchType()
    return self.matchType
end

function CompeteSupportPageModel:GetCombatIndex()
    return self.combatIndex
end

function CompeteSupportPageModel:GetGuessPlayer()
    return self.playerData.guessPlayer
end

function CompeteSupportPageModel:GetRewards()
    return self.rewards
end

-- 获得当前选择的奖励
function CompeteSupportPageModel:GetCurrChoosedReward()
    return self.currRewardIdx
end

-- 改变当前选择的奖励
function CompeteSupportPageModel:ChangeChoosedReward(idx)
    if self.currRewardIdx then
        self.rewards[self.currRewardIdx].choosed = false
    end
    self.currRewardIdx = idx
    self.rewards[self.currRewardIdx].choosed = true
end

-- 获得当前选择的奖励的档位，与index一致
function CompeteSupportPageModel:GetCurrStage()
    return self.currRewardIdx
end

-- 竞猜后更新数据
function CompeteSupportPageModel:UpdateAfterGuess(data)
    local cost = data.cost
    if cost ~= nil and cost.type ~= nil and tostring(cost.type) == CurrencyType.Money then
        self.playerInfoModel:SetMoney(cost.curr_num)
    end
end

return CompeteSupportPageModel
