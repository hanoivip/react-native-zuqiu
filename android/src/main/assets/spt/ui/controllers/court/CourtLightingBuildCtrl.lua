local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtSubsidiaryBuildCtrl = require("ui.controllers.court.CourtSubsidiaryBuildCtrl")
local CourtLightingBuildCtrl = class(CourtSubsidiaryBuildCtrl)

CourtLightingBuildCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/SubsidiaryBuildLevelUp.prefab"

function CourtLightingBuildCtrl:Refresh(courtBuildModel)
    self.view:InitView(courtBuildModel, CourtBuildType.LightingBuild)
end

return CourtLightingBuildCtrl