local GameObjectHelper = require("ui.common.GameObjectHelper")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")

local LegendRoadImproveItemToggleSelItemView = class(unity.base, "LegendRoadImproveItemToggleSelItemView")

function LegendRoadImproveItemToggleSelItemView:ctor()
    self.toggle = self.___ex.toggle
    self.txtLabel = self.___ex.txtLabel
    self.toggle.onValueChanged:AddListener(function (isOn)
        if isOn then
            if self.selectSlot and tonumber(self.selectSlot) ~= tonumber(self.slot) then
                EventSystem.SendEvent("LegendRoad_ToggleSelect", self.improveType, self.slot)
            end
        end
    end)
end

function LegendRoadImproveItemToggleSelItemView:InitView(index, legendRoadModel, detail, improveType, detailImprove)
    self.improveType = improveType
    self.detailImprove = detailImprove

    self.index = index
    self.slot = detail.slot or index
    self.selectSlot = -1
    if improveType == ImproveType.Attr_Single then -- 单属性增加，3
        self.txtLabel.text = lang.trans("legend_road_effect_" .. improveType, detail.name, detailImprove[1])
    elseif improveType == ImproveType.Skill_Single then -- 单技能等级增加，4
        self.txtLabel.text = lang.trans("legend_road_effect_" .. improveType, detail.name, detailImprove[detail.slot])
    end

    if not self.toggle.isOn then -- 只有当toggle为false才可以改动数值
        local isActive = false
        local chapterId = legendRoadModel:GetCurrChapterId()
        local stageId = legendRoadModel:GetCurrStageId()
        local pcid = legendRoadModel:GetCardModel():GetPcid()
        self.selectSlot = legendRoadModel:GetAppointStageActiveIndex(pcid, chapterId, stageId)
        if self.selectSlot then
            isActive = tobool(tonumber(self.slot) == tonumber(self.selectSlot))
        end
        self.toggle.isOn = isActive
    end
end

return LegendRoadImproveItemToggleSelItemView
