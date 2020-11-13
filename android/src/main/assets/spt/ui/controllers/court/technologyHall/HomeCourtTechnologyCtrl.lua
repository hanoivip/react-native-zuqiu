local BaseCtrl = require("ui.controllers.BaseCtrl")
local HomeCourtTechnologyCtrl = class(BaseCtrl, "HomeCourtTechnologyCtrl")

HomeCourtTechnologyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Court/Prefab/HomeCourtTechnology.prefab"
function HomeCourtTechnologyCtrl:Init()

end

function HomeCourtTechnologyCtrl:Refresh(settingType, courtBuildModel, isMyHomeCourt, isNeutral)
    HomeCourtTechnologyCtrl.super.Refresh(self)
    self.view:InitView(settingType, courtBuildModel, isMyHomeCourt, isNeutral)
end

return HomeCourtTechnologyCtrl
