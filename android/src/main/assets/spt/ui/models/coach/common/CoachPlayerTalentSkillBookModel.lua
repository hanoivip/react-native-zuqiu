local Model = require("ui.models.Model")
local CoachItemBaseModel = require("ui.models.coach.common.CoachItemBaseModel")
local PlayerTalentSkillBook = require("data.PlayerTalentSkillBook")
local PlayerTalentSkill = require("data.PlayerTalentSkill")

local CoachPlayerTalentSkillBookModel = class(CoachItemBaseModel, "CoachPlayerTalentSkillBookModel")

function CoachPlayerTalentSkillBookModel:ctor()
    CoachPlayerTalentSkillBookModel.super.ctor(self)
end

function CoachPlayerTalentSkillBookModel:GetStaticConfig(id)
    return PlayerTalentSkillBook[tostring(id)] or {}
end

-- 图标的主图标显示
function CoachPlayerTalentSkillBookModel:GetPicIcon()
    return self:GetIconIndex()
end

function CoachPlayerTalentSkillBookModel:GetIconIndex()
    return self.staticData.picIcon
end

-- 技能书背景
function CoachPlayerTalentSkillBookModel:GetDecoratePicIcon()
    return self.staticData.picBackGround
end

-- 特性道具初始价格
function CoachPlayerTalentSkillBookModel:GetBaseMallPrice()
    return self.staticData.baseMallPrice
end

-- 该特性书内，球员特性技能ID
function CoachPlayerTalentSkillBookModel:GetSkillId()
    return self.staticData.skillId
end

-- 替换概率（如果没随机到替换则一定为增加，百分制）
function CoachPlayerTalentSkillBookModel:GetExchangeProbability()
    return self.staticData.exchangeProbability
end

-- 获得技能数据
function CoachPlayerTalentSkillBookModel:GetSkillData()
    if self.skillData then return self.skillData end
    local skillId = self:GetSkillId()
    local skillData = PlayerTalentSkill[tostring(skillId)] or {}
    self.skillData = skillData
    return self.skillData
end

-- 获得技能描述
function CoachPlayerTalentSkillBookModel:GetDesc()
    local skillData = self:GetSkillData()
    return skillData.skillDesc
end

-- 获得技能等级
function CoachPlayerTalentSkillBookModel:GetSkillQuality()
    local skillData = self:GetSkillData()
    return skillData.quality
end

-- 获得技能适用条件
function CoachPlayerTalentSkillBookModel:GetSkillCondition()
    local skillData = self:GetSkillData()
    return skillData.conditionType
end

-- 获得技能适用类别
function CoachPlayerTalentSkillBookModel:GetSkillTalentType()
    local skillData = self:GetSkillData()
    return skillData.playerTalentType
end

return CoachPlayerTalentSkillBookModel
