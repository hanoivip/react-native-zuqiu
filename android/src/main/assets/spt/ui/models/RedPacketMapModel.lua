local RedPacket = require("data.RedPacket")
local Model = require("ui.models.Model")

local RedPacketMapModel = class(Model)

function RedPacketMapModel:ctor()
    RedPacketMapModel.super.ctor(self)
end

function RedPacketMapModel:Init(data)
    if not data then
        data = cache.getRedPacketMap()
    end
    self.data = data
end

function RedPacketMapModel:InitWithProtocol(data)
    data = data or {}
    local redPacketMap = {}
    for i, v in ipairs(data) do
        redPacketMap[tostring(v.id)] = v
    end
    cache.setRedPacketMap(redPacketMap)
    self:Init(redPacketMap)
end

function RedPacketMapModel:GetRedPacketAll()
    return self.data
end

function RedPacketMapModel:GetItemNum(id)
     return self.data[tostring(id)] and self.data[tostring(id)].num or 0
end

function RedPacketMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.redPacket then return end

    for i, v in ipairs(rewardTable.redPacket) do
        self:ResetRedPacketNum(v.id, v.num)
    end

end

function RedPacketMapModel:ResetRedPacketNum(id, num)
    assert(id and num and type(num) == "number")
    local idStr = tostring(id)
    if not self.data[idStr] then
        self.data[idStr] = {}
        self.data[idStr].id = id
    end
    self.data[idStr].num = num
    if num <= 0 then
        self.data[idStr] = nil
    end
    EventSystem.SendEvent("ItemsMapModel_ResetItemNum", id, num)
end

return RedPacketMapModel
