local SubBaseSupporterCtrl = require("ui.controllers.cardDetail.supporter.SubBaseSupporterCtrl")
local PasterSupporterCtrl = class(SubBaseSupporterCtrl, "PasterSupporterCtrl")

local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/PasterSupportBoard.prefab"

function PasterSupporterCtrl:ctor(pasterSupporterModel, parentTrans)
    PasterSupporterCtrl.super.ctor(self, pasterSupporterModel, parentTrans, prefabPath)
end

function PasterSupporterCtrl:Init()

end

return PasterSupporterCtrl
