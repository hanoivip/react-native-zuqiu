local Nation = require("data.Nation")
local DreamLeagueCardBaseModel = require("ui.models.dreamLeague.DreamLeagueCardBaseModel")
local Model = require("ui.models.Model")
local DreamMainModel = class(Model, "DreamMainModel")
local DreamConstants = require("ui.scene.dreamLeague.dreamMain.DreamConstants")

function DreamMainModel:InitWithProtocol(data)
    self.data = data
    self:InitNationMatchScrollData()
end

-- 此处需要显示昨天，今天，明天的数据
function DreamMainModel:InitNationMatchScrollData()
    local yesterday = self.data.matchList.lastMatchList
    yesterday.dateMark = DreamConstants.dateMark.YESTERDAY

    local today = self.data.matchList.todayMatchList
    today.dateMark = DreamConstants.dateMark.TODAY
    
    local tomorrow = self.data.matchList.nextMatchList
    tomorrow.dateMark = DreamConstants.dateMark.TOMORROW

    self.data.matchList = {}
    -- 按策划需求显示顺序
    table.insert(self.data.matchList, next(yesterday) and yesterday or {})
    table.insert(self.data.matchList, next(today) and today or {})
    table.insert(self.data.matchList, next(tomorrow) and tomorrow or {})
end

function DreamMainModel:GetNationMatchScrollData()
    return self.data.matchList
end

-- 如果有昨日比赛，则会存在第一个位置是昨日比赛，需求是进入时永远是今日的
function DreamMainModel:GetNationMatchScrollIndex()
    local function noHaveYesterdayOrTomorrow(matchList)
        return matchList.yesterday and 2 or 1
    end
    local matchList = self.data.matchList
    return #matchList > 2 and 2 or noHaveYesterdayOrTomorrow(matchList)
end

function DreamMainModel:GetSeasonRankScrollData()
    return self.data.seasonRank
end

function DreamMainModel:GetDayRankScrollData()
    return self.data.dayRank
end

return DreamMainModel
