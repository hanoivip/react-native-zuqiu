local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtSubsidiaryBuildCtrl = require("ui.controllers.court.CourtSubsidiaryBuildCtrl")
local CourtAudienceBuildCtrl = class(CourtSubsidiaryBuildCtrl)

CourtAudienceBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SubsidiaryBuildLevelUp.prefab"

function CourtAudienceBuildCtrl:Refresh(courtBuildModel)
    self.view:InitView(courtBuildModel, CourtBuildType.AudienceBuild)
end

return CourtAudienceBuildCtrl