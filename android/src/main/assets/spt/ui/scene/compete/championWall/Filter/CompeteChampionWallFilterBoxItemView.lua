local SingleSelectFilterBoxItemView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoxItemView")

local CompeteChampionWallFilterBoxItemView = class(SingleSelectFilterBoxItemView, "CompeteChampionWallFilterBoxItemView")

function CompeteChampionWallFilterBoxItemView:ctor()
    CompeteChampionWallFilterBoxItemView.super.ctor(self)
end

function CompeteChampionWallFilterBoxItemView:InitView(filterData, filterType)
    CompeteChampionWallFilterBoxItemView.super.InitView(self, filterData, filterType)
end

function CompeteChampionWallFilterBoxItemView:SetName()
    self.txt.text = self.filterData.name
end

return CompeteChampionWallFilterBoxItemView
