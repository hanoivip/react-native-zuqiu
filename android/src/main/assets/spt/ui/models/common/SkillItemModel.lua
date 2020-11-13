local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local Skills = require("data.Skills")
local Upgrade = require("data.Upgrade")
local CardQuality = require("data.CardQuality")
local PasterMainType = require("ui.scene.paster.PasterMainType")
local SkillType = require("ui.common.enum.SkillType")
local SkillConstants = require("ui.common.SkillConstants")

local SkillItemModel = class(Model, "SkillItemModel")

function SkillItemModel:ctor()
    SkillItemModel.super.ctor(self)
    self.coachSkillLvl = 0 -- 教练增加技能等级
    self.legendRoadSkilllvl = 0 -- 传奇之路增加等级
    self.homeCourtSkilllvl = 0 -- 主场增加技能
end

-- 根据球员的技能数据初始化，包含了球员技能数据
function SkillItemModel:InitWithCache(cache, slot)
    assert(cache)
    self.slot = slot
    self.sid = cache.sid
    -- 特训技能，如果有，优先显示这个技能
    self.exSid = cache.exSid
    self.cacheData = cache
    self.staticData = Skills[self.exSid or tostring(self.sid)] or {}
end

function SkillItemModel:SetCoachMainModel(coachMainModel)
    self.coachSkillLvl = coachMainModel ~= nil and coachMainModel:GetCoachSkillLvl(self.cacheData) or 0
end

-- 传奇之路技能
function SkillItemModel:SetLegendRoadLvl(legendRoadSkilllvl)
    self.legendRoadSkilllvl = legendRoadSkilllvl or 0
end

-- 主场技能
function SkillItemModel:SetHomeCourtLvl(homeCourtSkilllvl)
    self.homeCourtSkilllvl = homeCourtSkilllvl or 0
end

-- 梦幻11人技能
function SkillItemModel:SetFancyLvl(fancySkillLvl)
    self.fancySkillLvl = fancySkillLvl or 0
end

-- 球员助力贴纸
function SkillItemModel:SetSupportLvl(supportSkillLvl)
    self.supportSkillLvl = supportSkillLvl or 0
end

-- 服务器slot从0开始(客户端从1开始)
function SkillItemModel:GetSlot()
    return self.slot
end

-- 根据技能ID初始化，表示静态数据
function SkillItemModel:InitByID(sid)
    self.sid = sid
    self.staticData = Skills[tostring(self.sid)] or {}
end

function SkillItemModel:GetName()
    return self.staticData.skillName
end

function SkillItemModel:IsPasterSkill()
    return tobool(self.cacheData.ptid)
end

function SkillItemModel:GetPasterSkillType()
    return self.cacheData.pType
end

function SkillItemModel:GetPasterSkillExLvl()
    return self.cacheData.plvl or 0
end

function SkillItemModel:GetMedalSkillExLvl()
    return self.cacheData.mlvl or 0
end

function SkillItemModel:GetTrainingSkillExLvl()
    return self.cacheData.tlvl or 0
end

function SkillItemModel:GetHerohallSkillExLvl()
    return self.cacheData.hlvl or 0
end

-- 教练增加的技能等级
function SkillItemModel:GetCoachSkillExLvl()
    return self.coachSkillLvl or 0
end

-- 传奇之路增加的技能等级
function SkillItemModel:GetLegendRoadSkilllvl()
    return self.legendRoadSkilllvl or 0
end

-- 主场（特性）增加的技能等级
function SkillItemModel:GetHomeCourtLvl()
    return self.homeCourtSkilllvl or 0
end

-- 梦幻11人增加的技能等级
function SkillItemModel:GetFancyLvl()
    return self.fancySkillLvl or 0
end

-- 球员助力贴纸增加的技能等级
function SkillItemModel:GetSupportLvl()
    return self.supportSkillLvl or 0
end

-- 技能描述
function SkillItemModel:GetDesc()
    return self.staticData.desc
end

-- 事件类技能的额外描述
function SkillItemModel:GetDesc2()
    return self.staticData.desc2
end

function SkillItemModel:GetDesc3()
    return self.staticData.desc3
end

function SkillItemModel:GetDesc4()
    return self.staticData.desc4
end

function SkillItemModel:GetSkillSupporterPercent()
    return self.staticData.supporterPercent or 0
end

function SkillItemModel:IsPasterByMonthAndWeek()
    local pType = self:GetPasterSkillType()
	return tobool(pType == PasterMainType.Week) or tobool(pType == PasterMainType.Month) or false
end

function SkillItemModel:GetMatchsid()
    local match = self.staticData.desc3
    if not match or match == "" then 
        return nil
    else 
        return string.split(match, "#")
    end
end

function SkillItemModel:GetMatchName()
    local match = self.staticData.desc3
    if not match or match == "" then 
        return nil
    else 
        local list = string.split(match, "#")
        local matchName = {}
        for i,v in ipairs(list) do
            table.insert(matchName, Skills[tostring(v)].skillName)
        end
        return matchName
    end
end

function SkillItemModel:GetRestrainedName()
    local restrain = self.staticData.desc4
    if not restrain or restrain == "" then 
        return nil
    else 
        local list = string.split(restrain, "#")
        local restrainedName = {}
        for i,v in ipairs(list) do
            table.insert(restrainedName, Skills[tostring(v)].skillName)
        end
        return restrainedName
    end
end

function SkillItemModel:GetPosition()
    local position = self.staticData.desc5
    if not position or position == "" then 
        return nil
    else 
        return string.split(position, "#")
    end
end

function SkillItemModel:IsOpen()
    return self.cacheData and tobool(self.cacheData.isOpen) or false
end

function SkillItemModel:GetLevel()
    if self:IsOpen() then
        local lvl = self.cacheData and tonumber(self.cacheData.lvl)
        local levelMax = SkillConstants.MaxLevel
        return math.clamp(lvl, 0, levelMax)
    else
        return 0
    end
end

function SkillItemModel:GetAdditionLevel()
	local lvl = self.cacheData and tonumber(self.cacheData.lvl) or 0
	return lvl
end

function SkillItemModel:GetLevelEx()
    local lvlEx = tonumber(self.cacheData.plvl) + tonumber(self.cacheData.mlvl) + tonumber(self.cacheData.tlvl)
            + tonumber(self.cacheData.hlvl) + tonumber(self:GetCoachSkillExLvl())
            + tonumber(self:GetLegendRoadSkilllvl())+ tonumber(self:GetHomeCourtLvl())
            + tonumber(self:GetFancyLvl()) + tonumber(self:GetSupportLvl())
    return lvlEx
end

function SkillItemModel:GetSkillID()
    return self.sid
end

function SkillItemModel:GetSkillTotalLevel()
    local level = self:GetLevel()
    local levelEx = self:GetLevelEx()
    local levelMax = SkillConstants.MaxLevel
    return math.clamp(level + levelEx, 0, levelMax)
end

function SkillItemModel:GetSkillMaxLevel()
    if self:IsOpen() then
        return self.cacheData and tonumber(self.cacheData.skillMaxLvl) or 1
    else
        return 1
    end
end

-- 获取技能的图片索引
function SkillItemModel:GetIconIndex()
    return self.staticData.picIndex
end

-- 获取当前等级时的技能效果加成
function SkillItemModel:GetEffectPlus(level)
    local levelMax = SkillConstants.MaxLevel
    local level =  math.clamp(level, 0, levelMax)

    local baseLevelTable = self.staticData["lvlBase"]
    if baseLevelTable then -- 技能表优化
        local totalLevelTable = {}
        local lvlImprove = self.staticData["lvlImprove"] or {}
        for k, value in pairs(baseLevelTable) do
            totalLevelTable[k] = tonumber(value)
            local improveValue = lvlImprove[k] 
            if improveValue then 
                totalLevelTable[k] = totalLevelTable[k] + improveValue * (level - 1)
            end
        end
        return totalLevelTable
    else
        return self.staticData["lvl" .. tostring(level)]
    end
end

-- 是否是数值类技能
function SkillItemModel:IsAttributeSkill()
    return self.staticData.type == SkillType.ATTRIBUTE
end

-- 是否事件类技能
function SkillItemModel:IsEventSkill()
    return self.staticData.type == SkillType.EVENT
end

-- 是否是缘分类技能
function SkillItemModel:IsChemicalSkill()
    return self.staticData.type == SkillType.CHEMICAL
end

-- 是否是特训完技能
function SkillItemModel:IsTrainingSkill()
    return self.staticData.type == SkillType.TRAINING
end

function SkillItemModel:IsExEventSkill()
    return tonumber(self.staticData.skillType) == 1
end

function SkillItemModel:GetSkillType()
    return tonumber(self.staticData.skillType)
end

function SkillItemModel:IsChemicalType()
    local skillType = self:GetSkillType()
    return skillType == SkillType.CHEMICAL
end

function SkillItemModel:IsAttributeType()
    local skillType = self:GetSkillType()
    return skillType == SkillType.ATTRIBUTE
end

-- 缘分类技能的球员ID和配缘人的ID
function SkillItemModel:GetChemicalSkillCoupleID()
    if not self:IsChemicalSkill() then return nil end

    return self.staticData.cardID, self.staticData.cardID2
end

function SkillItemModel:GetTrainingChemicalSkillCoupleID()
    local skillTable = Skills[tostring(self.sid)]
    return skillTable.cardID, skillTable.cardID2
end

-- 是否达到当前进阶级数的最大技能等级
function SkillItemModel:IsUpToCurrentUpgradeMaxLevel()
    return self:GetLevel() >= self:GetSkillMaxLevel()
end

-- 技能等级是否达到了最大进阶级数的上限
function SkillItemModel:IsUpToMaxUpgradeMaxLevel(cardModel)
    return self:GetLevel() >= cardModel:GetDefaultUpgardeSkillLevel() and self:GetLevel() >= cardModel:GetMaxSkillLevel(cardModel:GetAscend())
end

-- 技能已达最大上限
function SkillItemModel:IsUpToMaxLevel30(cardModel)
    return self:GetLevel() >= cardModel:GetDefaultMaxSkillLevel()
end

-- 技能开启所需进阶数
function SkillItemModel:GetSkillOpenToNeedUpgrade()
    local needUpgrade = 1
    local sortUpgrade = {}
    for upgrade, v in pairs(Upgrade) do
        sortData = clone(v)
        sortData.upgrade = tonumber(upgrade)
        table.insert(sortUpgrade, sortData)
    end
    table.sort(sortUpgrade, function(a, b) return a.upgrade < b.upgrade end)
    for i, v in ipairs(sortUpgrade) do
        if tonumber(v.skillUnlock) == self.slot then 
            needUpgrade = v.upgrade
            break
        end
    end
    return needUpgrade
end

function SkillItemModel:IsActive()
    return tonumber(self.staticData.Activity) > 0
end

function SkillItemModel:GetChemicalSkillDesc()
    local cid = self.staticData.cardID2
    local playerCardModel = require("ui.models.cardDetail.StaticCardModel").new(cid)
    local name = playerCardModel:GetName()
    local quality = playerCardModel:GetCardQuality()
    local color_str, quality_str, color
    for i, v in ipairs(require("ui.controllers.cardIndex.QualityType").QualityDescMap) do
        if v.Quality == quality then
            quality_str = lang.transstr(v.Desc)
        end
    end
    color = CardQuality[tostring(quality)].color
    color_str = "<color=" .. color .. ">" .. quality_str .. "【" .. name .. "】" .. "</color>" 
    return lang.transstr("Chemical_Skill_Desc", color_str)
end

return SkillItemModel
