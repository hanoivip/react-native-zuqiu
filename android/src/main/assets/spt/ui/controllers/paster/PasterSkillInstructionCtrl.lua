local BaseCtrl = require("ui.controllers.BaseCtrl")
local PasterSkillInstructionCtrl = class(BaseCtrl)
PasterSkillInstructionCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Paster/PasterSkillInstruction.prefab"
PasterSkillInstructionCtrl.dialogStatus = {
    touchClose = true,
    withShadow = false,
    unblockRaycast = false,
}

function PasterSkillInstructionCtrl:Init()
end

function PasterSkillInstructionCtrl:Refresh(cardPasterModel, bSupporter)
    self.view:InitView(cardPasterModel, bSupporter)
end

return PasterSkillInstructionCtrl
