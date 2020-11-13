local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local EquipPieceMapModel = class(Model, "EquipPieceMapModel")

function EquipPieceMapModel:ctor()
    EquipPieceMapModel.super.ctor(self)
end

function EquipPieceMapModel:Init(data)
    if not data then
        data = cache.getEquipPiece()
    end
    self.data = data
end

function EquipPieceMapModel:InitWithProtocol(data)
    assert(type(data) == "table")
    local equipPieceMap = {}
    for k, v in pairs(data) do
        equipPieceMap[tostring(v.pid)] = v
    end
    cache.setEquipPiece(equipPieceMap)

    self:Init(equipPieceMap)
end

function EquipPieceMapModel:GetEquipPieces()
    return self.data
end

function EquipPieceMapModel:GetEquipPieceNum(pid)
    return self.data[tostring(pid)] and self.data[tostring(pid)].num or 0
end

function EquipPieceMapModel:ResetEquipPieceNum(pid, num)
    assert(pid and num, "EquipPieceMapModel:ResetEquipPieceNum(" .. tostring(pid) .. ", " .. tostring(num) .. ")")
    local pidStr = tostring(pid)
    if self.data[pidStr] == nil then
        self.data[pidStr] = {}
        self.data[pidStr].pid = pid
    end
    self.data[pidStr].num = num

    EventSystem.SendEvent("EquipPieceMapModel_ResetItemNum", pid, num)
end

function EquipPieceMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.equipPiece then return end
    
    for i, v in ipairs(rewardTable.equipPiece) do
        self:ResetEquipPieceNum(v.pid, v.num)
    end
    
    EventSystem.SendEvent("EquipPieceMapModel_UpdateFromReward")
end

return EquipPieceMapModel
