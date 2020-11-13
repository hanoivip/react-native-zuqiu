local Model = require("ui.models.Model")
local ActivityLabelModel = class(Model)

local DefaultIndex = 1
function ActivityLabelModel:ctor(index)
    ActivityLabelModel.super.ctor(self)
    self:SetSelectLabel(index)
end

function ActivityLabelModel:GetSelectLabel()
    return self.labelIndex 
end

function ActivityLabelModel:SetSelectLabel(index)
    self.labelIndex = index or DefaultIndex
end

return ActivityLabelModel
