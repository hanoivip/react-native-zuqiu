local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local DreamBattleRoomInfoItemView = class(unity.base)

function DreamBattleRoomInfoItemView:ctor()
    self.logoImg = self.___ex.logoImg
    self.serverTxt = self.___ex.serverTxt
    self.nameTxt = self.___ex.nameTxt
    self.detailBtn = self.___ex.detailBtn
    self.entry = self.___ex.entry
    self.noEntry = self.___ex.noEntry
end

function DreamBattleRoomInfoItemView:start()
    self.detailBtn:regOnButtonClick(function()
        res.PushDialog("ui.controllers.dreamLeague.dreamSelectPlayer.DreamSelectPlayerCtrl", self.id, self.playerData.pid)
    end)
end

function DreamBattleRoomInfoItemView:InitView(playerData, id)
    self.playerData = playerData
    self.id = id
    GameObjectHelper.FastSetActive(self.entry, playerData)
    GameObjectHelper.FastSetActive(self.noEntry, not playerData)

    if not playerData then
        return
    end

    self.serverTxt.text = playerData.serverName
    self.nameTxt.text = playerData.name

    self:OnInitTeamLogo(self.logoImg, playerData.logo)
end

function DreamBattleRoomInfoItemView:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return DreamBattleRoomInfoItemView
