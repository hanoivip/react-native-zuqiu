local Model = require("ui.models.Model")

local ChatPacketItemModel = class(Model, "ChatPacketItemModel")

function ChatPacketItemModel:ctor(data)
    self.data = data
end

function ChatPacketItemModel:GetName()
    return self.data.name
end

function ChatPacketItemModel:GetTeamLogoInfo()
    return self.data.logo
end

function ChatPacketItemModel:GetDate()
    return self.data.c_t
end

function ChatPacketItemModel:GetDiamond()
    if not self.data.d then
        return self:GetRedPacketCount()
    end
    return self.data.d
end

function ChatPacketItemModel:GetRedPacketCount()
    local num = 0
    for k, v in pairs(self.data.contents) do
        if type(v) == "number" then
            num = v
        else
            num = v[1].num
        end
    end
    return num
end

return ChatPacketItemModel
