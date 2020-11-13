local CompeteGuessSchedule = require("ui.models.compete.guess.CompeteGuessSchedule")
local Model = require("ui.models.Model")

local CompeteGuessModel = class(Model, "CompeteGuessModel")

function CompeteGuessModel:ctor()
    -- 缓存raw数据
    self.cacheData = {}
    -- 赛季
    self.season = nil
    -- 轮次
    self.round = nil
    -- 当前页签
    self.currTag = nil
    -- 倒计时，所有比赛共享
    self.countdown = nil
    -- 比赛状态，所有比赛共享
    self.schedule = nil
    -- 我的列表数据
    self.myData = nil
    -- 比赛列表数据
    self.matchData = nil
end

function CompeteGuessModel:InitWithProtocol(data)
    self.cacheData = data or {}
    if not data.bigEar then data.bigEar = {} end
    if not data.smallEar then data.smallEar = {} end
    if not data.tnmGuess then data.tnmGuess = {} end

    self.season = self.cacheData.season or ""
    self.round = self.cacheData.round or 0
    -- 倒计时
    local serverTime = data.serverTime or 0
    local timestr, timetable = string.convertSecondToTimeAll(serverTime)
    self.countdown = -1
    if timetable.hour < CompeteGuessSchedule.MatchStartTime.hour then
        -- 未开始
        self.schedule = CompeteGuessSchedule.guessing
        self.countdown = string.convertTimeToSecond(0, CompeteGuessSchedule.MatchStartTime.hour, CompeteGuessSchedule.MatchStartTime.minute, CompeteGuessSchedule.MatchStartTime.second) - 
                    string.convertTimeToSecond(0, timetable.hour, timetable.minute, timetable.second)
    elseif timetable.hour >= CompeteGuessSchedule.MatchStartTime.hour and timetable.hour < CompeteGuessSchedule.MatchOverTime.hour then
        if timetable.minute < CompeteGuessSchedule.MatchStartTime.minute then -- 未开始
            self.schedule = CompeteGuessSchedule.guessing
            self.countdown = string.convertTimeToSecond(0, CompeteGuessSchedule.MatchStartTime.hour, CompeteGuessSchedule.MatchStartTime.minute, CompeteGuessSchedule.MatchStartTime.second) - 
                    string.convertTimeToSecond(0, timetable.hour, timetable.minute, timetable.second)
        else -- 比赛中
            self.schedule = CompeteGuessSchedule.accounting
        end
    elseif timetable.hour >= CompeteGuessSchedule.MatchOverTime.hour then
        if timetable.minute < CompeteGuessSchedule.MatchOverTime.minute then -- 比赛中
            self.schedule = CompeteGuessSchedule.accounting
        else -- 比赛结束
            self.schedule = CompeteGuessSchedule.resulting
        end
    end

    -- 我的列表信息
    self.myData = {}
    for season, matchTypes in pairs(data.tnmGuess) do
        for matchType, roundDatas in pairs(matchTypes) do
            for round, combats in pairs(roundDatas) do
                for combatIndex, myGuess in pairs(combats) do
                    local supportInfo = nil
                    if myGuess.match then
                        supportInfo = myGuess.match.supportInfo
                    end
                    if supportInfo then
                        myGuess.match.player1.guessCount = supportInfo.player1
                        myGuess.match.player2.guessCount = supportInfo.player2
                    end
                    -- 赛季
                    myGuess.season = season
                    -- 轮次
                    myGuess.round = round
                    -- 大耳朵杯小耳朵杯
                    myGuess.matchType = matchType
                    -- 竞猜的索引
                    -- myGuess.combatIndex = tonumber(combatIndex) - 1
                    -- 竞猜的玩家
                    myGuess.guessPlayer = myGuess.value
                    -- 竞猜的档位
                    myGuess.guessStage = myGuess.stage
                    -- 完善比赛信息
                    self:PolishMatchData(myGuess.match)
                    local sortPriority = 0
                    if matchType == "bigEar" then
                        sortPriority = 2
                    elseif matchType == "smallEar" then
                        sortPriority = 1
                    end
                    sortPriority = tonumber(season) + round * 100 + sortPriority * 10 + (9 - tonumber(myGuess.combatIndex))
                    myGuess.sortPriority = sortPriority
                    table.insert(self.myData, myGuess)
                end
            end
        end
    end
    -- 比赛信息
    self.matchData = {}
    -- 大耳朵杯信息完善
    self:PolishMatchDatas("bigEar", data.bigEar, data)
    -- 小耳朵杯信息完善
    self:PolishMatchDatas("smallEar", data.smallEar, data)

    local reverseJuedge = {}
    local stageBonus = data.cfgBonus and data.cfgBonus.stageBonus or {}
    for k, v in pairs(stageBonus) do
        v.idx = tonumber(k)
        if tonumber(v.comebackStart) == 1 then
            table.insert(reverseJuedge, v)
        end
    end
    table.sort(reverseJuedge, function(a, b)
        return a.idx < b.idx
    end)
    self.minStage = nil
    self.maxStage = nil
    for k, v in pairs(reverseJuedge) do
        if self.minStage == nil or self.minStage > v.idx then
            self.minStage = v.idx
        end
        if self.maxStage == nil or self.maxStage < v.idx then
            self.maxStage = v.idx
        end
    end
    local comebackBonus = data.cfgBonus and data.cfgBonus.comebackBonus or {}
    for k, v in pairs(comebackBonus) do
        v.idx = tonumber(k)
    end
end

-- 完善比赛信息
function CompeteGuessModel:PolishMatchDatas(matchType, matches, cacheData)
    local season = cacheData.season
    local round = cacheData.round
    local myGuesses = cacheData.tnmGuess
    for k, match in pairs(matches or {}) do
        -- 竞猜人数
        local supportInfo = match.supportInfo
        if supportInfo then
            match.player1.guessCount = supportInfo.player1 or 0
            match.player2.guessCount = supportInfo.player2 or 0
        end
        -- 赛季及轮次
        match.season = season
        match.round = round
        -- 竞猜时所需post信息
        -- match.combatIndex = tonumber(k) - 1
        match.matchType = matchType
        -- 完善比赛信息
        self:PolishMatchData(match)
        -- 看是否有我竞猜的数据
        if myGuesses[tostring(season)] then
            local matchTypes = myGuesses[tostring(season)]
            if matchTypes[tostring(matchType)] then
                local rounds = matchTypes[tostring(matchType)]
                if rounds[tostring(round)] then
                    local combats = rounds[tostring(round)]
                    for i, v in pairs(combats) do
                        if tonumber(match.combatIndex) == tonumber(v.combatIndex) then
                            match.myGuess = clone(v)
                            match.myGuess.match = nil
                            break
                        end
                    end
                end
            end
        end
        -- 当前竞猜状态
        match.schedule = self.schedule
        table.insert(self.matchData, match)
    end
end

function CompeteGuessModel:PolishMatchData(match)
    if not match or table.nums(match) <= 0 then return end

    match.player1.guessPlayer = "player1"
    match.player2.guessPlayer = "player2"
    -- 比赛是否有结果
    if match.player1.winner then
        match.isMatchOver = true
        match.winner = "player1"
        match.notwinner = "player2"
    elseif match.player2.winner then
        match.isMatchOver = true
        match.winner = "player2"
        match.notwinner = "player1"
    else
        match.isMatchOver = false
    end
    -- 比赛结束后的比分
    if match.isMatchOver then
        -- player1代表界面显示上左边的玩家，player2代表界面显示上右边的玩家
        local player1_score = 0
        local player1_scores = {}
        local player2_score = 0
        local player2_scores = {}
        local player1_pid = match.player1.pid
        local player2_pid = match.player2.pid
        local idx = 1
        for i, realMatch in pairs(match.match) do
            if realMatch.attacker.attackerPid == player1_pid and realMatch.defender.opponentPid == player2_pid then
                -- 左边玩家是进攻方，客场
                player1_score = player1_score + realMatch.attacker.score
                player1_scores[idx] = {
                    score = realMatch.defender.score,
                    isMark = false -- 左侧玩家界面上用颜色标记，该字段为true表示这个分数是左侧玩家的
                }
                player2_score = player2_score + realMatch.defender.score
                player2_scores[idx] = {
                    score = realMatch.attacker.score,
                    isMark = true
                }
            elseif realMatch.attacker.attackerPid == player2_pid and realMatch.defender.opponentPid == player1_pid then
                -- 左边玩家是防守方，主场
                player1_score = player1_score + realMatch.defender.score
                player1_scores[idx] = {
                    score = realMatch.defender.score,
                    isMark = true
                }
                player2_score = player2_score + realMatch.attacker.score
                player2_scores[idx] = {
                    score = realMatch.attacker.score,
                    isMark = false
                }
            end
            idx = idx + 1
        end
        if match.penaltyMatch then
            if match.penaltyMatch.attacker.attackerPid == player1_pid and match.penaltyMatch.defender.opponentPid == player2_pid then
                --左边玩家是进攻方，客场
                player1_score = player1_score + match.penaltyMatch.attacker.penaltyScore
                player1_scores[idx] = {
                    score = match.penaltyMatch.defender.penaltyScore,
                    isMark = false
                }
                player2_score = player2_score + match.penaltyMatch.defender.penaltyScore
                player2_scores[idx] = {
                    score = match.penaltyMatch.attacker.penaltyScore,
                    isMark = true
                }
            elseif match.penaltyMatch.attacker.attackerPid == player2_pid and match.penaltyMatch.defender.opponentPid == player1_pid then
                --左边玩家是防守方，主场
                player1_score = player1_score + match.penaltyMatch.defender.penaltyScore
                player1_scores[idx] = {
                    score = match.penaltyMatch.defender.penaltyScore,
                    isMark = true
                }
                player2_score = player2_score + match.penaltyMatch.attacker.penaltyScore
                player2_scores[idx] = {
                    score = match.penaltyMatch.attacker.penaltyScore,
                    isMark = false
                }
            end
        end
        match.player1.score = player1_score
        match.player1.scores = player1_scores
        match.player2.score = player2_score
        match.player2.scores = player2_scores
    end
    -- 支持人数
    if not match.player1.guessCount then match.player1.guessCount = 0 end
    if not match.player2.guessCount then match.player2.guessCount = 0 end
    -- 倍率
    if match.player1.guessCount > 0 and match.player2.guessCount > 0 then
        -- 都大于0
        match.guessRatio = match.player1.guessCount > match.player2.guessCount and match.player1.guessCount / match.player2.guessCount or match.player2.guessCount / match.player1.guessCount
    elseif match.player1.guessCount > 0 and match.player2.guessCount <= 0 then
        -- player2为0
        match.guessRatio = match.player1.guessCount
    elseif match.player1.guessCount <= 0 and match.player2.guessCount > 0 then
        -- player1为0
        match.guessRatio = match.player2.guessCount
    else
        match.guessRatio = 0
    end
end

function CompeteGuessModel:SetCurrTabTag(tag)
    self.currTag = tag
end

function CompeteGuessModel:GetCurrTabTag(tag)
    return self.currTag
end

-- 竞猜列表是否有数据
function CompeteGuessModel:HasMatchData()
    return tobool(self.matchData ~= nil and table.nums(self.matchData) > 0)
end

-- 获得竞猜列表
function CompeteGuessModel:GetMatchList()
    return self.matchData
end

-- 我的竞猜是否有数据
function CompeteGuessModel:HasMyData()
    return tobool(self.myData ~= nil and table.nums(self.myData) > 0)
end

-- 获得我的竞猜数据
function CompeteGuessModel:GetMyList()
    local result = {}
    for k, v in ipairs(self.myData) do
        if v. match then
            if v.match.isMatchOver then
                table.insert(result, v)
            end
        end
    end
    table.sort(result, function(a, b) return tonumber(a.sortPriority) > tonumber(b.sortPriority) end)
    return result
end

-- 获取赛季字符串
function CompeteGuessModel:GetSeason()
    return self.season or ""
end

-- 获取轮次
function CompeteGuessModel:GetRound()
    return self.round or 0
end

-- 获取倒计时，所有比赛共享
function CompeteGuessModel:GetCountdown()
    return self.countdown
end

-- 更新倒计时
function CompeteGuessModel:SetCountdown(val)
    self.countdown = val
end

-- 获得当前比赛状态
function CompeteGuessModel:GetSchedule()
    return self.schedule or ""
end

-- 获得翻盘奖励数据
function CompeteGuessModel:GetReverseReward()
    if self.cacheData and self.cacheData.cfgBonus then
        return self.cacheData.cfgBonus.comebackBonus or {}
    else
        return {}
    end
end

-- 根据倍率获得翻盘奖励数据
function CompeteGuessModel:GetReverseRewardByRatio(ratio)
    local rewards = self:GetReverseReward()
    local rewardArray = {}
    local reward = nil

    for k, v in pairs(rewards) do
        table.insert(rewardArray, v)
    end
    table.sort(rewardArray, function(a, b)
        return a.idx < b.idx
    end)
    for k, v in ipairs(rewardArray) do
        if ratio * 100 > v.comebackTimes then -- 左闭右开
            reward = v
        else
            break
        end
    end
    return reward
end

-- 获得竞猜奖励
function CompeteGuessModel:GetStageReward()
    if self.cacheData and self.cacheData.cfgBonus then
        return self.cacheData.cfgBonus.stageBonus or {}
    else
        return {}
    end
end

-- 根据竞猜档位获得竞猜奖励数据
function CompeteGuessModel:GetStageRewardByStage(stage)
    return self:GetStageReward()[tostring(stage)]
end

-- 获得竞猜所需金额
function CompeteGuessModel:GetGuessMoney(stage)
    local rewards = self:GetStageReward()
    if rewards[tostring(stage)] then
        return rewards[tostring(stage)].mConsume
    else
        return 0
    end
end

-- 获得翻盘奖励判断
function CompeteGuessModel:GetJudgeStage()
    return self.minStage, self.maxStage
end

-- 领取奖励后更新
function CompeteGuessModel:UpdateAfterReceive(data, season, round, matchType, combatIndex)
    local combats = self.cacheData.tnmGuess[tostring(season)][tostring(matchType)][tostring(round)]
    local myData
    for k, v in pairs(combats) do
        if tonumber(v.combatIndex) == tonumber(combatIndex) then
            myData = v
            break
        end
    end
    if myData then
        myData.redeemed = true
    end
    for k, v in pairs(self.myData) do
        if v.season == season and v.round == round and v.matchType == matchData and tonumber(v.combatIndex) == tonumber(combatIndex) then
            v.redeemed = true
            break
        end
    end
end

return CompeteGuessModel
