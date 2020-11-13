local CoachTalentModel = require("ui.models.coach.talent.CoachTalentModel")

local OtherCoachTalentModel = class(CoachTalentModel, "OtherCoachTalentModel")

function OtherCoachTalentModel:ctor()
    OtherCoachTalentModel.super.ctor(self)
end

function OtherCoachTalentModel:InitWithProtocol(talent)
    self.cacheData = talent
    self:ParseConfigData(self.cacheData)
end

function OtherCoachTalentModel:GetStatusData()
    return self.cacheData
end

return OtherCoachTalentModel
