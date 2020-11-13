local Model = require("ui.models.Model")
local FancyEntryModel = class(Model, "FancyEntryModel")

function FancyEntryModel:ctor()
    FancyEntryModel.super.ctor(self)
end

function FancyEntryModel:Init(data)
    self.data = data
end

function FancyEntryModel:InitWithProtocol(data)
    assert(type(data) == "table")
    self:Init(data)
end

return FancyEntryModel
