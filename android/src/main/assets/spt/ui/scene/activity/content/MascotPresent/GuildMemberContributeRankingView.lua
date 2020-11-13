local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GuildMemberContributeRankingView = class(unity.base)

function GuildMemberContributeRankingView:ctor()
    self.rankingScrollView = self.___ex.rankingScrollView
    self.closeBtn = self.___ex.closeBtn
    self.myRankText = self.___ex.myRankText
    self.myPointText = self.___ex.myPointText

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function GuildMemberContributeRankingView:start()
end

function GuildMemberContributeRankingView:InitView(mascotPresentModel)
    self.activityModel = mascotPresentModel
    self.rankingScrollView:InitView(self.activityModel)
    self:InitMyContributeInfo() --放在initview的后面
end

function GuildMemberContributeRankingView:InitMyContributeInfo()
    self.myRankText.text = tostring(self.activityModel:GetMyContributeRankInGuild())
    self.myPointText.text = tostring(self.activityModel:GetMyContributePointValue())
end

function GuildMemberContributeRankingView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return GuildMemberContributeRankingView