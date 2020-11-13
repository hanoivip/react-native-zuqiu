local CoachBaseLevel = require("data.CoachBaseLevel")
local CoachBaseTactics = require("data.CoachBaseTactics")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CoachTalent = require("data.CoachTalent")
local AssistantCoachModel = require("ui.models.coach.assistantSystem.AssistantCoachModel")
local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")

local Model = require("ui.models.Model")

local CoachMainModel = class(Model, "CoachMainModel")

-- 每一级的星星个数
local STAR_MAX_LEVEL = 5
local EFFECT_TALENT_TYPE = {
    ["FIXED"] = 1,
    ["RATE"] = 2,
}

-- 场上的26个位置对应 CoachTalent.positionEffectTalentType
--  1：前锋 2：中场 3：后卫 4：门将
local PositionToNumber = {
    ["1"] = "1",
    ["2"] = "1",
    ["3"] = "1",
    ["4"] = "1",
    ["5"] = "1",
    ["6"] = "1",
    ["7"] = "2",
    ["8"] = "2",
    ["9"] = "2",
    ["10"] = "1",
    ["11"] = "2",
    ["12"] = "2",
    ["13"] = "2",
    ["14"] = "2",
    ["15"] = "2",
    ["16"] = "3",
    ["17"] = "2",
    ["18"] = "2",
    ["19"] = "2",
    ["20"] = "3",
    ["21"] = "3",
    ["22"] = "3",
    ["23"] = "3",
    ["24"] = "3",
    ["25"] = "3",
    ["26"] = "4",
}

-- 全技能等级增加的key
local KEY_ALL_SKILL = "all_skill"

function CoachMainModel:ctor(playerCardModel, teamsModel)
    CoachMainModel.super.ctor(self)
    self.playerCardModel = playerCardModel
    self:SetTeamModel(teamsModel)
end

function CoachMainModel:Init(data)
    if not data then
        data = cache.getCoachInfo()
    end
    self.cacheData = data or {}
end

function CoachMainModel:InitWithProtocol(cacheData, isCacheMission)
    cache.setCoachInfo(cacheData)
    self.cacheData = cacheData or {}
    self:CacheCoachAttrs()
    if isCacheMission then
        self:CacheCoachMissionData()
    end
end

function CoachMainModel:CacheCoachAttrs()
    self:CacheFormationData()
    self:CacheTacticData()
    self:CacheTalentData()
    self:CacheCoachGuidePlayers()
    self:CacheAssistantPower() -- 缓存助理教练属性数据及技能等级加成
end

function CoachMainModel:GetData()
    return self.cacheData
end

function CoachMainModel:GetCoachStarMaxLevel()
    return STAR_MAX_LEVEL
end

-- 教练的等级
function CoachMainModel:GetCredentialLevel()
    local lvl = self:GetCoachLevel()
    return CoachBaseLevel[lvl].coachCredentialLevel
end

-- 教练的星级
function CoachMainModel:GetStarLevel()
    local lvl = self:GetCoachLevel()
    return CoachBaseLevel[lvl].coachLevel
end

-- 获取总等级
function CoachMainModel:GetCoachLevel()
    return tostring(self.cacheData.lvl or "1")
end

-- 设置总等级
function CoachMainModel:SetCoachLevel(lvl)
    self.cacheData.lvl = tostring(lvl)
end

-- 获取教练当前经验
function CoachMainModel:GetCoachExp()
    return self.cacheData.exp or 0
end

-- 设置教练当前经验
function CoachMainModel:SetCoachExp(exp)
    self.cacheData.exp = exp
end

-- 阵型升级的信息
function CoachMainModel:GetFormationInfo()
    return self.cacheData.formation or {}
end

-- 战术升级的信息
function CoachMainModel:GetTacticsInfo()
    return self.cacheData.tactics or {}
end

-- 天赋升级的信息
function CoachMainModel:GetTalentInfo()
    return self.cacheData.talent or {}
end

-- 阵型升级带来的全属性加成
function CoachMainModel:GetFormationAttrByFormationId(formationId)
    formationId = tostring(formationId)
    local formationAttrs = cache.getCoachFormationAttrs()
    return formationAttrs[formationId] or 0
end

-- 战术升级带来的全属性加成
function CoachMainModel:GetTacticAttr(teamsModel)
    local nowTactic = teamsModel:GetNowTeamTacticsData()
    local cacheTacticAttr = cache.getCoachTacticAttr()
    local attrValue = 0
    for tacticName, levelTable in pairs(cacheTacticAttr) do
        local currLevel = tostring(nowTactic[tacticName])
        local coachTacticValue = levelTable[currLevel] or 0
        attrValue = attrValue + coachTacticValue
    end
    return attrValue
end

-- 天赋升级时更新
function CoachMainModel:RefreshTalentData(data)
    self.cacheData = data
    self:CacheTalentData()
end

-- 战术升级时更新
function CoachMainModel:RefreshTacticData(data)
    self.cacheData = data
    self:CacheTacticData()
end

-- 阵型升级时更新
function CoachMainModel:RefreshFormationData(data)
    self.cacheData = data
    self:CacheFormationData()
end

-- 天赋升级时缓存属性信息更新
function CoachMainModel:CacheTalentData()
    local tallentInfo = self:GetTalentInfo()
    local talentRateMap = {}
    for k,v in pairs(tallentInfo) do
        local tallentId = tostring(k)
        local tellentLevel = tonumber(v)
        if tellentLevel > 0 then
            tellentLevel = tellentLevel - 1
        end
        local tallentData = CoachTalent[tallentId]
        local valueByLevel = tallentData.effectTalent1 + tallentData.effectTalentLevelUp * tellentLevel
        talentRateMap[tallentId] = valueByLevel
    end
    cache.setCoachTalentRateMap(talentRateMap)
end

-- 阵型升级时缓存属性信息更新
function CoachMainModel:CacheFormationData()
    local formationAttrs = {}
    local formationInfo = self:GetFormationInfo()
    for formationId, formationLvl in pairs(formationInfo) do
        local id = tostring(formationId)
        formationAttrs[id] = CoachBaseTactics[tostring(formationLvl)].propertyImprove
    end
    cache.setCoachFormationAttrs(formationAttrs)
end

-- 战术升级时缓存属性信息更新
function CoachMainModel:CacheTacticData()
    local tacticAttr = {}
    local tcticsInfo = self:GetTacticsInfo()
    for tacticName, tacticType in pairs(tcticsInfo) do
        tacticAttr[tacticName] = {}
        for key, tacticLevel in pairs(tacticType) do
            tacticAttr[tacticName][key] = CoachBaseTactics[tostring(tacticLevel)].propertyImprove
        end
    end
    cache.setCoachTacticAttr(tacticAttr)
end

-- 教练的属性加成
function CoachMainModel:GetCoachAttr()
    local attr = {}
    local teamsModel = self:GetTeamsModel()
    if not teamsModel then
        return attr
    end

    local pcid = self.playerCardModel:GetPcid()
    local posInTeam = teamsModel:GetPlayerInInitTeamPos(pcid)
    if posInTeam then
        local teamType = teamsModel:GetTeamType()
        local nowTeamId = teamsModel:GetNowTeamId()
        local formationId = teamsModel:GetFormationId(nowTeamId)
        local attrList = self.playerCardModel:GetAttrNameList()
        local quality = self.playerCardModel:GetCardQuality()
        local qualitySpecial = self.playerCardModel:GetCardQualitySpecial()
        local cardFixQuality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)

        -- 阵型
        local formationAttr = self:GetFormationAttrByFormationId(formationId)

        -- 战术
        local tacticAttr = self:GetTacticAttr(teamsModel)

        -- 天赋固定加成 和 百分比加成
        local tallentFixed = {}
        local tallentRate = {}
        local tallentInfo = self:GetTalentInfo()
        local talentRateMap = cache.getCoachTalentRateMap()

        -- 助理教练属性加成，包括助教自身带来的属性加成和技能type=2带来的属性加成
        local assistantAttr = self:GetAssistantAttr()

        -- 在一个循环内把属性固定加成和百分比加成计算出来
        for k,v in pairs(tallentInfo) do
            local tallentId = tostring(k)
            local tellentLevel = tonumber(v)
            local tallentData = CoachTalent[tallentId]
            if self:CheckTallenPosition(posInTeam, tallentData.positionEffectTalentType) and
                self:CheckTallenQuality(cardFixQuality, tallentData.qualityEffectTalentTypeDetail) and
                self:CheckTallenMode(teamType, tallentData.modeEffectTalentTypeDetail) then

                local effectTalentType = tallentData.effectTalentType
                if effectTalentType == EFFECT_TALENT_TYPE.RATE then  -- 百分比加成
                    local valueByLevel = talentRateMap[tallentId] / 1000
                    for k, attrName in pairs(tallentData.effectTalentAttribute) do
                        tallentRate[attrName] = (tallentRate[attrName] or 0) + valueByLevel
                    end
                elseif effectTalentType == EFFECT_TALENT_TYPE.FIXED then  -- 固定属性加成
                    local valueByLevel = talentRateMap[tallentId]
                    for k, attrName in pairs(tallentData.effectTalentAttribute) do
                        tallentFixed[attrName] = (tallentFixed[attrName] or 0) + valueByLevel
                    end
                end
            end
        end
        local attrTallentRate = {}
        for k,v in pairs(attrList) do
            attr[v] = formationAttr + tacticAttr + (tallentFixed[v] or 0) + (assistantAttr[v] or 0)
            attrTallentRate[v] = tallentRate[v]
        end
        self.tallentRate = attrTallentRate
    end
    return attr
end

-- 教练带来的球员技能等级加成
function CoachMainModel:GetCoachSkillLvl(skill)
    local lvl = 0
    if skill == nil then
        return lvl
    end

    -- 教练加技能等级的一些限制条件
    local teamsModel = self:GetTeamsModel()
    if not teamsModel then
        return lvl
    end

    local pcid = self.playerCardModel:GetPcid()
    local posInTeam = teamsModel:GetPlayerInInitTeamPos(pcid)
    if not posInTeam then
        return lvl
    end

    local sid = tostring(skill.exSid or skill.sid)
    if sid == nil then
        return lvl
    end

    -- 获得增加的技能等级
     lvl = self:GetCoachSkillLvlCore(skill)
     return lvl
end

-- 计算教练增加技能等级的核心计算函数
-- 在此添加后续的增加技能等级的计算内容
function CoachMainModel:GetCoachSkillLvlCore(skill)
    local isPasterSkill = skill.ptid ~= nil -- 是否是贴纸技能
    local sid = tostring(skill.exSid or skill.sid)
    local lvl = 0

    -- 助理教练给球员技能等级提升
    local assistantSkillLvl = self:GetAssistantSkillLvl()
    lvl = lvl + (assistantSkillLvl[sid] or 0)
    if not isPasterSkill then -- 全技能加等级的时候，贴纸不加，EX技能加
        if assistantSkillLvl[KEY_ALL_SKILL] ~= nil and assistantSkillLvl[KEY_ALL_SKILL] > 0 then
            lvl = lvl + assistantSkillLvl[KEY_ALL_SKILL]
        end
    end

    -- add other

    return lvl
end

function CoachMainModel:GetTallenRate()
    return self.tallentRate or {}
end

function CoachMainModel:CheckTallenPosition(cardPos, tallentPos)
    cardPos = tostring(cardPos)
    if type(tallentPos) ~= "table" or not next(tallentPos) then
        return true
    end

    for k,v in pairs(tallentPos) do
        if PositionToNumber[cardPos] == v then
            return true
        end
    end
    return false
end

function CoachMainModel:CheckTallenQuality(cardQuality, tallentQuality)
    if type(tallentQuality) ~= "table" or not next(tallentQuality) then
        return true
    end
    for k,v in pairs(tallentQuality) do
        if cardQuality == v then
            return true
        end
    end
    return false
end

function CoachMainModel:CheckTallenMode(teamType, tallentTeamType)
    if type(tallentTeamType) ~= "table" or not next(tallentTeamType) then
        return true
    end
    for k,v in pairs(tallentTeamType) do
        if teamType == v then
            return true
        end
    end
    return false
end

function CoachMainModel:SetTeamModel(teamsModel)
    self.teamsModel = teamsModel
end

function CoachMainModel:GetTeamsModel()
    return self.teamsModel
end

function CoachMainModel:CacheCoachMissionData()
    local CoachMissionDetail = require("data.CoachMissionDetail")
    for k,v in pairs(CoachMissionDetail) do
        local tempCondition = {}
        for index, value in ipairs(v.missionCondition2) do
            local tValue = tostring(value)
            tempCondition[tValue] = tValue
        end
        v.missionCondition2 = tempCondition
    end
end

function CoachMainModel:GetFormationLvl(formationId)
    local formationInfo = self:GetFormationInfo()
    return formationInfo[tostring(formationId)] or 1
end

function CoachMainModel:GetCoachGuideData()
    local coachData = self:GetData()
    return coachData.guide or {}
end

function CoachMainModel:CacheCoachGuidePlayers()
    local cachGuideData = self:GetCoachGuideData()
    self.coachGuidePcids = {}
    for k,v in pairs(cachGuideData) do
        if v.pcid then
            self.coachGuidePcids[tostring(v.pcid)] = true
        end
    end
end

function CoachMainModel:GetCoachGuideSlotByPcid(pcid)
    if type(self.coachGuidePcids) == "table" then
        return self.coachGuidePcids[tostring(pcid)]
    end
end

function CoachMainModel:SetCoachGuideData(guide)
    self.cacheData.guide = guide or {}
end

-- 获得助理教练数据
function CoachMainModel:GetAssistantData()
    return self.cacheData.assistantCoach or {}
end

-- 缓存助理教练属性及技能加成
-- 属性：包括助教自身带来的属性加成和技能type=2带来的属性加成
-- 技能：type=1单技能加成及type=3全技能加成
function CoachMainModel:CacheAssistantPower()
    local assistantAttr, assistantSkillLvl = self:CacheAssistantPowerCore(self:GetAssistantData())
    cache.setCoachAssistantAttr(assistantAttr)
    cache.setCoachAssistantSkillLvl(assistantSkillLvl)
end

-- 计算助理教练增加的属性及技能等级辅助功能函数
-- @param [assistantData]: 助教上阵信息，{teamId = {acData}, ...}
-- @return [assistantAttr]: 助教增加属性的缓存，{attrName = attrVar, ...}
-- @return [assistantSkillLvl]: 助教增加技能等级的缓存，{sid = lvl, ...}
function CoachMainModel:CacheAssistantPowerCore(assistantData)
    local assistantAttr = {}
    local assistantSkillLvl = {}
    for teamIdx, acData in pairs(assistantData or {}) do
        local completeData = AssistantCoachModel.new():ParseFromConfig(acData)
        -- 助理教练自身属性
        for k, attr in pairs(completeData.ac_attrs or {}) do
            local attrName = tostring(attr.type)
            assistantAttr[attrName] = (assistantAttr[attrName] or 0) + attr.curr
        end
        -- 技能，加属性&技能等级
        for k, skill in pairs(completeData.skills) do
            if skill.isOpen then
                local skillType = tonumber(skill.skillType)
                if skillType == AssistantCoachConstants.SkillType.ToSkill then
                    for k, sid in ipairs(skill.skillImproveReal) do
                        assistantSkillLvl[sid] = (assistantSkillLvl[sid] or 0) + tonumber(skill.skillImproveAmount)
                    end
                elseif skillType == AssistantCoachConstants.SkillType.ToAttr then
                    for k, attrName in ipairs(skill.skillImproveReal) do
                        assistantAttr[attrName] = (assistantAttr[attrName] or 0) + tonumber(skill.skillImproveAmount)
                    end
                elseif skillType == AssistantCoachConstants.SkillType.ToAllSkill then
                    assistantSkillLvl[KEY_ALL_SKILL] = (assistantSkillLvl[KEY_ALL_SKILL] or 0) + tonumber(skill.skillImproveAmount)
                else
                    dump("wrong type of assistant skill: " .. skillType)
                end
            end
        end
    end
    return assistantAttr, assistantSkillLvl
end

-- 助理教练带来的属性加成
function CoachMainModel:GetAssistantAttr()
    return cache.getCoachAssistantAttr()
end

-- 助理教练带来的技能加成
function CoachMainModel:GetAssistantSkillLvl()
    return cache.getCoachAssistantSkillLvl()
end

-- 刷新助理教练数据，更换上阵&升级
function CoachMainModel:RefreshAssistantData(teamIdx, acData_new)
    self.cacheData.assistantCoach[tostring(teamIdx)] = acData_new
    self:CacheAssistantPower()
end

return CoachMainModel
