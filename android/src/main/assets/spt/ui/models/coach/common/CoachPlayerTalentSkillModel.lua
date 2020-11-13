local Model = require("ui.models.Model")
local PlayerTalentSkill = require("data.PlayerTalentSkill")

local CoachPlayerTalentSkillModel = class(Model, "CoachPlayerTalentSkillModel")

function CoachPlayerTalentSkillModel:ctor()
    CoachPlayerTalentSkillModel.super.ctor(self)
end

function CoachPlayerTalentSkillModel:InitWithId(id)
    self.staticData = PlayerTalentSkill[tostring(id)] or {}
    self.id = id
end

-- 图标的主图标显示
function CoachPlayerTalentSkillModel:GetPicIcon()
    return self:GetIconIndex()
end

function CoachPlayerTalentSkillModel:GetIconIndex()
    return self.staticData.picIcon
end

function CoachPlayerTalentSkillModel:GetQualityName()
    return self.staticData.skillQuailtyName
end

function CoachPlayerTalentSkillModel:GetName()
    return self.staticData.skillName
end

-- 技能书背景
function CoachPlayerTalentSkillModel:GetDecoratePicIcon()
    return self.staticData.picBackGround
end

-- 获得技能描述
function CoachPlayerTalentSkillModel:GetDesc()
    return self.staticData.skillDesc
end

-- 获得技能等级
function CoachPlayerTalentSkillModel:GetSkillQuality()
    return self:GetQuality()
end

-- 获得技能适用条件
function CoachPlayerTalentSkillModel:GetSkillCondition()
    return self.staticData.conditionType
end

-- 获得技能适用类别
function CoachPlayerTalentSkillModel:GetSkillTalentType()
    return self.staticData.playerTalentType
end

-- 获得品质
function CoachPlayerTalentSkillModel:GetQuality()
    return self.staticData.quality
end

-- 入门品质
function CoachPlayerTalentSkillModel:GetQualitySign()
    return self.staticData.qualityPicIndex
end

return CoachPlayerTalentSkillModel
