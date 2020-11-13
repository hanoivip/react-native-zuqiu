local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuildWarGuardDetailModel = class(Model, "GuildWarGuardDetailModel")

function GuildWarGuardDetailModel:ctor()
    self.memberList = {}
    self.playerInfoModel = PlayerInfoModel.new()
    self.pid = self.playerInfoModel:GetID()
end

function GuildWarGuardDetailModel:InitWithProtrol(guardData, data)
    self.memberList = data
    self:SetGuardData(guardData)
    self:SetCurrentMember(guardData.name)
end

function GuildWarGuardDetailModel:GetMemberItemByPid(pid)
    for i = 1, #self.memberList do
        if self.memberList[i]._id == pid then
            return self.memberList[i]
        end
    end
end

function GuildWarGuardDetailModel:GetMemberItemByName(name)
    for i = 1, #self.memberList do
        if self.memberList[i].name == name then
            return self.memberList[i], i
        end
    end
end

function GuildWarGuardDetailModel:RemoveMemberItemByName(name)
    for i = 1, #self.memberList do
        if self.memberList[i].name == name then
            local data = clone(self.memberList[i])
            table.remove(self.memberList, i)
            return data
        end
    end
end

function GuildWarGuardDetailModel:RemoveMemberItemByPid(pid)
    for i = 1, #self.memberList do
        if self.memberList[i]._id == pid then
            table.remove(self.memberList, i)
            break
        end
    end
end

function GuildWarGuardDetailModel:SetCurrentMember(name, data)
    if name == nil then return end
    if self.currentMenber then
        local member = self:RemoveMemberItemByName(name)
        local mdata = clone(self.currentMenber)
        table.insert(self.memberList, mdata)
        self.currentMenber = member
    else
        local member = self:RemoveMemberItemByName(name)
        self.currentMenber = member
    end
    if data then
        for i = 1, #self.memberList do
            self.memberList[i].pos = nil
        end
        for k, v in pairs(data) do
            for i = 1, #self.memberList do
                if v.name == self.memberList[i].name then
                    self.memberList[i].pos = tonumber(k)
                    break
                end
            end
        end
    end
end

function GuildWarGuardDetailModel:GetCurrentMember()
    return self.currentMenber
end

function GuildWarGuardDetailModel:SetGuardData(data)
    self.guardData = data
end

function GuildWarGuardDetailModel:GetGuardData()
    return self.guardData
end

function GuildWarGuardDetailModel:GetMemberList()
    table.sort(self.memberList, function (a, b)
        a.self = 0
        b.self = 0
        if a._id == self.pid then
            a.self = 1
        end
        if b._id == self.pid then
            b.self = 1
        end

        if a.self == b.self then
            if a.power == b.power then
                return a.lvl > b.lvl
            else
                return a.power > b.power
            end
        else
            return a.self > b.self
        end
    end)
    
    return self.memberList
end

return GuildWarGuardDetailModel