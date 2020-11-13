local Model = require("ui.models.Model")
local ArenaKnockoutModel = class(Model, "ArenaKnockoutModel")

function ArenaKnockoutModel.GetInstance()
    return ArenaKnockoutModel.Instance
end

function ArenaKnockoutModel.ClearInstance()
    ArenaKnockoutModel.Instance = nil
end

function ArenaKnockoutModel:ctor()
    ArenaKnockoutModel.super.ctor(self)
    ArenaKnockoutModel.Instance = self
end

function ArenaKnockoutModel:Init(data)
    self.data = data or {}
end

function ArenaKnockoutModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

function ArenaKnockoutModel:GetMatchScheduleData(matchScheduleType)
    return self.data[matchScheduleType]
end

return ArenaKnockoutModel