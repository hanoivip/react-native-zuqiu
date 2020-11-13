local Model = require("ui.models.Model")
local GuildRedEnvelope = require("data.GuildRedEnvelope")

local GuildSignInModel = class(Model, "GuildSignInModel")

function GuildSignInModel:ctor()
    
end

function GuildSignInModel:InitWithProtocol(data)
    self.data = data
end

function GuildSignInModel:SetMemberNum(num)
    self.memberNum = num
end

function GuildSignInModel:GetMemberNum()
    return self.memberNum
end

function GuildSignInModel:GetSignNum()
    return self.data.guildSign
end

function GuildSignInModel:SetSignNum(num)
    self.data.guildSign = num
end

function GuildSignInModel:GetRedPacketInfo()
    return self.data.redEnvelope
end

function GuildSignInModel:SetProgress(num)
    self.data.progress = num
end

function  GuildSignInModel:GetProgress()
    return self.data.progress
end

function GuildSignInModel:GetSelfSignState()
    return self.data.selfSign
end

function GuildSignInModel:SetSelfSignState(state)
    self.data.selfSign = state
end

function GuildSignInModel:SetPacketSendState(index, isSend)
    self.data.redEnvelope[index].send = isSend
end

function GuildSignInModel:GetConfig()
    return GuildRedEnvelope
end

function GuildSignInModel:GetDiamondPrice()
    return 30
end

function GuildSignInModel:GetCoinPrice()
    return 10
end

return GuildSignInModel