local Skills = require("data.Skills")
local SkillType = require("ui.common.enum.SkillType")
local Model = require("ui.models.Model")

local MedalListSkillSearchModel = class(Model, "MedalListSkillSearchModel")

function MedalListSkillSearchModel:ctor()
    MedalListSkillSearchModel.super.ctor(self)
    self.eventSkills = {}
    self.medalSkills = {}
    self.selectSkill = {} -- 最终技能选择id列表

    self.selectEventSkillData = nil -- 最终event技能的选择
    self.selectEventSkillDataTemp = nil -- 界面上临时的event技能选择

    self.selectMedalSkillData = nil -- 最终的medal技能选择
    self.selectMedalSkillDataTemp = nil -- 界面上临时的medal技能选择
end

function MedalListSkillSearchModel:InitSkillDatas()
    self:InitEventSkillList()
    self:InitMedalSkillList()
end

local HideLegendSkillIndex = 1
-- 初始化普通技能
function MedalListSkillSearchModel:InitEventSkillList(selectData)
    self.eventSkills = {}
    for k, eventSkill in pairs(Skills) do
        if eventSkill.type == SkillType.EVENT and tonumber(eventSkill.unShow) ~= HideLegendSkillIndex then
            local skillData = {}
            skillData.name = eventSkill.skillName
            skillData.skillID = eventSkill.skillID
            skillData.picIndex = eventSkill.picIndex
            skillData.isSelect = (selectData ~= nil) and (selectData.skillID == skillData.skillID)
            table.insert(self.eventSkills, skillData)
        end
    end
end

-- 初始化其他技能
function MedalListSkillSearchModel:InitMedalSkillList(selectData)
    self.medalSkills = {}
    for k, medalSkill in pairs(Skills) do
        if medalSkill.type == SkillType.MEDAL then
            local skillData = {}
            skillData.name = medalSkill.skillName
            skillData.skillID = medalSkill.skillID
            skillData.picIndex = medalSkill.picIndex
            skillData.isSelect = selectData and (selectData.skillID == skillData.skillID)
            table.insert(self.medalSkills, skillData)
        end
    end
end

function MedalListSkillSearchModel:GetEventSkillList(selectData)
    self:InitEventSkillList(selectData)
    return self.eventSkills
end

function MedalListSkillSearchModel:GetMedalSkillList(selectData)
    self:InitMedalSkillList(selectData)
    return self.medalSkills
end

function MedalListSkillSearchModel:SetSelectEventSkillData(eventSkill)
    if eventSkill then
        eventSkill.isSelect = true
        self.selectSkill.eventSkill = eventSkill.skillID
    else
        self.selectSkill.eventSkill = nil
    end
    -- 旧的设置为false
    if self.selectEventSkillData then
        self.selectEventSkillData.isSelect = false
    end
    self.selectEventSkillData = eventSkill
end

function MedalListSkillSearchModel:GetSelectEventSkillData()
    return self.selectEventSkillData
end

function MedalListSkillSearchModel:GetSelectEventTempSkillData()
    return self.selectEventSkillDataTemp
end

function MedalListSkillSearchModel:SetSelectEventTempSkillData(eventSkill)
    if eventSkill and eventSkill.isSelect then
        self.selectEventSkillDataTemp = eventSkill
    else
        self.selectEventSkillDataTemp = nil
    end
end

function MedalListSkillSearchModel:ResetSelectEventTempSkillData()
    if self.selectEventSkillDataTemp then
        self.selectEventSkillDataTemp.isSelect = false
        self.selectEventSkillDataTemp = nil
    end
end

function MedalListSkillSearchModel:SetSelectMedalSkillData(medalSkill)
    if medalSkill then
        medalSkill.isSelect = true
        self.selectSkill.medalSkill = medalSkill.skillID
    else
        self.selectSkill.medalSkill = nil
    end
    -- 旧的设置为false
    if self.selectMedalSkillData then
        self.selectMedalSkillData.isSelect = false
    end
    self.selectMedalSkillData = medalSkill
end

function MedalListSkillSearchModel:GetSelectMedalSkillData()
    return self.selectMedalSkillData
end

function MedalListSkillSearchModel:GetSelectSkill()
    return self.selectSkill
end

function MedalListSkillSearchModel:GetSelectMedalTempSkillData()
    return self.selectMedalSkillDataTemp
end

function MedalListSkillSearchModel:SetSelectMedalTempSkillData(medalSkill)
    if medalSkill and medalSkill.isSelect then
        self.selectMedalSkillDataTemp = medalSkill
    else
        self.selectMedalSkillDataTemp = nil
    end
end

function MedalListSkillSearchModel:ResetSelectMedalTempSkillData()
    if self.selectMedalSkillDataTemp then
        self.selectMedalSkillDataTemp.isSelect = false
        self.selectMedalSkillDataTemp = nil
    end
end

function MedalListSkillSearchModel:GetEventSelectSkillNum()
    if self:GetSelectEventSkillData() then
        return 1
    else
        return 0
    end
end

function MedalListSkillSearchModel:GetMedalSelectSkillNum()
    if self:GetSelectMedalSkillData() then
        return 1
    else
        return 0
    end
end

-- 进入界面存一下界面的技能选择状态
function MedalListSkillSearchModel:SavePreSkillSelectData()
    self.preSelectMedalSkillData = clone(self.selectMedalSkillData)
    self.preSelectEventSkillData = clone(self.selectEventSkillData)
    self.preSelectSkill = clone(self.selectSkill)
end

-- 如果在退出界面前没有确认 没有重置 直接关闭的话 还原为进入时的状态
function MedalListSkillSearchModel:RecoverPreSkillSelectData()
    self.selectMedalSkillData = self.preSelectMedalSkillData
    self.selectEventSkillData = self.preSelectEventSkillData
    self.selectSkill = self.preSelectSkill
end

function MedalListSkillSearchModel:ResetSelectSkill()
    self:SetSelectEventSkillData()
    self:SetSelectMedalSkillData()
end

return MedalListSkillSearchModel
