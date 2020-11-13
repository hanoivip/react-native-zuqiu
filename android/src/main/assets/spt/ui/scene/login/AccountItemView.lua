local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local LuaButton = require("ui.control.button.LuaButton")

local AccountItemView = class(LuaButton)

function AccountItemView:ctor()
    AccountItemView.super.ctor(self)    
    self.serverItem = self.___ex.serverItem
    self.accountName = self.___ex.accountName
    self.accountLevel = self.___ex.accountLevel
    self.teamLogo = self.___ex.teamLogo
end

function AccountItemView:Init(serverNumDisplayName, serverName, statusNum, accountName, accountLevel, teamLogoData, index)
    self.index = index
    self.serverItem:Init(serverNumDisplayName, serverName, statusNum, false)

    self.accountName.text = (type(accountName) == "string" and accountName ~= "") and accountName or lang.transstr("team_info_not_set")
    self.accountLevel.text = "LV " .. tostring(accountLevel)

    res.ClearChildren(self.teamLogo)
    local teamLogo = TeamLogoCtrl.new()
    if type(teamLogoData) == "table" then
        teamLogoData = PlayerInfoModel.TransTeamLogoData(teamLogoData)
    end
    teamLogo:Init(teamLogoData)
    teamLogo.view.transform:SetParent(self.teamLogo, false)
end

return AccountItemView

