local PasterMainType = require("ui.scene.paster.PasterMainType")
local Model = require("ui.models.Model")
local PasterTextModel = class(Model, "PasterTextModel")

function PasterTextModel:ctor(key, generalColor, weekColor, monthColor, honorColor, annualColor, competeColor)
    PasterTextModel.super.ctor(self)
    self.key = key
    self.generalColor = generalColor
    self.weekColor = weekColor
    self.monthColor = monthColor
    self.honorColor = honorColor
    self.annualColor = annualColor
    self.competeColor = competeColor
end

function PasterTextModel:GetTextColor(pasterType)
    local textColor
    if tonumber(pasterType) == PasterMainType.General then
        textColor = self.generalColor
    elseif tonumber(pasterType) == PasterMainType.Week then
        textColor = self.weekColor
    elseif tonumber(pasterType) == PasterMainType.Month then
        textColor = self.monthColor
    elseif tonumber(pasterType) == PasterMainType.Honor then
        textColor = self.honorColor
    elseif tonumber(pasterType) == PasterMainType.Annual then
        textColor = self.annualColor
    elseif tonumber(pasterType) == PasterMainType.Compete then
        textColor = self.competeColor
    end
    return textColor
end

return PasterTextModel