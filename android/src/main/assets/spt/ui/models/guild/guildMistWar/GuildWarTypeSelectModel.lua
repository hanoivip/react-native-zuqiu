local GuildWar = require("data.GuildWar")
local GuildWarBaseSet = require("data.GuildWarBaseSet")
local GUILDWAR_STATE = require("ui.controllers.guild.guildWar.GUILDWAR_STATE")
local GuildWarRegisterState = require("ui.models.guild.guildMistWar.GuildWarRegisterState")
local GuildWarType = require("ui.models.guild.guildMistWar.GuildWarType")

local Model = require("ui.models.Model")

local GuildWarTypeSelectModel = class(Model, "GuildWarTypeSelectModel")

function GuildWarTypeSelectModel:ctor()
    GuildWarTypeSelectModel.super.ctor(self)
    self.guildInfo = nil
end

function GuildWarTypeSelectModel:Init()

end

function GuildWarTypeSelectModel:InitWithProtocol(data)
    --state = false,
    --level = -1,  -- 报名层级
    --openLevel = 3,  -- 历史最大层级
    self.data = data
end

function GuildWarTypeSelectModel:GetCommonRegisterState()
    local state = self:GetRegisterStateByWarType(GuildWarType.Common)
    return state
end

function GuildWarTypeSelectModel:GetMistRegisterState()
    local state = self:GetRegisterStateByWarType(GuildWarType.Mist)
    return state
end

function GuildWarTypeSelectModel:GetRegisterStateByWarType(warType)
    local level = self:GetRegisterLevel()
    local levelStr = tostring(level)
    local openMaxLevel = self.data.openMaxLevel
    local state = self.data.state
    local addition = self:GetAdditionByWarType(warType)
    local isLock = openMaxLevel < addition
    if isLock then
        return GuildWarRegisterState.Lock
    end
    if state == GUILDWAR_STATE.NOTSIGN or state == GUILDWAR_STATE.PREFINISH then
        return GuildWarRegisterState.CanRegister
    else
        local currWarType = GuildWar[levelStr] and GuildWar[levelStr].type
        if not currWarType then
            return GuildWarRegisterState.CanRegister
        end
        if currWarType == warType then
            return GuildWarRegisterState.Registered
        else
            return GuildWarRegisterState.NoneRegister
        end
    end
end

-- 解锁条件
function GuildWarTypeSelectModel:GetAdditionByWarType(warType)
    local addition = GuildWarBaseSet[warType].addition or 0
    return addition
end

function GuildWarTypeSelectModel:GetRegisterLevel()
    local level = self.data.level
    return level
end

-- 是否被降级
function GuildWarTypeSelectModel:GetShowTips()
    local showTips = self.data.showTips
    return showTips
end

function GuildWarTypeSelectModel:GetRegisterMinLevel()
    local level = self:GetRegisterLevel()
    local levelStr = tostring(level)
    local minLevel = GuildWar[levelStr].minLevel
    return minLevel
end

function GuildWarTypeSelectModel:SetGuildInfo(guildInfo)
    self.guildInfo = guildInfo
end

function GuildWarTypeSelectModel:GetGuildInfo()
    return self.guildInfo
end

function GuildWarTypeSelectModel:GetRegisterInfo()
    return self.data
end

return GuildWarTypeSelectModel
