local BaseCtrl = require("ui.controllers.BaseCtrl")

local PowerShootDetailCtrl = class(BaseCtrl)

PowerShootDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitPowerShoot/PowerShootDetailBoard.prefab"

function PowerShootDetailCtrl:Init(rewardBonus)
    self.view:InitView(rewardBonus)
end

return PowerShootDetailCtrl
