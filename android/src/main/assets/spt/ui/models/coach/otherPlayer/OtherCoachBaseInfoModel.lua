local CoachBaseInfoModel = require("ui.models.coach.baseInfo.CoachBaseInfoModel")
local Formation = require("data.Formation")
local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachMainModel = require("ui.models.coach.CoachMainModel")

local OtherCoachBaseInfoModel = class(CoachBaseInfoModel, "OtherCoachBaseInfoModel")

function OtherCoachBaseInfoModel:ctor()
    OtherCoachBaseInfoModel.super.ctor(self)
end

function OtherCoachBaseInfoModel:InitWithProtocol(coach, otherPlayerCardsMapModel, otherPlayerTeamsModel)
    self.data = coach
    self.otherPlayerCardsMapModel = otherPlayerCardsMapModel
    self.playerTeamsModel = otherPlayerTeamsModel
    self.coachMainModel = CoachMainModel.new()

    self.lvlId = tostring(self.data.lvl)
    for k, v in pairs(CoachBaseLevel) do
        if tonumber(k) > self.maxCoachLvl then
            self.maxCoachLvl = tonumber(k)
        end
    end
    if self.data.lvl >= self.maxCoachLvl then self.isCoachMaxLevel = true end
    self.exp = self.data.exp
    self.formationId = self.playerTeamsModel:GetFormationId()
    self.formationName = Formation[tostring(self.formationId)].name
    self.tacticsData = self.playerTeamsModel:GetTacticsData()

    self.tacticNameCache = {}
    self:ParseData(self.data)
end

function OtherCoachBaseInfoModel:GetStatusData()
    return self.data, self.otherPlayerCardsMapModel
end

return OtherCoachBaseInfoModel
