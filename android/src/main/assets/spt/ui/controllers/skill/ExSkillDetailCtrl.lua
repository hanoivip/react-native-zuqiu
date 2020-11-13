local ExSkillDetailModel = require("ui.models.skill.ExSkillDetailModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local ExSkillDetailCtrl = class(BaseCtrl)

ExSkillDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SkillDetail/ExSkillDetail.prefab"

ExSkillDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function ExSkillDetailCtrl:Refresh(skillItemModel)
    local exSkillDetailModel = ExSkillDetailModel.new(skillItemModel)
    self.view:InitView(exSkillDetailModel)
end

return ExSkillDetailCtrl
