local Card = require("data.Card")
local Paster = require("data.Paster")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local PasterSortPriority = require("ui.scene.paster.PasterSortPriority")
local PasterUpgradeQualityType = require("ui.scene.pasterUpgrade.PasterUpgradeQualityType")
local Model = require("ui.models.Model")
local Skills = require("data.Skills")

local CardPasterModel = class(Model, "CardPasterModel")

function CardPasterModel:ctor(ptid, pasterState)
    CardPasterModel.super.ctor(self)
    self.ptid = ptid
    self.pasterState = pasterState or PasterStateType.Default
    self.cacheData = {}
end

function CardPasterModel:InitWithCache(cache)
    self.cacheData = cache
    self.ptid = self.cacheData.ptid
    self:InitWithStatic(self.cacheData.ptcid)
end

function CardPasterModel:InitWithStatic(ptcid)
    self.ptcid = ptcid
    assert(tostring(self.ptcid) and Paster[tostring(self.ptcid)], "ptcid(" .. tostring(self.ptcid) .. ") not in Paster table")
    self.pasterData = Paster[tostring(self.ptcid)]
    if self:GetPasterUsedByAll() or self:IsPasterUsedByPosition() then 
        self.staticData = {}
        self.staticData.pictureID = "Default"
        self.staticData.name = ""
    else
        self.useCardID = self:GetPasterCardDefault()
        self.staticData = Card[tostring(self.useCardID)] or {}
    end
end

function CardPasterModel:GetId()
    return tostring(self.ptid)
end

function CardPasterModel:GetPasterId()
    return tostring(self.ptcid)
end

function CardPasterModel:GetPasterState()
    return self.pasterState
end

function CardPasterModel:GetNum()
    return self.cacheData.num or 1
end

function CardPasterModel:GetPasterQuality()
    return self.pasterData.quality
end

function CardPasterModel:IsPlusCard()
    local qualitySpecial = self.staticData.qualitySpecial or 0
    return tobool(qualitySpecial == 1)
end

function CardPasterModel:GetPasterQualitySpecial()
    return self.staticData.qualitySpecial or 0
end

function CardPasterModel:GetAvatar()
    return self.staticData.pictureID
end

function CardPasterModel:GetNameByEnglish()
    return self.staticData.name
end

-- 1周 2月 3荣耀 4争霸赛贴纸 5周年纪念
function CardPasterModel:GetPasterType()
    return tonumber(self.pasterData.type)
end

function CardPasterModel:IsWeekPaster()
    local pasterType = self:GetPasterType()
    return tobool(tonumber(pasterType) == PasterMainType.Week)
end

function CardPasterModel:IsMonthPaster()
    local pasterType = self:GetPasterType()
    return tobool(tonumber(pasterType) == PasterMainType.Month)
end

function CardPasterModel:IsHonorPaster()
    local pasterType = self:GetPasterType()
    return tobool(tonumber(pasterType) == PasterMainType.Honor)
end

function CardPasterModel:IsAnnualPaster()
    local pasterType = self:GetPasterType()
    return tobool(tonumber(pasterType) == PasterMainType.Annual)
end

function CardPasterModel:IsCompetePaster()
    local pasterType = self:GetPasterType()
    return tobool(tonumber(pasterType) == PasterMainType.Compete)
end

function CardPasterModel:GetPasterSortPriority()
    return PasterSortPriority[self:GetPasterType()]
end

function CardPasterModel:GetHonorSkillLevelEx()
    return self.pasterData.skillLv
end

function CardPasterModel:GetAnnualSkillLevelEx()
    return self.pasterData.skillLv
end

function CardPasterModel:GetCompeteSkillLevelEx()
    return self.pasterData.skillLv
end

function CardPasterModel:GetCompeteSkillName()
    local sid = self:GetCompetePasterSkill()
    local skillName = ""
    if Skills[tostring(sid)] then
        skillName = Skills[tostring(sid)].skillName
    end
    return skillName
end

function CardPasterModel:GetName()
    return self.pasterData.name
end

function CardPasterModel:GetProfile()
    return self.pasterData.desc
end

function CardPasterModel:GetUseText()
    return self.pasterData.desc2
end

function CardPasterModel:GetPasterSkill()
    return self.pasterData.skill
end

function CardPasterModel:GetCompetePasterSkill()
    return self.pasterData.skillImprove
end

function CardPasterModel:GetPasterSkillLvl()
    return self.cacheData.skillLv or 1
end

function CardPasterModel:GetCompetePasterSkillLvl()
    return self.cacheData.skillLv or 1
end

function CardPasterModel:GetPasterUsedByCard()
    return self.pasterData.cardID or {}
end      

function CardPasterModel:GetPasterUsedByAll()
    return tobool(tonumber(self.pasterData.all) == 1)
end    

-- 是否为同位置球员可用贴纸
function CardPasterModel:IsPasterUsedByPosition()
    return tobool(tonumber(self.pasterData.all) == 2)
end

-- 获取贴纸可用位置
function CardPasterModel:GetPasterUsedByPosition()
    return self.pasterData.position or {}
end

function CardPasterModel:GetPasterSkillExLvl()
    return self.cacheData.plvl or 0
end

function CardPasterModel:GetHerohallSkillExLvl()
    return self.cacheData.hlvl or 0
end

function CardPasterModel:GetComposePieceNeed()
    return self.pasterData.combinePieces or 0
end

function CardPasterModel:GetSplitPieceNeed()
    return self.pasterData.splitPieces or 0
end

function CardPasterModel:GetPasterCardDefault()
    local cardID = self:GetPasterUsedByCard() or {}
    return cardID[1]
end

function CardPasterModel:GetIsPasterPokedex()
    return false
end

-- 是否需要显示在图鉴
function CardPasterModel:GetPasterHandbook()
    if self.pasterData.pasterHandbook == 0 then
        return false
    else
        return true
    end
end

-- 是否可拆分， 0不可，1可以
function CardPasterModel:GetPasterSplitType()
    return self.pasterData.splitType or 0
end

function CardPasterModel:CanPasterSplit()
    return self:GetPasterSplitType() == 1
end

function CardPasterModel:GetNameByChinese()
    return self.staticData.name2 or ""
end

function CardPasterModel:GetNationByEnglish()
    return self.staticData.nationIcon or ""
end

function CardPasterModel:GetNationByChinese()
    return self.staticData.nation or ""
end

function CardPasterModel:CanPasterUpgrade()
    local isCompetePaster = self:IsCompetePaster()
    local quality = self:GetPasterQuality()
    local isNotMaxQuality = PasterUpgradeQualityType.MAX_QUALITY > quality
    local pasterState = self:GetPasterState()
    local isCanUpgrade = (pasterState == PasterStateType.CanUse) or (pasterState == PasterStateType.Unload)
    return isCompetePaster and isNotMaxQuality and isCanUpgrade
end

function CardPasterModel:GetPieceBg(quality)
    return "Universal_Quality"
end

function CardPasterModel:GetLevelEx()
    return 0
end

return CardPasterModel
