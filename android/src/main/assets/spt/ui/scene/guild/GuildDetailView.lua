local UnityEngine = clr.UnityEngine
local UI = UnityEngine.UI
local Text = UI.Text
local Vector2 = UnityEngine.Vector2
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")

local GuildDetailView = class(unity.base)

function GuildDetailView:ctor()
    self.close = self.___ex.close
    self.guildLogo = self.___ex.guildLogo
    self.guildName = self.___ex.guildName
    self.adminLogo = self.___ex.adminLogo
    self.adminName = self.___ex.adminName
    self.contribute = self.___ex.contribute
    self.warBest = self.___ex.warBest
    self.contributeRank = self.___ex.contributeRank
    self.warRank = self.___ex.warRank
    self.memberNum = self.___ex.memberNum
    self.reqType = self.___ex.reqType
    self.reqLevel = self.___ex.reqLevel
    self.notice = self.___ex.notice
    self.powerTxt = self.___ex.powerTxt
    self.mistNum = self.___ex.mistNum
end

function GuildDetailView:start()
    DialogAnimation.Appear(self.transform)

    self.close:regOnButtonClick(function()
        self:Close()
    end)
end

function GuildDetailView:InitView(guildDetailModel)
    self.guildLogo.sprite = guildDetailModel:GetGuildLogo()
    self.guildName.text = guildDetailModel:GetGuildName()
    local logoTable = guildDetailModel:GetAdminLogo()
    TeamLogoCtrl.BuildTeamLogo(self.adminLogo, logoTable)
    self.adminName.text = guildDetailModel:GetAdminName()
    self.contribute.text = guildDetailModel:GetContribute()
    self.warBest.text = guildDetailModel:GetBestWarInfo()
    self.mistNum.text = guildDetailModel:GetBestMistWarInfo()
    self.contributeRank.text = guildDetailModel:GetContributeRank()
    self.warRank.text = guildDetailModel:GetWarRank()
    self.memberNum.text = guildDetailModel:GetMemberNum() .. "/40"
    self.reqType.text = guildDetailModel:GetReqType()
    self.reqLevel.text = guildDetailModel:GetReqLevel()
    self.notice.text = guildDetailModel:GetNotice()
    self.powerTxt.text = string.formatIntWithTenThousands(guildDetailModel:GetPower())
end

function GuildDetailView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

return GuildDetailView