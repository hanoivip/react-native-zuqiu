local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtSubsidiaryBuildCtrl = require("ui.controllers.court.CourtSubsidiaryBuildCtrl")
local CourtStoreBoardBuildCtrl = class(CourtSubsidiaryBuildCtrl)

CourtStoreBoardBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SubsidiaryBuildLevelUp.prefab"

function CourtStoreBoardBuildCtrl:Refresh(courtBuildModel)
    self.view:InitView(courtBuildModel, CourtBuildType.StoreBuild)
end

return CourtStoreBoardBuildCtrl