local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local Skills = require("data.Skills")
local LegendRoadImproveTabView = class(unity.base, "LegendRoadImproveTabView")

function LegendRoadImproveTabView:ctor()
    self.desc = self.___ex.desc
end

function LegendRoadImproveTabView:InitView(improveData, cardModel)
    local improveType = improveData.improveType
    local desc = ""

    if improveType == ImproveType.Attr_All then
        desc = lang.trans("legend_road_effect_1", improveData.allAttr)
    elseif improveType == ImproveType.Attr_Train then
        desc = lang.trans("legend_road_effect_2", improveData.potent)
    elseif improveType == ImproveType.Paster_EX then
        desc = lang.trans("legend_road_effect_6")
    elseif improveType == ImproveType.Skill_All then
        desc = lang.trans("legend_road_effect_5", improveData.allSkill)
    elseif improveType == ImproveType.Attr_Single then
        local attr = improveData.attr
        local name = lang.transstr(attr.key)
        local value = attr.value
        desc = lang.transstr("legend_road_effect_3", name, value)
    elseif improveType == ImproveType.Skill_Single then
        local skill = improveData.skill
        local skillItemModel = cardModel:GetSkillModel(tonumber(skill.slot))
        local name = skillItemModel:GetName()
        local value = skill.value
        desc = lang.transstr("legend_road_effect_4", name, value)
    elseif improveType == ImproveType.Skill_New then
        local skillId = next(improveData.legendSkill)
        local skillData = Skills[skillId] or {}
        local name = skillData.skillName
        desc = lang.trans("legend_road_effect_7", name)
    end
    self.desc.text = desc
end

return LegendRoadImproveTabView