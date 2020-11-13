local BaseCtrl = require("ui.controllers.BaseCtrl")
local ContributeRecordCtrl = class(BaseCtrl)

ContributeRecordCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

ContributeRecordCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/GoldCup/ContributeRecordBoard.prefab"

function ContributeRecordCtrl:ctor()
end

function ContributeRecordCtrl:Init(goldCupModel)
    self.goldCupModel = goldCupModel
    self.view:InitView(self.goldCupModel)
end

return ContributeRecordCtrl

