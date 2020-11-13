local Model = require("ui.models.Model")

local ChatItemModel = class(Model, "ChatItemModel")

local lineLimit = 22
local oneLineHeight = 24
local confHeight = 70
local packetHeight = 194

function ChatItemModel:ctor(serverData)
    self.serverData = serverData
end

function ChatItemModel:GetMessage()
    return self.serverData.content
end

function ChatItemModel:GetName()
    return self.serverData.sender.name or ""
end

function ChatItemModel:GetLevel()
    return self.serverData.sender.lvl or 1
end

function ChatItemModel:GetTeamLogoInfo()
    return self.serverData.sender.logo
end

function ChatItemModel:GetPid()
    return self.serverData.sender.pid or ""
end

function ChatItemModel:GetSid()
    return self.serverData.sender.sid or ""
end

function ChatItemModel:GetServer()
    return " ." .. self:GetSid()
end

function ChatItemModel:GetServerName()
    return self.serverData.sender.serverName or ""
end

function ChatItemModel:GetSender()
    return self.serverData.sender
end

function ChatItemModel:GetIsSelf()
    return self.serverData.isSelf == 1
end

function ChatItemModel:GetForm()
    return self.serverData.form
end

function ChatItemModel:GetAuthority()
    return self.serverData.sender.authority
end

function ChatItemModel:GetTheTextHeight()
    local message = self.serverData.content
    if type(message) == "string" then
        if not message or string.len(message) == 0 then
            return oneLineHeight + confHeight
        end
        local textTab = clr.splitstr(message)
        local lineCount = 1
        local cnt = 0
        for i = 1, #textTab do
            if textTab[i] == "\n" or cnt >= lineLimit then
                lineCount = lineCount + 1
                cnt = 0
            end
            cnt = cnt + 1
        end
        return lineCount * oneLineHeight + confHeight
    else
        return packetHeight
    end
end

return ChatItemModel
