local Model = require("ui.models.Model")

local GuildWarGuardModel = class(Model, "GuildWarGuardModel")

function GuildWarGuardModel:ctor()
    self.turnedCnt = 0    
    self:InitData()
end

function GuildWarGuardModel:InitData()
    self.guardList = {}        
    for i = 1, 13 do
        local info = {name = nil, pid = nil, level = 1, logo = nil, seizeCnt = 0, index = i, state = ""}
        table.insert(self.guardList, info)
    end
    self:ClearTurnedCnt()
end

function GuildWarGuardModel:InitWithProtrol(guardTable, state)
    for i = 1, #self.guardList do
        self.guardList[i].state = state
    end
    for k, v in pairs(guardTable) do
        self:SetGuardPositionData(k, v, state)
    end
    self:ClearTurnedCnt()
end

function GuildWarGuardModel:SetGuardList(table, state)
    self:InitData()
    self:InitWithProtrol(table, state)
    EventSystem.SendEvent("GuildWarGuardModel_RefreshGuardPosition", self.guardList)
end

function GuildWarGuardModel:GetGuardPosition(index)
    return self.guardList[index]
end

function GuildWarGuardModel:SetGuardPosition(index, data, state)
    self:SetGuardPositionData(index, data, state)
    EventSystem.SendEvent("GuildWarGuardModel_RefreshGuardPosition", self.guardList)
end

function GuildWarGuardModel:SetGuardPositionSeizeCnt(index, cnt)
    self:ClearTurnedCnt()
    local guardPos = self.guardList[tonumber(index)]
    guardPos.seizeCnt = cnt
    EventSystem.SendEvent("GuildWarGuardModel_RefreshGuardPosition", self.guardList)
end

function GuildWarGuardModel:SetGuardPositionData(index, data, state)
    local guardPos = self.guardList[tonumber(index)]
    guardPos.name = data.name
    guardPos.pid = data.pid
    guardPos.sid = data.sid
    guardPos.level = data.lvl
    guardPos.logo = data.logo
    guardPos.seizeCnt = data.seizeCnt or 0
    guardPos.state = state
end

function GuildWarGuardModel:GetGuardList()
    return self.guardList
end

function GuildWarGuardModel:AddTurnedCnt()
    self.turnedCnt = self.turnedCnt + 1
    local allTurned = self:CheckTurnedCnt()
    if allTurned == true then
        EventSystem.SendEvent("GuildWarGuardPos_Turned")
    end 
end

function GuildWarGuardModel:ClearTurnedCnt()
    self.turnedCnt = 0
end

function GuildWarGuardModel:CheckTurnedCnt()
    return self.turnedCnt >= 13
end

return GuildWarGuardModel