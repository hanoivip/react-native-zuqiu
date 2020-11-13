local SingleSelectFilterBoxView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoxView")

local CompeteChampionWallFilterBoxView = class(SingleSelectFilterBoxView, "CompeteChampionWallFilterBoxView")

function CompeteChampionWallFilterBoxView:ctor()
    CompeteChampionWallFilterBoxView.super.ctor(self)
end

function CompeteChampionWallFilterBoxView:InitView(filterDatas, filterType)
    self.boxItemPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/ChampionWall/Prefabs/CompeteChampionWallFilterBoxItem.prefab"
    CompeteChampionWallFilterBoxView.super.InitView(self, filterDatas, filterType)
end

return CompeteChampionWallFilterBoxView
