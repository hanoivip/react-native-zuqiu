local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local SeasonRankListItemView = class()

function SeasonRankListItemView:ctor()
    self.playerName = self.___ex.playerName
    self.playerServer = self.___ex.playerServer
    self.playerIcon = self.___ex.playerIcon
end

function SeasonRankListItemView:InitView(data)
    self.playerName.text = data.name
    TeamLogoCtrl.BuildTeamLogo(self.playerIcon, data.logo)
    self.playerServer.text = data.serverName
end

return SeasonRankListItemView