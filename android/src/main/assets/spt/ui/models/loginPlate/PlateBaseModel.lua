local Model = require("ui.models.Model")
local PlateBaseModel = class(Model)
-- 每个单独活动的model基类
function PlateBaseModel:ctor(data)
    PlateBaseModel.super.ctor(self)
    self.plateData = data
    self:InitWithProtocol()
end

function PlateBaseModel:InitWithProtocol()
end

function PlateBaseModel:GetPlateType()
    return self.plateData.type
end

function PlateBaseModel:GetPlateData()
    return self.plateData
end

function PlateBaseModel:GetPlateId()
    return tonumber(self.plateData.id)
end

return PlateBaseModel
