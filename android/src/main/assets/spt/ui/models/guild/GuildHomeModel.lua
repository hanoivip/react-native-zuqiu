local Model = require("ui.models.Model")
local GUILD_MEMBERTYPE = require("ui.controllers.guild.GUILD_MEMBERTYPE")
local GuildHomeModel = class(Model, "GuildHomeModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

function GuildHomeModel:ctor()
    self.playerInfoModel = PlayerInfoModel.new()
    self.memberList = {}
    self.requestList = {}
    self.memberManager = false
    self.authority = nil
    self.pid = nil
    self.moveUp = true
end

function GuildHomeModel:InitWithProtocal(data)
    if data == nil then return end
    self.data = data
    if self.data.member then
        self.authority = self.data.member.authority
        self.pid = self.data.member._id
        self.cumulativeTotal = self.data.member.cumulativeTotal
    end
    self.baseInfo = self.data.base
    self.gid = self.baseInfo.gid

    local guild = {
        name = self.baseInfo.name,
        authority = self.authority,
        gid = self.baseInfo.gid
    }
    self.playerInfoModel:SetGuild(guild)
end

function GuildHomeModel:GetGuildWarTip()
    return self.data.guildWarTip
end

function GuildHomeModel:GetGid()
    return self.gid
end

function GuildHomeModel:GetMoveUpState()
    return self.moveUp
end

function GuildHomeModel:SetMoveUpState()
    self.moveUp = not self.moveUp
end

function GuildHomeModel:GetGuildBaseInfo()
    return self.baseInfo
end

function GuildHomeModel:GetSelfPid()
    return self.pid
end

function GuildHomeModel:GetCumulativeTotal()
    return self.baseInfo.cumulativeTotal
end

function GuildHomeModel:AddGuildMemberNum()
    self.baseInfo.memberNum = self.baseInfo.memberNum + 1
end

function GuildHomeModel:ReduceGuildMemberNum()
    self.baseInfo.memberNum = self.baseInfo.memberNum - 1
end

function GuildHomeModel:GetGuildMemberNum()
    return self.baseInfo.memberNum
end

function GuildHomeModel:SetGuildBaseInfo(data)
    self.baseInfo = data
end

function GuildHomeModel:GetMyselfAuthority()
    return self.authority
end

function GuildHomeModel:SetMyselfAuthority(authority)
    self.authority = authority
end

function GuildHomeModel:SetMemberList(mlist)
    self.memberList = mlist
end

function GuildHomeModel:GetMemberList()
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
            return a.authority < b.authority
        else
            return a.self > b.self
        end
    end)
    return self.memberList
end

function GuildHomeModel:ChangeMemberAuthority(pid, authority)
    for i = 1, #self.memberList do 
        if self.memberList[i]._id == pid then
            self.memberList[i].authority = authority
            break
        end
    end
end

function GuildHomeModel:ChangeMemberAdmin(pid)
    for i = 1, #self.memberList do 
        if self.memberList[i].authority == GUILD_MEMBERTYPE.ADMIN then
            self.memberList[i].authority = GUILD_MEMBERTYPE.VP
        end
    end
    self:ChangeMemberAuthority(pid, GUILD_MEMBERTYPE.ADMIN)
    self:SetMyselfAuthority(GUILD_MEMBERTYPE.VP)
end

function GuildHomeModel:RemoveMember(pid)
    for i = 1, #self.memberList do 
        if self.memberList[i]._id == pid then
            table.remove(self.memberList, i)
            break
        end
    end
end

function GuildHomeModel:SetMemberManager()
    self.memberManager = not self.memberManager    
    EventSystem.SendEvent("GuildMember_ManagerEvent", self.memberManager)
end

function GuildHomeModel:GetMemberManager()
    return self.memberManager
end

function GuildHomeModel:RefreshCumulativeDay(cumulativeTotal)
    self.baseInfo.cumulativeTotal = cumulativeTotal
end

return GuildHomeModel