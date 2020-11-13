local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransportMatchDetailsModel = require("ui.models.transfort.TransportMatchDetailsModel")
local MatchLoader = require("coregame.MatchLoader")
local DialogManager = require("ui.control.manager.DialogManager")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local TransportMatchDetailCtrl = class(BaseCtrl)

TransportMatchDetailCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

TransportMatchDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportMatchDetailBoard.prefab"

function TransportMatchDetailCtrl:Init(matchDetailsData)
    self.transportMatchDetailsModel = TransportMatchDetailsModel.new()
    self.transportMatchDetailsModel:InitWithParentProtocol(matchDetailsData)
    self.view.onInitTeamLogo = function(teamLogo, logoData) self:OnInitTeamLogo(teamLogo, logoData) end
    self.view.onChangeStyle = function(selectIndex) 
        if self.transportMatchDetailsModel:CheckIsHaveTeam(selectIndex) then
            self.transportMatchDetailsModel:SetTeamID(selectIndex) 
            self.view:SetButtonStyle(selectIndex)
        else
            DialogManager.ShowToast(lang.trans("transport_robbery_team_nil_title"))
        end
    end
    self.view.onChallengeOver = function() self:OnOverChallenge() end
    self.view.onContinueChallenge = function(style) self:OnContinueChallenge(style) end
    self.view:InitView(self.transportMatchDetailsModel)
    NewYearCongratulationsPageCtrl.new(matchDetailsData, NewYearOutPutPosType.TRANSPORT)
end

function TransportMatchDetailCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function TransportMatchDetailCtrl:OnContinueChallenge(style)
    if self.startReq then
        return
    end
    self.startReq = true
    clr.coroutine(function()
        local urlData = self.transportMatchDetailsModel:GetUrlData()
        local resp = req.transportBattle(urlData.pid, urlData.sid, urlData.robberyId, urlData.ptid)
        if api.success(resp) then
            self.startReq = false
            local data = resp.val
            self.view:CloseImmediate()
            MatchLoader.startMatch(data.matchData)
        end
    end)
end

function TransportMatchDetailCtrl:OnOverChallenge()
    self.view:Close()
end

return TransportMatchDetailCtrl