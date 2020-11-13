local BaseCtrl = require("ui.controllers.BaseCtrl")

local PlayerTreasureDetailCtrl = class(BaseCtrl)

PlayerTreasureDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureDetailBoard.prefab"

PlayerTreasureDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PlayerTreasureDetailCtrl:Init(treasureBonus)
    self.view:InitView(treasureBonus)
end

return PlayerTreasureDetailCtrl
