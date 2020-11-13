local BaseCtrl = require("ui.controllers.BaseCtrl")
local LegendSkillDetailCtrl = class(BaseCtrl)

LegendSkillDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SkillDetail/LegendSkillDetail.prefab"

LegendSkillDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function LegendSkillDetailCtrl:Refresh(skillItemModel)
    self.view:InitView(skillItemModel)
end

return LegendSkillDetailCtrl
