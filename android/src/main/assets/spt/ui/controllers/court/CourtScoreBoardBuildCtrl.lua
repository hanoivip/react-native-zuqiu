local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtSubsidiaryBuildCtrl = require("ui.controllers.court.CourtSubsidiaryBuildCtrl")
local CourtScoreBoardBuildCtrl = class(CourtSubsidiaryBuildCtrl)

CourtScoreBoardBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SubsidiaryBuildLevelUp.prefab"

function CourtScoreBoardBuildCtrl:Refresh(courtBuildModel)
    self.view:InitView(courtBuildModel, CourtBuildType.ScoreBoardBuild)
end

return CourtScoreBoardBuildCtrl