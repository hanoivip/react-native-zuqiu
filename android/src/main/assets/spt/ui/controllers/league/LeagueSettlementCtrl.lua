local MatchInfoModel = require("ui.models.MatchInfoModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local LeagueSettlementCtrl = class(BaseCtrl)

LeagueSettlementCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/League/LeagueSettlement.prefab"

LeagueSettlementCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false
}

function LeagueSettlementCtrl:Init()
    self.matchInfoModel = MatchInfoModel.GetInstance()
end

function LeagueSettlementCtrl:Refresh()
    self.view:InitView(self.matchInfoModel)
end

return LeagueSettlementCtrl
