local SingleSelectFilterBoardView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoardView")

local PlaneFilterBoardView = class(SingleSelectFilterBoardView, "PlaneFilterBoardView")

function PlaneFilterBoardView:ctor()
    PlaneFilterBoardView.super.ctor(self)
end

function PlaneFilterBoardView:InitView(planeInformationModel, planeInformationView, planeFilterModel)
    self.boardItemPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/FilterBoardItem.prefab"
    PlaneFilterBoardView.super.InitView(self, planeInformationModel, planeInformationView, planeFilterModel)
end

return PlaneFilterBoardView
