local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local GuildMistWarGuardDetailModel = class(Model, "GuildMistWarGuardDetailModel")

function GuildMistWarGuardDetailModel:ctor()
    self.memberList = {}
    self.playerInfoModel = PlayerInfoModel.new()
    self.pid = self.playerInfoModel:GetID()
end

function GuildMistWarGuardDetailModel:InitWithProtocol(guardData, data)
    self.memberList = data
    self:SetGuardData(guardData)
    self:SetCurrentMember(guardData.name)
end

function GuildMistWarGuardDetailModel:GetMemberItemByPid(pid)
    for i = 1, #self.memberList do
        if self.memberList[i]._id == pid then
            return self.memberList[i]
        end
    end
end

function GuildMistWarGuardDetailModel:GetMemberItemByName(name)
    for i = 1, #self.memberList do
        if self.memberList[i].name == name then
            return self.memberList[i], i
        end
    end
end

function GuildMistWarGuardDetailModel:RemoveMemberItemByName(name)
    for i = 1, #self.memberList do
        if self.memberList[i].name == name then
            local data = clone(self.memberList[i])
            table.remove(self.memberList, i)
            return data
        end
    end
end

function GuildMistWarGuardDetailModel:RemoveMemberItemByPid(pid)
    for i = 1, #self.memberList do
        if self.memberList[i]._id == pid then
            table.remove(self.memberList, i)
            break
        end
    end
end

function GuildMistWarGuardDetailModel:SetCurrentMember(name, data)
    if name == nil then return end
    if self.currentMember then
        local member = self:RemoveMemberItemByName(name)
        local mData = clone(self.currentMember)
        table.insert(self.memberList, mData)
        self.currentMember = member
    else
        local member = self:RemoveMemberItemByName(name)
        self.currentMember = member
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

function GuildMistWarGuardDetailModel:GetCurrentMember()
    return self.currentMember
end

function GuildMistWarGuardDetailModel:SetGuardData(data)
    self.guardData = data
end

function GuildMistWarGuardDetailModel:GetGuardData()
    return self.guardData
end

function GuildMistWarGuardDetailModel:GetMemberList()
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

return GuildMistWarGuardDetailModel