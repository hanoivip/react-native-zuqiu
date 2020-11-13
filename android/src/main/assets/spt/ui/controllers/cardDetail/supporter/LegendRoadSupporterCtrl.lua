local SubBaseSupporterCtrl = require("ui.controllers.cardDetail.supporter.SubBaseSupporterCtrl")
local LegendRoadSupporterCtrl = class(SubBaseSupporterCtrl, "LegendRoadSupporterCtrl")

local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Supporter/LegendRoadSupportBoard.prefab"

function LegendRoadSupporterCtrl:ctor(legendRoadSupporterModel, parentTrans)
    LegendRoadSupporterCtrl.super.ctor(self, legendRoadSupporterModel, parentTrans, prefabPath)
end

function LegendRoadSupporterCtrl:Init()

end

return LegendRoadSupporterCtrl
