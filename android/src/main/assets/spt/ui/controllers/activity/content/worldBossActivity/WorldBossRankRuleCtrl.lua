local BaseCtrl = require("ui.controllers.BaseCtrl")
local WorldBossRankModel = require("ui.models.activity.worldBossActivity.WorldBossRankModel")
local WorldBossSeverRank = require("data.WorldBossSeverRank")
local WorldBossSingleRank = require("data.WorldBossSingleRank")
local WorldBossRankRuleCtrl = class(BaseCtrl)

WorldBossRankRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossRankRule.prefab"
WorldBossRankRuleCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function WorldBossRankRuleCtrl:Init(isSelf)
    self.isSelf = isSelf
    self.view:InitView(isSelf)
end

return WorldBossRankRuleCtrl