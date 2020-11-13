local PasterStateType = require("ui.scene.paster.PasterStateType")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")

local CardAppendPasterModel = class(CardPasterModel, "CardAppendPasterModel")

function CardAppendPasterModel:ctor(ptid)
    CardAppendPasterModel.super.ctor(self, ptid, PasterStateType.Unload)
    self.coachSkillLvl = 0  -- 教练增加技能等级
    self.legendRoadSkilllvl = 0 -- 传奇之路增加等级
    self.homeCourtSkilllvl = 0 -- 主场增加技能
end

function CardAppendPasterModel:InitWithCache(cache, pasterSkillData, isPokedex)
    self.pasterSkillData = pasterSkillData
    self.skillValid = pasterSkillData.skillValid
    self.isPokedex = isPokedex
    self.pcid = cache.pcid
    self.isHave = cache.isHave
    CardAppendPasterModel.super.InitWithCache(self, cache)
end

function CardAppendPasterModel:SetCoachMainModel(coachMainModel)
    self.coachSkillLvl = coachMainModel ~= nil and coachMainModel:GetCoachSkillLvl(self.pasterSkillData) or 0
end

-- 传奇之路技能
function CardAppendPasterModel:SetLegendRoadLvl(legendRoadSkilllvl)
    self.legendRoadSkilllvl = legendRoadSkilllvl or 0
end

-- 主场技能
function CardAppendPasterModel:SetHomeCourtLvl(homeCourtSkilllvl)
    self.homeCourtSkilllvl = homeCourtSkilllvl or 0
end

-- 梦幻11人技能
function CardAppendPasterModel:SetFancyLvl(fancySkillLvl)
    self.fancySkillLvl = fancySkillLvl or 0
end

-- 球员助力贴纸
function CardAppendPasterModel:SetSupportLvl(supportSkillLvl)
    self.supportSkillLvl = supportSkillLvl or 0
end

function CardAppendPasterModel:GetPcid()
    return self.pcid
end

function CardAppendPasterModel:GetPasterSkillData()
    return self.pasterSkillData
end

-- 贴纸现在可以拥有传奇之路改变的ex贴纸
function CardAppendPasterModel:GetPasterSkill()
    local sid = self.pasterSkillData.exSid or self.pasterSkillData.sid or self.pasterData.skill
    return sid
end

-- 1 标识启用
-- 用此字段能区分装备的月帖中相同技能里生效的技能
-- 月贴的技能只能生效一个，周贴技能可以叠加，
function CardAppendPasterModel:GetSkillValid()
    return self.pasterSkillData.skillValid or 0
end

function CardAppendPasterModel:GetPasterSkillLvl()
    return self.pasterSkillData.lvl or 1
end

function CardAppendPasterModel:GetCompetePasterSkillLvl()
    return self.pasterSkillData.lvl or 1
end

function CardAppendPasterModel:GetPasterSkillExLvl()
    return self.pasterSkillData.plvl or 0
end

function CardAppendPasterModel:GetMedalSkillExLvl()
    return self.pasterSkillData.mlvl or 0
end

function CardAppendPasterModel:GetHerohallSkillExLvl()
    return self.pasterSkillData.hlvl or 0
end

-- 月贴获得技能是否与球员自身技能冲突标识
-- 为1，表示此技能冲突不生效
-- nil或0标识未产生冲突
function CardAppendPasterModel:GetSkillConflict()
    return self.pasterSkillData.skillConflict or 0
end

function CardAppendPasterModel:IsSkillConflict()
    return self:GetSkillConflict() == 1
end

function CardAppendPasterModel:GetCoachSkillExLvl()
    return self.coachSkillLvl or 0
end

function CardAppendPasterModel:GetLegendRoadLvl()
    return self.legendRoadSkilllvl or 0
end

function CardAppendPasterModel:GetHomeCourtLvl()
    return self.homeCourtSkilllvl or 0
end

function CardAppendPasterModel:GetFancyLvl()
    return self.fancySkillLvl or 0
end

function CardAppendPasterModel:GetSupportLvl()
    return self.supportSkillLvl or 0
end

function CardAppendPasterModel:GetLevelEx()
    local lvlEx = self:GetPasterSkillExLvl() + self:GetMedalSkillExLvl() + self:GetHerohallSkillExLvl()
            + self:GetCoachSkillExLvl() + self:GetLegendRoadLvl() + self:GetHomeCourtLvl()
            + self:GetFancyLvl() + self:GetSupportLvl()
    return lvlEx
end

function CardAppendPasterModel:GetIsPasterPokedex()
    return not not self.isPokedex
end

function CardAppendPasterModel:GetIsHave()
    return not not self.isHave
end

return CardAppendPasterModel
