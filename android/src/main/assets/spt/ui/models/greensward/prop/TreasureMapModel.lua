local Model = require("ui.models.Model")

local TreasureMapModel = class(Model, "TreasureMapModel")

function TreasureMapModel:ctor()
    TreasureMapModel.super.ctor(self)
end

function TreasureMapModel:Init()
    TreasureMapModel.super.Init(self)
end

function TreasureMapModel:InitWithProtocol(data)
    self.data = data
end

function TreasureMapModel:SetItemModel(greenswardItemModel)
    self.itemModel = greenswardItemModel
end

function TreasureMapModel:IsTreasure(key)
    for k, v in ipairs(self.data) do
        if v == key then
            return true
        end
    end
    return false
end

function TreasureMapModel:GetConditionMapData()
    local result = {}
    for k, v in ipairs(self.data) do
        local splitIdx = string.find(v, "_")
        if splitIdx then
            local row = tonumber(string.sub(v, 1, splitIdx - 1))
            local col = tonumber(string.sub(v, splitIdx + 1, string.len(v)))
            table.insert(result, {row = row, col = col})
        end
    end
    return result
end

return TreasureMapModel
