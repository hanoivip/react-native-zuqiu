local GameObjectHelper = require("ui.common.GameObjectHelper")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")

local LegendRoadImproveItemView = class(unity.base, "LegendRoadImproveItemView")

-- 各类加成的父类
function LegendRoadImproveItemView:ctor()
end

function LegendRoadImproveItemView:InitView(legendRoadModel, improveType, detailImprove)
    self.legendRoadModel = legendRoadModel
    self.improveType = improveType
    self.detailImprove = detailImprove
end

function LegendRoadImproveItemView:RefreshView()
    if not self:HasInit() then
        return
    end

    if self.improveType == ImproveType.Attr_All then -- 不可培养全属性增加
    elseif self.improveType == ImproveType.Attr_Train then -- 可培养全属性增加
    elseif self.improveType == ImproveType.Attr_Single then -- 单属性增加
    elseif self.improveType == ImproveType.Skill_Single then -- 单技能等级增加
    elseif self.improveType == ImproveType.Skill_All then -- 全技能等级增加
    elseif self.improveType == ImproveType.Paster_EX then -- EX贴纸
    elseif self.improveType == ImproveType.Skill_New then -- 新技能
    end
end

function LegendRoadImproveItemView:HasInit()
    return self.legendRoadModel ~= nil and self.improveType ~= nil and not table.isEmpty(self.detailImprove)
end

return LegendRoadImproveItemView
