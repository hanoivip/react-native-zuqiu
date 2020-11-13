local Model = require("ui.models.Model")

local ChatTipDialogModel = class(Model, "ChatItemModel")

function ChatTipDialogModel:ctor(sender)
    self.sender = sender
end

function ChatTipDialogModel:GetName()
    return self.sender.name
end

function ChatTipDialogModel:GetLevel()
    return self.sender.lvl
end

function ChatTipDialogModel:GetTeamLogoInfo()
    return self.sender.logo
end

function ChatTipDialogModel:GetSender()
    return self.sender
end

function ChatTipDialogModel:GetPid()
    return self.sender.pid
end

return ChatTipDialogModel