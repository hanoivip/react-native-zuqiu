local Model = require("ui.models.Model")
local ArenaStore = require("data.ArenaStore")

local ArenaStoreModel = class(Model, "ArenaStoreModel")

function ArenaStoreModel:ctor()
    self.data = {}
    self.super.ctor(self)
end

function ArenaStoreModel:Init()
    for k, v in pairs(ArenaStore) do
        table.insert(self.data, v)
    end
    table.sort(self.data, function (a, b)
        return a.ID < b.ID
    end)
end

function ArenaStoreModel:GetStoreData()
    return self.data
end

function ArenaStoreModel:GetStoreDataByIndex(index)
    return self.data[index]
end

return ArenaStoreModel