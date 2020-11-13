local BaseCtrl = require("ui.controllers.BaseCtrl")
local ChapterRewardCtrl = class(BaseCtrl, "ChapterRewardCtrl")

ChapterRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/ChapterReward.prefab"

ChapterRewardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function ChapterRewardCtrl:Init(matchModel, greenswardBuildModel)
    self.view:InitView(matchModel, greenswardBuildModel)
end

return ChapterRewardCtrl