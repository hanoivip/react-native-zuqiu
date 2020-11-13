local PasterMainType = require("ui.scene.paster.PasterMainType")
local Model = require("ui.models.Model")
local PasterImageModel = class(Model, "PasterImageModel")

function PasterImageModel:ctor(key, generalPath, weekPath, monthPath, honorPath, annualPath, competePath)
    PasterImageModel.super.ctor(self)
    self.key = key
    self.generalPath = generalPath
    self.weekPath = weekPath
    self.monthPath = monthPath
    self.honorPath = honorPath
    self.annualPath = annualPath
    self.competePath = competePath
end

function PasterImageModel:GetImageRes(pasterType)
    local resPath
    if tonumber(pasterType) == PasterMainType.General then
        resPath = self.generalPath
    elseif tonumber(pasterType) == PasterMainType.Week then
        resPath = self.weekPath
    elseif tonumber(pasterType) == PasterMainType.Month then
        resPath = self.monthPath
    elseif tonumber(pasterType) == PasterMainType.Honor then
        resPath = self.honorPath
    elseif tonumber(pasterType) == PasterMainType.Annual then
        resPath = self.annualPath
    elseif tonumber(pasterType) == PasterMainType.Compete then
        resPath = self.competePath
    end
    return res.LoadRes(resPath)
end

return PasterImageModel