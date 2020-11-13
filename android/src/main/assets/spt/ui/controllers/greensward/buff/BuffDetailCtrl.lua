local BaseCtrl = require("ui.controllers.BaseCtrl")
local BuffDetailCtrl = class(BaseCtrl, "BuffDetailCtrl")

BuffDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Buff/BuffDetail.prefab"

function BuffDetailCtrl:Init(greenswardBuildModel, greenswardResourceCache)
    self.view:InitView(greenswardBuildModel, greenswardResourceCache)
end

return BuffDetailCtrl
