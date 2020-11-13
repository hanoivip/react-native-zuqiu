local Model = require("ui.models.Model")
local GuildLogo = require("data.GuildLogo")
local GuildSettingModel = class(Model, "GuildSettingModel")

local RequestTypeStr = {
    lang.transstr("guild_reqAuto1"),
    lang.transstr("guild_reqAuto2")
}

function GuildSettingModel:ctor()
    self.currentIndex = 1
    self.chooseIndex = 1
    self.requestLevel = 1
    self.requestType = 0
    self.invitationType = 0
    self.maxRequestLevel = 60
    self.minRequestLevel = 1
    self.autoRequestType = 1
    self.notAutoRequestType = 0
    self.autoInviteType = 1
    self.notAutoInviteType = 0
    self.price = 500

    self.name = ""
    self.notice = ""
end

function GuildSettingModel:GetGuildName()
    return self.name
end

function GuildSettingModel:GetPrice()
    return self.price
end

function GuildSettingModel:SetGuildName(str)
    self.name = str
end

function GuildSettingModel:GetGuildNotice()
    return self.notice
end

function GuildSettingModel:InitWithProtocal(data)
    self.name = data.name
    self.notice = data.msg
    self.currentIndex = data.eid
    self.chooseIndex = data.eid
    self.requestType = data.requestAcceptType
    self.invitationType = data.autoInviteNewPlayer
    self.requestLevel = data.minPlayerLvl
    self.changeNameCoolDown = data.changeNameCoolDown or false
end

function GuildSettingModel:GetIconInfo()
    local list = {}

    for k, v in pairs(GuildLogo) do
        v.index = tonumber(k)
        table.insert(list, v)
    end

    table.sort(list, function(a, b) return a.order < b.order end)
    return list
end

function GuildSettingModel:GetRequestTypeStr()
    return RequestTypeStr[self:GetRequestType() + 1]
end

function GuildSettingModel:SetRequestTypeAuto()
    self.requestType = self.autoRequestType
end

function GuildSettingModel:SetRequestTypeNotAuto()
    self.requestType = self.notAutoRequestType
end

function GuildSettingModel:SetInvitationNewPlayerType(isLeft)
    if isLeft then
        self.invitationType = self.notAutoRequestType
    else
        self.invitationType = self.autoInviteType
    end
end

function GuildSettingModel:GetInvitationNewPlayerType()
    return self.invitationType
end

function GuildSettingModel:GetIsInvitationLeftType()
    return self.invitationType == self.notAutoRequestType
end

function GuildSettingModel:GetAutoRequestType()
    return self.autoRequestType
end

function GuildSettingModel:GetNotAutoRequestType()
    return self.notAutoRequestType
end

function GuildSettingModel:GetRequestType()
    return self.requestType
end

function GuildSettingModel:AddRequestLevel()
    if self.requestLevel < self.maxRequestLevel then
        self.requestLevel = self.requestLevel + 1
    end
end

function GuildSettingModel:MinusRequestLevel()
    if self.requestLevel > self.minRequestLevel then
        self.requestLevel = self.requestLevel - 1
    end
end

function GuildSettingModel:GetRequestLevel()
    return self.requestLevel
end

function GuildSettingModel:GetMaxRequestLevel()
    return self.maxRequestLevel
end

function GuildSettingModel:GetMinRequestLevel()
    return self.minRequestLevel
end

function GuildSettingModel:GetCurrentIndex()
    return self.currentIndex
end

function GuildSettingModel:SetCurrentIndex(index)
    self.currentIndex = index
end

function GuildSettingModel:GetChooseIndex()
    return self.chooseIndex
end

function GuildSettingModel:SetChooseIndex(index)
    self.chooseIndex = index
end

function GuildSettingModel:GetChangeNameCoolDown()
    return self.changeNameCoolDown
end

return GuildSettingModel