local PlayerTalentSkill = require("data.PlayerTalentSkill")
local CoachItemType = require("ui.models.coach.common.CoachItemType")
local FeatureSKillState = require("ui.scene.cardDetail.feature.FeatureSKillState")
local Model = require("ui.models.Model")
local CardFeatureModel = class(Model, "CardFeatureModel")

function CardFeatureModel:ctor(sid, slot, effectAmount)
    self.sid = sid
    self.slot = slot
    self.effectAmount = effectAmount
    self.cacheData = {}
    self.staticData = {}
    self.featureOpen = true -- 默认特性为开启
    self.featureStatu = CoachItemType.SkillFuncType.Normal
    self.featureSKillState = FeatureSKillState.Lock
    self:InitWithStatic(sid)
end

function CardFeatureModel:InitWithCache(cache)
    self.cacheData = cache or {}
    self.featureOpen = self.cacheData.open
    self.sid = self.cacheData.sid
    self:InitFeatureSKillState()
end

function CardFeatureModel:InitFeatureSKillState()
    if self.featureOpen then
        self.featureSKillState = FeatureSKillState.Enable
        return
    end
    if self.sid then
        self.featureSKillState = FeatureSKillState.Disable
        return
    end
    if self.effectAmount < tonumber(self.slot) then
        self.featureSKillState = FeatureSKillState.Lock
    else
        self.featureSKillState = FeatureSKillState.Empty
    end
end

function CardFeatureModel:SetFeatureSKillState(featureSKillState)
    self.featureSKillState = featureSKillState
end

function CardFeatureModel:InitWithStatic(sid)
    self.staticData = PlayerTalentSkill[tostring(sid)] or {}
end

function CardFeatureModel:GetPicIcon()
    return self.staticData.picIcon
end

function CardFeatureModel:GetId()
    return self.sid
end

-- 技能书背景
function CardFeatureModel:GetDecoratePicIcon()
    return self.staticData.picBackGround
end

-- 入门品质
function CardFeatureModel:GetQualitySign()
    return self.staticData.qualityPicIndex
end

-- 获得品质
function CardFeatureModel:GetQuality()
    return self.staticData.qualityPicIndex
end

-- 获得名字
function CardFeatureModel:GetName()
    return self.staticData.skillName
end

-- 技能标签 特性品质客户端的文字显示(1为稀有2为罕见3为珍稀4为传奇)
function CardFeatureModel:GetTag()
    return self.staticData.skillTag
end

function CardFeatureModel:IsOpen()
    return self.featureOpen
end

--(1为稀有2为罕见3为珍稀4为传奇)
function CardFeatureModel:GetTagText()
    local tag = self:GetTag()
    if tag and tag ~= "" then
        return lang.trans("coach_feature_skill" .. tag) 
    end
    return ""
end

-- 技能品质评级
function CardFeatureModel:GetSkillQuality()
    return self.staticData.skillQuailtyName
end

-- 获得技能描述
function CardFeatureModel:GetDesc()
    return self.staticData.skillDesc
end

function CardFeatureModel:GetCoachItemType()
    return CoachItemType.PlayerTalentSkillBook
end

function CardFeatureModel:ChangeFuncStateByNormal()
    self.featureStatu = CoachItemType.SkillFuncType.Normal
end

function CardFeatureModel:ChangeFuncState(skillFuncType)
    self.featureStatu = skillFuncType
end

function CardFeatureModel:GetStatu()
    return self.featureStatu
end

function CardFeatureModel:GetFeatureSKillState()
    return self.featureSKillState
end

return CardFeatureModel
