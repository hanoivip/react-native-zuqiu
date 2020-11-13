local Model = require("ui.models.Model")
local CoachItemBaseModel = require("ui.models.coach.common.CoachItemBaseModel")
local AssistantCoachInformation = require("data.AssistantCoachInformation")

local AssistCoachInfoModel = class(CoachItemBaseModel, "AssistCoachInfoModel")

function AssistCoachInfoModel:ctor()
    AssistCoachInfoModel.super.ctor(self)
end

function AssistCoachInfoModel:GetStaticConfig(id)
    return AssistantCoachInformation[tostring(id)] or {}
end

-- 判断是否为无阶级情报（0为否，1为是）
function AssistCoachInfoModel:GetSuperInformation()
    return self.staticData.superInformation
end

-- 判断是否为无阶级情报（0为否，1为是）
function AssistCoachInfoModel:IsSuperInformation()
    local superInformation = self:GetSuperInformation()
    return superInformation == 1
end

-- 情报的星级
function AssistCoachInfoModel:GetAssistantInfoQuailty()
    return self.staticData.assistantCoachQuality
end

-- 助理教练情报特点的类型（1属性类别，2基础属性，3属性成长，4单技能技能，5全技能）
function AssistCoachInfoModel:GetAssistantInfoType()
    return self.staticData.informationType
end

-- 获得保底数量
function AssistCoachInfoModel:GetAssistantInfoAmount()
    return self.staticData.informationAmount
end

-- 分解助理教练情报获得基础助理教练经验书数量
function AssistCoachInfoModel:GetAssistantInfoSplitAmount()
    return self.staticData.splitAmount
end

-- 合成时，生效百分比，0-100
function AssistCoachInfoModel:SetComposeEfxProbability(per)
    self.efx = per
end

function AssistCoachInfoModel:GetComposeEfxProbability()
    return self.efx or 0
end

return AssistCoachInfoModel
