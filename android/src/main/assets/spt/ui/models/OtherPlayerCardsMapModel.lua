
local Model = require("ui.models.Model")

local OtherPlayerCardsMapModel = class(Model, "OtherPlayerCardsMapModel")

function OtherPlayerCardsMapModel:ctor()
    OtherPlayerCardsMapModel.super.ctor(self)
end

function OtherPlayerCardsMapModel:Init(data)
    if not data then
        data = cache.getOtherPlayerCardsMap()
    end
    self.data = data
end

function OtherPlayerCardsMapModel:InitWithProtocol(data)
    assert(type(data) == "table")
    cache.setOtherPlayerCardsMap(data)
    self:Init(data)
end

function OtherPlayerCardsMapModel:GetCardData(pcid)
    return self.data[tostring(pcid)]
end

-- �Ƿ����cid�Ŀ���
function OtherPlayerCardsMapModel:IsExistCardID(cid)
    assert(cid)
    for pcid, v in pairs(self.data) do
        if tostring(v.cid) == tostring(cid) then
            return true, pcid
        end
    end
    return false
end

return OtherPlayerCardsMapModel