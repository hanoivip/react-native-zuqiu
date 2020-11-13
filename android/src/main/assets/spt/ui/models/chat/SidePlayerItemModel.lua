local Model = require("ui.models.Model")

local SidePlayerItemModel = class(Model, "ChatItemModel")

function SidePlayerItemModel:ctor(sender)
    self.sender = sender
end

function SidePlayerItemModel:GetName()
    return self.sender.name
end

function SidePlayerItemModel:GetTeamLogoInfo()
    return self.sender.logo
end

function SidePlayerItemModel:GetPid()
    return self.sender.pid
end

function SidePlayerItemModel:GetSid()
    return self.sender.sid
end

return SidePlayerItemModel
