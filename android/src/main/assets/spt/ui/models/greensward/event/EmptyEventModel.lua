local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local EmptyEventModel = class(GreenswardEventModel, "EmptyEventModel")

function EmptyEventModel:ctor()
    EmptyEventModel.super.ctor(self)
end

function EmptyEventModel:TriggerEvent()

end

return EmptyEventModel