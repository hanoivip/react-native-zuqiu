local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local DetectingEventModel1 = class(GreenswardEventModel, "DetectingEventModel1")

function DetectingEventModel1:ctor()
    DetectingEventModel1.super.ctor(self)
end

function DetectingEventModel1:TriggerEvent()

end

return DetectingEventModel1