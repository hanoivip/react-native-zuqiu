local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Model = require("ui.models.Model")

local SelfDetailBattleModel = class(Model)

function SelfDetailBattleModel:ctor()
    SelfDetailBattleModel.super.ctor(self)
    self.cacheData = {}
end

function SelfDetailBattleModel:InitWithProtocal(data)
    assert(data)
    if type(data) == "table" then
        for k, v in pairs(data) do
            table.insert(self.cacheData, v)
        end
        self:ResetData()
    end
end

function SelfDetailBattleModel:ResetData()
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

function SelfDetailBattleModel:GetDatas()
    return self.cacheData
end




return SelfDetailBattleModel