local Model = require("ui.models.Model")
local GreenswardStarModel = require("ui.models.greensward.star.GreenswardStarModel")
local AdventureStarEffect = require("data.AdventureStarEffect")

local GreenswardStarLibModel = class(Model, "GreenswardStarLibModel")

function GreenswardStarLibModel:ctor()
    self.starModels = nil
    GreenswardStarLibModel.super.ctor(self)
end

function GreenswardStarLibModel:Init()
    GreenswardStarLibModel.super.Init(self)
    self.starModels = {}
    for id, config in pairs(AdventureStarEffect) do
        local greenswardStarModel = GreenswardStarModel.new(id)
        table.insert(self.starModels, greenswardStarModel)
    end
    table.sort(self.starModels, function(a, b)
        return tonumber(a:GetId()) < tonumber(b:GetId())
    end)
end

function GreenswardStarLibModel:GetStarModels()
    return self.starModels
end

return GreenswardStarLibModel
