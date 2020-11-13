local Model = require("ui.models.Model")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local ChatRedPacketModel = class(Model, "ChatRedPacketModel")

function ChatRedPacketModel:ctor()
    self.recdList = {}
    self.canView = true
    self.isopen = false
end

function ChatRedPacketModel:InitWithProtrol(data)
    self.data = data
    self.recdList = {}
    if self.data.recd then
        for k, v in pairs(self.data.recd) do
            v._id = k
            table.insert(self.recdList, v)
        end
    end
end

function ChatRedPacketModel:GetDate()
    return self.data.date
end

function ChatRedPacketModel:GetPacketId()
    return self.data._id
end

function ChatRedPacketModel:GetIdType()
    return self.data.id
end

function ChatRedPacketModel:GetDiamondSum()
    return self.data.sum
end

function ChatRedPacketModel:GetOpenState()
    return self.isopen
end

function ChatRedPacketModel:SetOpenState(state)
    self.isopen = state
end

function ChatRedPacketModel:GetNum()
    return self.data.num
end

function ChatRedPacketModel:GetRewardContents()
    return self.data.contents
end

function ChatRedPacketModel:GetRecdList()
    table.sort(self.recdList, function(a, b) return tonumber(a.c_t) > tonumber(b.c_t)  end)
    return self.recdList
end

function ChatRedPacketModel:SetCanViewState(state)
    self.canView = state
end

function ChatRedPacketModel:GetCanViewState()
    return self.canView
end

function ChatRedPacketModel:GetSelfDiamond()
    local playerInfoModel = PlayerInfoModel.new()
    local mid = playerInfoModel:GetID()
    local diamond = 0
    for i = 1 , #self.recdList do
        if self.recdList[i]._id == mid then
            diamond = self.recdList[i].d
            break
        end
    end
    return diamond
end

function ChatRedPacketModel:IsSelfGetState()
    local playerInfoModel = PlayerInfoModel.new()
    local mid = playerInfoModel:GetID()
    local isGet = false
    for i = 1 , #self.recdList do
        if self.recdList[i]._id == mid then
            isGet = true
            break
        end
    end
    return isGet
end

function ChatRedPacketModel:GetContent()
    return self.data.title
end

return ChatRedPacketModel