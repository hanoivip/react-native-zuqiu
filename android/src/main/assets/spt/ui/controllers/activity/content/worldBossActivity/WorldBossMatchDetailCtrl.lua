local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local WorldBossMatchDetailCtrl = class(BaseCtrl)

WorldBossMatchDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossMatchDetailBoard.prefab"
WorldBossMatchDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}
function WorldBossMatchDetailCtrl:Init(response, opponentData)
    local data = {}
    data.contents = response.gift
    data.match = {}
    data.match.enemyName = opponentData["teamName"]
    data.match.enemyLogo = opponentData["teamLogo"]
    data.match.score = response.matchData.playerScore .."  :  " .. response.matchData.opponentScore
    local playerInfoModel = PlayerInfoModel.new()
    data.match.ourName = playerInfoModel:GetName()
    data.match.ourLogo = playerInfoModel:GetTeamLogo()
    self.view.onInitTeamLogo = function(teamLogo, logoData) self:OnInitTeamLogo(teamLogo, logoData) end
    self.view:InitView(data)
end

function WorldBossMatchDetailCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function WorldBossMatchDetailCtrl:Refresh()
end

return WorldBossMatchDetailCtrl