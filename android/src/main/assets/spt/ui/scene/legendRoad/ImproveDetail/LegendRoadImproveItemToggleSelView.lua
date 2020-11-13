local GameObjectHelper = require("ui.common.GameObjectHelper")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local LegendRoadImproveItemView = require("ui.scene.legendRoad.ImproveDetail.LegendRoadImproveItemView")

local LegendRoadImproveItemToggleSelView = class(LegendRoadImproveItemView, "LegendRoadImproveItemToggleSelView")

-- 有多项单选框的属性加成
function LegendRoadImproveItemToggleSelView:ctor()
    LegendRoadImproveItemToggleSelView.super.ctor(self)
    self.sptToggles = self.___ex.sptToggles
end

function LegendRoadImproveItemToggleSelView:InitView(legendRoadModel, improveType, detailImprove)
    LegendRoadImproveItemToggleSelView.super.InitView(self, legendRoadModel, improveType, detailImprove)
    self.legendRoadModel = legendRoadModel
    self.capacity = table.nums(self.sptToggles)
end

function LegendRoadImproveItemToggleSelView:RefreshView()
    if not self:HasInit() then
        return
    end
    local detailTypeList = {}
    if self.improveType == ImproveType.Attr_Single then -- 单属性增加，3
        detailTypeList = self.legendRoadModel:GetImproveAttrTypeList() -- 属性名称key列表
    elseif self.improveType == ImproveType.Skill_Single then -- 单技能等级增加，4
        detailTypeList = self.legendRoadModel:GetImproveSkillNameList(self.detailImprove) -- 技能名称及槽位列表
    end

    local count = #detailTypeList
    for i = 1, self.capacity do
        local spt = self.sptToggles[tostring(i)]
        local isShow = i <= count
        GameObjectHelper.FastSetActive(spt.gameObject, isShow)
        if isShow then
            spt:InitView(i, self.legendRoadModel, detailTypeList[i], self.improveType, self.detailImprove)
        end
    end
end

return LegendRoadImproveItemToggleSelView
