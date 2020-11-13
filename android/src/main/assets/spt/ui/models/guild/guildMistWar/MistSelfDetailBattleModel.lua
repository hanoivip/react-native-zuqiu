local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Model = require("ui.models.Model")

local MistSelfDetailBattleModel = class(Model, "MistSelfDetailBattleModel")

function MistSelfDetailBattleModel:ctor()
    MistSelfDetailBattleModel.super.ctor(self)
    self.cacheData = {}
end

function MistSelfDetailBattleModel:InitWithProtocol(data)
    assert(data)
    if type(data) == "table" then
        for k, v in pairs(data) do
            table.insert(self.cacheData, v)
        end
        self:ResetData()
    end
end

function MistSelfDetailBattleModel:ResetData()
    local id = PlayerInfoModel.new():GetID()
    table.sort(self.cacheData, function (a, b)
        if a._id == tostring(id) then
            return true
        elseif b._id == tostring(id) then
            return false
        end
        if a.remainCount ~= b.remainCount then
            return a.remainCount > b.remainCount
        else
            if a.power ~= b.power then
                return a.power > b.power
            else
                return a.lvl > b.lvl
            end
        end
    end)
end

function MistSelfDetailBattleModel:GetTotalRemainCount()
    local total = 0
    for i, v in ipairs(self.cacheData) do
        local rCount = v.remainCount or 0
        total = total + rCount
    end
    return total
end

function MistSelfDetailBattleModel:GetDatas()
    return self.cacheData
end

return MistSelfDetailBattleModel
