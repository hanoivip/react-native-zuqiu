local Skills = require("data.Skills")
local SkillType = require("ui.common.enum.SkillType")
local CardOpenFromType = require("ui.controllers.cardDetail.CardOpenFromType")
local Model = require("ui.models.Model")
local PasterQueueModel = class(Model, "PasterQueueModel")

function PasterQueueModel:ctor(cardModel, selectCardAppendPasterModel)
    PasterQueueModel.super.ctor(self)
    self.cardModel = cardModel
    self.selectCardAppendPasterModel = selectCardAppendPasterModel
    self:InitSkillViewData()
end

function PasterQueueModel:SetCardModel(cardModel)
    self.cardModel = cardModel
end

function PasterQueueModel:GetCardModel()
    return self.cardModel
end

function PasterQueueModel:GetSelectCardAppendPasterModel()
    return self.selectCardAppendPasterModel
end

function PasterQueueModel:GetPasterModelList()
    local cardModel = self.cardModel
    local tempPasterModel = clone(cardModel:GetPasterModel())
    local pasterModel = {}

    -- 检查是否选中这些类型 减少查询次数 start
    local isTypeSearch = false
    local isLevelSearch = false
    local isSkillSearch = false
    local pasterTypeTags, levelTag, skillTag = self:GetPasterSearchList()
    -- 是否选中贴纸类型
    for i, v in pairs(pasterTypeTags) do
        if v then
            isTypeSearch = true
            break
        end
    end
    -- 是否选中可升级
    if levelTag then
        isLevelSearch = true
    end
    -- 是否选中技能
    if skillTag then
        isSkillSearch = true
    end
    -- 检查是否选中这些类型 减少查询次数 end

    local hasPasterAvailable, hasPasterUsedByAll = cardModel:HasPasterAvailable()
    local isHasSearchResult = isTypeSearch or isLevelSearch or isSkillSearch
    if (hasPasterAvailable or hasPasterUsedByAll) and (not isHasSearchResult) then
        local appendData = {isAppend = true}
        table.insert(pasterModel, appendData)
    end

    if cardModel:GetOpenFromPageType() ==  CardOpenFromType.HANDBOOK then
        for k,v in pairs(tempPasterModel) do
            if v:GetPasterHandbook() then
                local isInSearch = self:IsInSearchPaster(v, isTypeSearch, isLevelSearch, isSkillSearch)
                if isInSearch then
                    table.insert(pasterModel, v)
                end
            end
        end
    else
        for k,v in pairs(tempPasterModel) do
            local isInSearch = self:IsInSearchPaster(v, isTypeSearch, isLevelSearch, isSkillSearch)
            if isInSearch then
                table.insert(pasterModel, v)
            end
        end
    end
    return pasterModel
end

function PasterQueueModel:IsInSearchPaster(pasterModel, isTypeSearch, isLevelSearch, isSkillSearch)
    local pasterTypeTags, levelTag, skillTag = self:GetPasterSearchList()
    local isInSearch = true
    if isTypeSearch then
        local pasterType = pasterModel:GetPasterType()
        pasterType = tostring(pasterType)
        if not pasterTypeTags[pasterType] then
            return false
        end
    end

    if isLevelSearch then
        local skillData = pasterModel:GetPasterSkillData()
        local skillMaxLvl = skillData.skillMaxLvl
        local lvl = skillData.lvl
        if levelTag == "full" and lvl < skillMaxLvl then
            return false
        end
        if levelTag == "notFull" and lvl >= skillMaxLvl then
            return false
        end
    end

    if isSkillSearch then
        local skillData = pasterModel:GetPasterSkillData()
        local sid = (skillData.exSid ~= "" and skillData.exSid) or (skillData.sid ~= "" and skillData.sid) or skillData.skillImprove
        if sid ~= skillTag then
            return false
        end
    end
    return isInSearch
end

function PasterQueueModel:GetPasterSearchList()
    self.pasterTypeTags = self.pasterTypeTags or {}
    return self.pasterTypeTags, self.levelTag, self.skillTag
end

function PasterQueueModel:SetPasterSearchList(pasterTypeTags, levelTag, skillTag)
    self.pasterTypeTags = pasterTypeTags or {}
    self.levelTag = levelTag
    self.skillTag = skillTag
end

local HideLegendSkillIndex = 1
function PasterQueueModel:InitSkillViewData()
    self.skillList = {}
    self.skillMap = {}
    for sid, skill in pairs(Skills) do
        local unShow = skill.unShow and tonumber(skill.unShow)
        local openValue = skill.openValue and tonumber(skill.openValue)
        local isOpenSkill = (openValue == nil or openValue == HideLegendSkillIndex) -- ex技能是否投放字段
        isOpenSkill = isOpenSkill and (unShow == nil or unShow ~= HideLegendSkillIndex) -- 普通技能是否显示字段
        if isOpenSkill and skill.type ~= SkillType.CHEMICAL and skill.type ~= SkillType.MEDAL then
            if luaevt.reg("__VN__VERSION__") and skill.type == SkillType.TRAINING then
                -- VI 屏蔽贴纸筛选的Ex技能
            else
                local skillData = {}
                skillData.skillID = skill.skillID or sid
                skillData.name = skill.skillName
                skillData.picIndex = skill.picIndex
                skillData.type = skill.type
                skillData.isSelect = false
                self.skillMap[sid] = skillData
                table.insert(self.skillList, skillData)
            end
        end
    end
    table.sort(self.skillList, function(a, b) return a.type > b.type end)
end

function PasterQueueModel:GetSkillList()
    return self.skillList
end

function PasterQueueModel:GetSkillIndexBySkillTag(skillTag)
    for i, v in ipairs(self.skillList) do
        if v.skillID == skillTag then
            return i
        end
    end
end

function PasterQueueModel:GetSkillPicIndex(skillID)
    local skillData = self.skillMap[skillID]
    return skillData.picIndex
end

return PasterQueueModel
