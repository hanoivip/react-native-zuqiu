local SingleSelectFilterBoardView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoardView")

local CompeteChampionWallFilterBoardView = class(SingleSelectFilterBoardView, "CompeteChampionWallFilterBoardView")

function CompeteChampionWallFilterBoardView:ctor()
    CompeteChampionWallFilterBoardView.super.ctor(self)
end

function CompeteChampionWallFilterBoardView:InitView(competeChampionWallModel, competeChampionWallView, competeChampionWallFilterModel)
    self.boardItemPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/ChampionWall/Prefabs/CompeteChampionWallFilterBoardItem.prefab"
    CompeteChampionWallFilterBoardView.super.InitView(self, competeChampionWallModel, competeChampionWallView, competeChampionWallFilterModel)
end

return CompeteChampionWallFilterBoardView
