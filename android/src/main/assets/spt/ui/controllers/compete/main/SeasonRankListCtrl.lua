local BaseCtrl = require("ui.controllers.BaseCtrl")

local SeasonRankListCtrl = class(BaseCtrl, "SeasonRankListCtrl")

SeasonRankListCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Main/Prefab/SeasonRankList.prefab"

SeasonRankListCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function SeasonRankListCtrl:Init(competeMainModel)
    self.view:InitView(competeMainModel)
end

return SeasonRankListCtrl