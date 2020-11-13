local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerDollTaskCtrl = class(BaseCtrl)

PlayerDollTaskCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerDoll/PlayerDollTaskBoard.prefab"

function PlayerDollTaskCtrl:Refresh(playerDollModel)
    self.playerDollModel = playerDollModel
    self.view:InitView(self.playerDollModel)
end

return PlayerDollTaskCtrl