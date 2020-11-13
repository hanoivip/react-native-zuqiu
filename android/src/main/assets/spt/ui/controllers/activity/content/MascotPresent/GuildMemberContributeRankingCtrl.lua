local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GuildMemberContributeRankingCtrl = class(BaseCtrl, "GuildMemberContributeRankingCtrl")

GuildMemberContributeRankingCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

GuildMemberContributeRankingCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/MascotPresent/GuildMemberContributeRanking.prefab"

function GuildMemberContributeRankingCtrl:ctor()
end

function GuildMemberContributeRankingCtrl:Init(mascotPresentModel)
    self.activityModel = mascotPresentModel
    self.view:InitView(self.activityModel)
end

function GuildMemberContributeRankingCtrl:OnEnterScene()
end

function GuildMemberContributeRankingCtrl:OnExitScene()
end

return GuildMemberContributeRankingCtrl