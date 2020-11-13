local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local EquipsMapModel = class(Model, "EquipsMapModel")

function EquipsMapModel:ctor()
    EquipsMapModel.super.ctor(self)
end

function EquipsMapModel:Init(data)
    if not data then
        data = cache.getEquipsMap()
    end
    self.data = data
end

function EquipsMapModel:InitWithProtocol(data)
    assert(type(data) == "table")
    local equipsMap = {}
    for i, v in ipairs(data) do
        equipsMap[tostring(v.eid)] = v
    end
    cache.setEquipsMap(equipsMap)
    self:Init(equipsMap)
end

function EquipsMapModel:GetEquips()
    return self.data
end

function EquipsMapModel:GetEquipData(eid)
    return self.data[tostring(eid)]
end

function EquipsMapModel:GetEquipNum(eid)
    return self.data[tostring(eid)] and self.data[tostring(eid)].num or 0
end

function EquipsMapModel:ResetEquipNum(eid, num)
    assert(eid and num, "EquipsMapModel:ResetEquipNum(" .. tostring(eid) .. ", " .. tostring(num) .. ")")
    local eidStr = tostring(eid)
    if self.data[eidStr] == nil then
        self.data[eidStr] = {}
        self.data[eidStr].eid = eid
    end
    self.data[eidStr].num = num
    if tonumber(num) == 0 then
        self.data[eidStr] = nil
    end

    EventSystem.SendEvent("EquipsMapModel_ResetEquipNum", eid, num)
end

function EquipsMapModel:UpdateFromReward(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")
    if not rewardTable.eqs then return end

    for i, v in ipairs(rewardTable.eqs) do
        self:ResetEquipNum(v.eid, v.num)
    end

    EventSystem.SendEvent("EquipsMapModel_UpdateFromReward")
end

return EquipsMapModel
