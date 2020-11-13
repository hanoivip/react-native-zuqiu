local Model = require("ui.models.Model")

local PeakHistoryModel = class(Model)

function PeakHistoryModel:ctor()
    PeakHistoryModel.super.ctor(self)
    self.seconds = 1
    self.secondsPerMinute = 60 * self.seconds
    self.secondsPerHour = 60 * self.secondsPerMinute
    self.secondsPerDay = 24 * self.secondsPerHour
    self.secondsPerMonth = 30 * self.secondsPerDay
    self.secondsPerYear = 12 * self.secondsPerMonth
end

function PeakHistoryModel:InitWithProtocol(data)
    assert(data)
    self.data = data
end

function PeakHistoryModel:GetPeakHistoryList()
    self.historyDataList = {}
    local recordData = self.data.record

    if not recordData or not next(recordData) then
        return self.historyDataList
    end

    local opponentData = {}
    for i, singleRecord in ipairs(recordData) do
        local historyData = {}
        historyData.home = singleRecord.selfIsAttacker and 0 or 1
        opponentData = singleRecord.selfIsAttacker and singleRecord.defender or singleRecord.attacker
        historyData.opponent ={}
        historyData.opponent.name = opponentData.name
        historyData.opponent.logo = opponentData.logo
        historyData.opponent.pid = opponentData.pid
        historyData.opponent.sid = opponentData.sid
        historyData.opponent.lvl = opponentData.lvl
        historyData.opponent.zone = opponentData.serverName
        historyData.new = singleRecord.isNewRecord
        --失败和胜利字符串
        historyData.result = (#singleRecord.result > 5) and 1 or -1
        historyData.rankChg = singleRecord.preRank - singleRecord.curRank
        historyData.historyTime = self:GethistoryTime(singleRecord.timeDistance)
        table.insert(self.historyDataList, historyData)
    end
    return self.historyDataList
end

function PeakHistoryModel:GetSingleMatchData(index)
    return self.data.record[index]
end

function PeakHistoryModel:GethistoryTime(time)
    --求时间
    local year1 = math.modf(time / self.secondsPerYear)
    if year1 > 0 then
        return lang.trans("peak_history_time_year", tostring(year1))
    end
    time = time - year1 * self.secondsPerYear
    local month1 = math.modf(time / self.secondsPerMonth)
    if month1 > 0 then
        return lang.trans("peak_history_time_month", tostring(month1))
    end
    time = time - month1 * self.secondsPerMonth
    local day1 = math.modf(time / self.secondsPerDay)
    if day1 > 0 then
        return lang.trans("peak_history_time_day", tostring(day1))
    end
    time = time - day1 * self.secondsPerDay
    local hour1 = math.modf(time / self.secondsPerHour)
    time = time - hour1 * self.secondsPerHour
    local minute1 = math.modf(time / self.secondsPerMinute)
    if hour1 > 0 then
        return lang.trans("peak_history_time_hour", tostring(hour1),tostring((minute1 < 1) and 1 or minute1))
    end
    local second = time - minute1 * self.secondsPerMinute
    if minute1 > 0 then
        return lang.trans("peak_history_time_minute", tostring(minute1),tostring((second < 1) and 1 or second))
    end
    return lang.trans("peak_history_time_second", tostring((second < 1) and 1 or second))
end

return PeakHistoryModel