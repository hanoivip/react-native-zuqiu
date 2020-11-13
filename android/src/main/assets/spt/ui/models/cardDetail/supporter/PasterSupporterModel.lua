local Model = require("ui.models.Model")

local PasterSupporterModel = class(Model, "PasterSupporterModel")

function PasterSupporterModel:ctor(supporterModel)
    PasterSupporterModel.super.ctor(self)
    self.supporterModel = supporterModel
end

function PasterSupporterModel:Init()

end

function PasterSupporterModel:GetSupportCardModel()
	return self.supporterModel:GetSupportCardModel()
end

function PasterSupporterModel:GetCardModel()
	return self.supporterModel:GetCardModel()
end

return PasterSupporterModel
