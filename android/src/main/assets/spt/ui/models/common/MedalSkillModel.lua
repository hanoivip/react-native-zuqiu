local EventSystem = require ("EventSystem")
local Skills = require("data.Skills")
local SkillItemModel = require("ui.models.common.SkillItemModel")
local MedalSkillModel = class(SkillItemModel, "MedalSkillModel")

function MedalSkillModel:ctor()
    MedalSkillModel.super.ctor(self)
end

-- 根据球员的技能数据初始化，包含了球员技能数据
function MedalSkillModel:InitWithCache(cache)
    assert(cache)
    self.sid = cache.sid
    self.cacheData = cache
    self.staticData = Skills[tostring(self.sid)]
end

-- 根据技能ID初始化，表示静态数据
function MedalSkillModel:InitByID(sid)
    self.sid = sid
    self.staticData = Skills[tostring(self.sid)]
end

function MedalSkillModel:GetName()
    return self.staticData.skillName
end

-- 技能描述
function MedalSkillModel:GetDesc()
    return self.staticData.desc
end

function MedalSkillModel:GetLevel()
    return self.cacheData and tonumber(self.cacheData.lvl) or 0
end

function MedalSkillModel:GetSkillID()
    return self.sid
end

-- 祝福技能放置在技能中
function MedalSkillModel:IsMedalSkill()
    return tobool(tonumber(self.staticData.isMedalSkill) == 1)
end

-- 获取技能的图片索引
function MedalSkillModel:GetIconIndex()
    return self.staticData.picIndex
end

-- 获取当前等级时的技能效果加成
function MedalSkillModel:GetEffectPlus(level)
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

return MedalSkillModel
