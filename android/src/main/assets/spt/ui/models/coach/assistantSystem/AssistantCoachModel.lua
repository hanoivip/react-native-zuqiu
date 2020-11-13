local Model = require("ui.models.Model")
local CoachBaseLevel = require("data.CoachBaseLevel")
local AssistantCoach = require("data.AssistantCoach")
local AssistantCoachSkill = require("data.AssistantCoachSkill")
local AssistantCoachUpgrade = require("data.AssistantCoachUpgrade")
local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")
local CardHelper = require("ui.scene.cardDetail.CardHelper")

--- 助理教练的通用model，协助管理助理教练基本信息及配置数据
local AssistantCoachModel = class(Model, "AssistantCoachModel")

function AssistantCoachModel:ctor()
    self.data = nil
    self.coachMainModel = require("ui.models.coach.CoachMainModel").new()
end

function AssistantCoachModel:InitWithProtocol(assistantCoachData)
    self.data = assistantCoachData or {}
    self:ParseFromConfig(self.data)
end

-- 从配置中解析数据
function AssistantCoachModel:ParseFromConfig(acData)
    local quality = tostring(acData.ac_quality)
    local lvl = acData.ac_lvl
    -- 最大等级
    local coachLvl = self.coachMainModel:GetCoachLevel()
    acData.maxCoachLvl = CoachBaseLevel[tostring(coachLvl)].assistantCoachMaxLevel -- 教练控制的最大等级
    acData.maxLvl = AssistantCoach[quality].maxLevel
    acData.isCoachMax = lvl >= acData.maxCoachLvl
    acData.isMax = lvl >= acData.maxLvl
    -- 技能解锁
    local skills = {}
    for index, skillId in pairs(acData.ac_skills) do
        local skill = {}
        skill.id = skillId
        skill.index = tonumber(index)
        skill.unlockLvl = tonumber(AssistantCoach[quality].assistanCoachSkillUnlock[tostring(index)])
        skill.isOpen = lvl >= skill.unlockLvl
        local config = AssistantCoachSkill[tostring(skillId)]
        if config then
            skill.quailty = config.quailty or 0
            skill.name = config.name or ""
            skill.desc = config.desc or ""
            skill.skillType = config.skillType or 0
            skill.skillImproveDetail = config.skillImproveDetail or ""
            skill.skillImproveReal = config.skillImproveReal or {}
            skill.skillImproveAmount = config.skillImproveAmount or 0
            skill.picIndex = config.picIndex or ""
        end
        table.insert(skills, skill)
    end
    table.sort(skills, function(a, b)
        return a.index < b.index
    end)
    acData.skills = skills
    -- 属性值
    for k, attr in pairs(acData.ac_attrs) do
        attr.curr = attr.initial + (lvl - 1) * attr.growth
    end
    -- 属性值排序
    AssistantCoachModel.SortAttrs(acData.ac_attrs)

    -- 分解/解雇获得基础助理教练经验书数量
    acData.splitAmount = AssistantCoach[quality].splitAmount
    -- 返还升级过教练，执教经验书比例（百分比向下取整）
    acData.spiltProportion = AssistantCoach[quality].spiltProportion

    -- 升级所需经验书
    acData.updateAce = tonumber(AssistantCoachUpgrade[tostring(lvl)].ace[quality])
    return acData
end

function AssistantCoachModel:GetCacheData()
    return self.data
end

-- 获得助理教练id
function AssistantCoachModel:GetId()
    return self.data.ac_id
end

-- 获得助理教练名字
function AssistantCoachModel:GetName()
    return self.data.ac_name
end

-- 获得助理教练等级
function AssistantCoachModel:GetLvl()
    return self.data.ac_lvl
end

-- 获得最大等级
function AssistantCoachModel:GetMaxLvl()
    local max = nil
    local isCoachLimit = nil -- 最大等级是否是教练等级控制的

    if self.data.maxCoachLvl >= self.data.maxLvl then
        max = self.data.maxLvl
        isCoachLimit = false
    else
        max = self.data.maxCoachLvl
        isCoachLimit = true
    end
    return max, isCoachLimit
end

-- 是否达到助理教练满级
function AssistantCoachModel:IsMax()
    return self.data.isMax
end

-- 是否达到教练控制的满级
function AssistantCoachModel:IsCoachMax()
    return self.data.isCoachMax
end

-- 获得助理教练头像
function AssistantCoachModel:GetIcon()
    return self.data.ac_headid
end

-- 获得助理教练头像背景
function AssistantCoachModel:GetIconBg()
    return self.data.ac_backid
end

-- 获得升级所需的ACE
function AssistantCoachModel:GetUpdateAce()
    return self.data.updateAce
end

-- 获得助理教练星级/品质
function AssistantCoachModel:GetQuality()
    return self.data.ac_quality
end

-- 获得助理教练品质最大的数
function AssistantCoachModel:GetMaxQuality()
    return AssistantCoachConstants.MaxQuality
end

-- 获得助理教练属性array
function AssistantCoachModel:GetAttrs()
    return self.data.ac_attrs
end

-- 获得助理教练属性的数目
function AssistantCoachModel:GetAttrNum()
    return #self.data.ac_attrs
end

-- 获得助理教练属性最大的数目
function AssistantCoachModel:GetMaxAttrNum()
    return AssistantCoachConstants.MaxAttrNum
end

-- 获得助理教练技能array
function AssistantCoachModel:GetSkills()
    return self.data.skills
end

-- 升级
function AssistantCoachModel:Upgrade(data)
    self.data.ac_lvl = tonumber(data.level)
    self:ParseFromConfig(self.data)
end

-- 是否是上阵的助理教练
function AssistantCoachModel:IsInTeam()
    return tobool(tonumber(self:GetTeamIdx()) > 0)
end

-- 获取上阵的团队id
-- 0或nil表示未上阵
function AssistantCoachModel:GetTeamIdx()
    return self.data.ac_teamIdx or 0
end

function AssistantCoachModel:SetTeamIdx(teamIdx)
    self.data.ac_teamIdx = tonumber(teamIdx)
end

-- 针对某个助理教练的属性排序
function AssistantCoachModel.SortAttrs(attrs)
    local attrOrder = {}
    for k, v in ipairs(CardHelper.NormalPlayerOrder) do
        attrOrder[v] = k
    end
    for k, v in ipairs(CardHelper.GoalKeeperOrder) do
        attrOrder[v] = k * 10
    end
    table.sort(attrs, function(a, b)
        return attrOrder[a.type] < attrOrder[b.type]
    end)
end

local Eps = 1e-6
-- 获得分解时返还的助理教练经验书数量
function AssistantCoachModel:GetSplitReturnNum()
    -- 已使用的经验书数量
    local totalNum = 0
    local quality = tostring(self:GetQuality())
    for i = 1, self:GetLvl() - 1 do
        totalNum = totalNum + tonumber(AssistantCoachUpgrade[tostring(i)].ace[quality])
    end

    local base = AssistantCoach[quality].splitAmount
    local percent = AssistantCoach[quality].spiltProportion

    return tonumber(base) + math.floor(totalNum * percent / 100 + Eps)
end

return AssistantCoachModel
