local Model = require("ui.models.Model")
local Skills = require("data.Skills")
local SkillType = require("ui.common.enum.SkillType")
local PasterStateType = require("ui.scene.paster.PasterStateType")
local PasterMainType = require("ui.scene.paster.PasterMainType")

local PasterUpgradeFilterModel = class(Model)

function PasterUpgradeFilterModel:ctor(filterMap)
    PasterUpgradeFilterModel.super.ctor(self)
    self.filterMap = filterMap
    self.preFilterSkill = self.filterMap and self.filterMap.skill
    self:InitSkillViewData()
end

function PasterUpgradeFilterModel:GetFilterMap()
    return self.filterMap
end

function PasterUpgradeFilterModel:SetFilterMap(filterMap)
    self.filterMap = filterMap
end

function PasterUpgradeFilterModel:SetFilterSkill(skill)
    if not self.filterMap then
        self.filterMap = {}
    end
    self.filterMap.skill = skill
end

function PasterUpgradeFilterModel:SetPreFilterSkill()
    if not self.filterMap then
        self.filterMap = {}
    end
    self.filterMap.skill = self.preFilterSkill
end

function PasterUpgradeFilterModel:InitSkillViewData()
    self.skillList = {}
    local selectSkill = self.filterMap and self.filterMap.skill
    for sid, skill in pairs(Skills) do
        if skill.type == SkillType.EVENT then
            local skillData = {}
            skillData.skillID = skill.skillID
            skillData.name = skill.skillName
            skillData.picIndex = skill.picIndex
            skillData.type = skill.type
            skillData.isSelect = selectSkill == skill.skillID
            table.insert(self.skillList, skillData)
        end
    end
end

function PasterUpgradeFilterModel:GetSkillList()
    self:InitSkillViewData()
    return self.skillList
end

return PasterUpgradeFilterModel