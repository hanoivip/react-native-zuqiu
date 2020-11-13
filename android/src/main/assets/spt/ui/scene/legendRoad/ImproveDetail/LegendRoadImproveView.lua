local GameObjectHelper = require("ui.common.GameObjectHelper")
local ImproveType = require("ui.models.legendRoad.LegendRoadImproveType")

local LegendRoadImproveView = class(unity.base, "LegendRoadImproveView")

function LegendRoadImproveView:ctor()
    -- 各种加成的脚本，LegendRoadImproveItemView
    self.sptImproveItem = self.___ex.sptImproveItem
end

function LegendRoadImproveView:InitView(legendRoadModel)
    self.legendRoadModel = legendRoadModel
    self.capicity = table.nums(self.sptImproveItem)
end

local function GetImproveItemKey(improveType)
    return tostring(improveType)
end

function LegendRoadImproveView:RefreshView(improveConfig)
    local improveItemKey = GetImproveItemKey(improveConfig.improveType)
    if improveItemKey then
        for k, spt in pairs(self.sptImproveItem) do
            GameObjectHelper.FastSetActive(spt.gameObject, k == improveItemKey)
        end
        -- dump(improveConfig.detailImprove, "类型：" .. improveConfig.improveType)
        self.sptImproveItem[improveItemKey]:InitView(self.legendRoadModel, improveConfig.improveType, improveConfig.detailImprove)
        self.sptImproveItem[improveItemKey]:RefreshView()
    end
end

return LegendRoadImproveView
