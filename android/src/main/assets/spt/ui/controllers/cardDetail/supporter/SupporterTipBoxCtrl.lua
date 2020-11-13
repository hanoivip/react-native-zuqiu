local BaseCtrl = require("ui.controllers.BaseCtrl")
local SupporterTipBoxCtrl = class(BaseCtrl, "SupporterTipBoxCtrl")

SupporterTipBoxCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/SupporterTipBox.prefab"

function SupporterTipBoxCtrl:Refresh(tips)
    self.view:InitView(tips)
end

return SupporterTipBoxCtrl