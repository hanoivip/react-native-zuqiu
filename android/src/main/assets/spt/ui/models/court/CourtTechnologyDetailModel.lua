local Model = require("ui.models.Model")
local CourtTechnologyDetailModel = class(Model, "CourtTechnologyDetailModel")

function CourtTechnologyDetailModel:ctor()
    CourtTechnologyDetailModel.super.ctor(self)
end

function CourtTechnologyDetailModel:SetTechnologyTitle(titleStr)
	self.titleStr = titleStr
end

function CourtTechnologyDetailModel:GetTechnologyTitle()
    return self.titleStr
end

function CourtTechnologyDetailModel:SetBarResPath(barPath)
	self.barPath = barPath
end

function CourtTechnologyDetailModel:GetBarResPath()
	return self.barPath
end

return CourtTechnologyDetailModel