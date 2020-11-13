local GameObjectHelper = require("ui.common.GameObjectHelper")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")
local LegendRoadImproveItemView = require("ui.scene.legendRoad.ImproveDetail.LegendRoadImproveItemView")

local LegendRoadImproveItemSglTxtView = class(LegendRoadImproveItemView, "LegendRoadImproveItemSglTxtView")

-- 只有一条属性加成
function LegendRoadImproveItemSglTxtView:ctor()
    LegendRoadImproveItemSglTxtView.super.ctor(self)
    self.txt = self.___ex.txt
    self.bg = self.___ex.bg
    self.supportNoAcBg = self.___ex.supportNoAcBg
    self.supportNoAcTxt = self.___ex.supportNoAcTxt
end

function LegendRoadImproveItemSglTxtView:InitView(legendRoadModel, improveType, detailImprove)
    LegendRoadImproveItemSglTxtView.super.InitView(self, legendRoadModel, improveType, detailImprove)
end

function LegendRoadImproveItemSglTxtView:RefreshView()
    if not self:HasInit() then
        return
    end
    GameObjectHelper.FastSetActive(self.bg, true)
    GameObjectHelper.FastSetActive(self.supportNoAcBg, false)
    if self.improveType == ImproveType.Attr_All then -- 不可培养全属性增加，1
        self.txt.text = lang.trans("legend_road_effect_1", self.detailImprove[1])
    elseif self.improveType == ImproveType.Attr_Train then -- 可培养全属性增加，2
        if self.legendRoadModel:IsActiveCurrStage() then
            self.txt.text = lang.trans("legend_road_effect_2", self.detailImprove[1])
        else
            GameObjectHelper.FastSetActive(self.bg, false)
            GameObjectHelper.FastSetActive(self.supportNoAcBg, true)
            self.supportNoAcTxt.text = lang.trans("legendroad_supporter_zerotrain")
        end
    elseif self.improveType == ImproveType.Skill_All then -- 全技能等级增加，5
        self.txt.text = lang.trans("legend_road_effect_5", self.detailImprove[1])
    elseif self.improveType == ImproveType.Paster_EX then -- EX贴纸，6
        self.txt.text = lang.trans("legend_road_effect_6")
    end
end

return LegendRoadImproveItemSglTxtView
