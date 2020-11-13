local SingleSelectFilterBoardView = require("ui.scene.coach.common.singleSelectFilter.SingleSelectFilterBoardView")

local AssistInfoFilterBoardView = class(SingleSelectFilterBoardView, "AssistInfoFilterBoardView")

function AssistInfoFilterBoardView:ctor()
    AssistInfoFilterBoardView.super.ctor(self)
end

function AssistInfoFilterBoardView:InitView(assistCoachInformationModel, assistCoachInformationView, assistCoachFilterModel)
    self.boardItemPath = "Assets/CapstonesRes/Game/UI/Scene/Coach/AssistCoachInformation/AssistInfoFilterBoardItem.prefab"
    AssistInfoFilterBoardView.super.InitView(self, assistCoachInformationModel, assistCoachInformationView, assistCoachFilterModel)
end

return AssistInfoFilterBoardView
