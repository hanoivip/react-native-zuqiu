local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamInvestType = require("ui.models.activity.teamInvest.TeamInvestType")
local ActivityModel = require("ui.models.activity.ActivityModel")
local TeamInvestModel = class(ActivityModel)

local SafeTime = 50  -- 网络请求的最大时间（防止还在倒计时时，服务器活动已经结束）
local maxLine = 8  -- 展示的最大行数

function TeamInvestModel:ctor(data)
    TeamInvestModel.super.ctor(self, data)
    self.singleData = self:GetActivitySingleData()
end

function TeamInvestModel:InitWithProtocol()
    self.singleData = self:GetActivitySingleData()
    self:InitNoteList()
end

function TeamInvestModel:GetPeriod()
    return self.singleData.ID
end

function TeamInvestModel:GetNowSlotLevel()
    if self.singleData.p_data then
        return self.singleData.p_data.value + 1
    else
        return 1
    end
end

function TeamInvestModel:GetDiamondNeed()
    local lvl = self:GetNowSlotLevel()
    local lData = self.singleData.list[lvl]
    if not lData then
        return self:GetRecordDiamond()
    else
        return lData.dNeed
    end
end

function TeamInvestModel:GetEndTime()
    local endTime = self.singleData.endTime
    return string.formatTimestampNoYear(endTime)
end

function TeamInvestModel:GetStartTime()
    local beginTime = self.singleData.beginTime
    return string.formatTimestampNoYear(beginTime)
end

function TeamInvestModel:GetNeedVIPLevel()
    local slotLevel = self:GetNowSlotLevel()
    return self.singleData.list[slotLevel] and self.singleData.list[slotLevel].vip
end

function TeamInvestModel:GetMaxDiamond()
    local slotLevel = self:GetNowSlotLevel()
    return self.singleData.list[slotLevel] and self.singleData.list[slotLevel].dDisplay
end

function TeamInvestModel:GetMinDiamond()
    local slotLevel = self:GetNowSlotLevel()
    return self.singleData.list[slotLevel] and self.singleData.list[slotLevel].dDisplayLow
end

function TeamInvestModel:GetConsumeDiamond()
    local slotLevel = self:GetNowSlotLevel()
    return self.singleData.list[slotLevel] and self.singleData.list[slotLevel].dNeed
end

function TeamInvestModel:GetMaxVIPLevel()
    local maxValue = #self.singleData.list
    return self.singleData.list[maxValue].vip or 0
end

function TeamInvestModel:GetDesc()
    local slotLevel = self:GetNowSlotLevel()
    if not self.singleData.list[slotLevel] then
        slotLevel = #self.singleData.list
    end
    return self.singleData.list[slotLevel].desc
end

function TeamInvestModel:GetDesc1()
    local slotLevel = self:GetNowSlotLevel()
    if not self.singleData.list[slotLevel] then
        slotLevel = #self.singleData.list
    end
    return self.singleData.list[slotLevel].desc1
end

function TeamInvestModel:IsSlotFull()
    local slotLevel = self:GetNowSlotLevel()
    local maxValue = #self.singleData.list
    return slotLevel > maxValue
end

function TeamInvestModel:RefreshRedeemData(data)
    self:RefreshNote(data)

    self.singleData.p_data = data.pdata
    self.singleData.currentDiamond = data.currentDiamond
end

-- 每次抽完自己手动把自己的数据添加到展示列表里
function TeamInvestModel:RefreshNote(data)
    local costDiamond = self:GetConsumeDiamond()
    local showDiamond = data.contents.d + costDiamond
    local selfName = PlayerInfoModel.new():GetName()
    local t = {}
    t.diamond = showDiamond
    t.name = selfName
    t.time = 0
    t.index = #self.noteList + 1
    table.insert(self.noteList, t)
    if #self.noteList > maxLine then
        self.noteList[1] = nil
        local tList = {}
        for i, v in pairs(self.noteList) do
            if v then
                table.insert(tList, v)
            end
        end
        self.noteList = self:SortTable(tList)
    end
end

function TeamInvestModel:ChangeInt2Str(intNumber)
    local dStr = tostring(intNumber)
    local le = string.len(dStr)
    for i = 1, 5 - le do
       dStr = 0 .. dStr
    end
    return dStr
end

function TeamInvestModel:GetTeamInvestType()
    return TeamInvestType.TIME_LIMIT
end

-- 所有的奖励抽完只有 显示上一次抽到的奖励
function TeamInvestModel:GetRecordDiamond()
    return self.singleData.p_data.dRecord
end

-- 获取活动剩余时间
function TeamInvestModel:GetRemainTime()
    local endTime = tonumber(self.singleData.endTime)
    local serverDeltaTime = cache.getServerDeltaTimeValue()
    local osTime = os.time() + serverDeltaTime
    local remainTime = endTime - osTime - SafeTime
    if remainTime > 0 then
        return remainTime
    else
        return 0
    end
end

function TeamInvestModel:GetNoteList()
    return self.noteList
end

-- 获取其他玩家获得钻石的信息
function TeamInvestModel:InitNoteList()
    local noteList = {}
    local note = self.singleData.note or {}
    for i, v in pairs(note) do
        local t = {}
        t.time = i
        t.diamond = v.diamond
        t.name = v.name
        table.insert(noteList, t)
    end
    self.noteList = self:SortTable(noteList)
end

function TeamInvestModel:SortTable(noteList)
    table.sort(noteList, function(a, b) return tonumber(a.time) < tonumber(b.time) end)
    if math.fmod(#noteList, 2) == 1 and #noteList > maxLine then
        table.insert(noteList, clone(noteList[maxLine / 2]))
    end
    for i, v in ipairs(noteList) do
        v.index = i
    end
    return noteList
end

return TeamInvestModel
