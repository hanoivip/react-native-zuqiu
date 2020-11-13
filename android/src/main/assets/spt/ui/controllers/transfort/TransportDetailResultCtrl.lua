local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransportDetailResultModel = require("ui.models.transfort.TransportDetailResultModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TransportInfoBarCtrl = require("ui.controllers.transfort.TransportInfoBarCtrl")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")
local TechnologySettingConfig = require("ui.scene.court.technologyHall.TechnologySettingConfig")
local DialogManager = require("ui.control.manager.DialogManager")
local MatchLoader = require("coregame.MatchLoader")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local TransportDetailResultCtrl = class(BaseCtrl, "TransportDetailResultCtrl")

TransportDetailResultCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportDetailResult.prefab"

TransportDetailResultCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function TransportDetailResultCtrl:AheadRequest(pid, isCanChallange)
    self.pid = pid
    self.isCanChallange = isCanChallange
    local response = req.transportExpress(pid)
    if api.success(response) then
        local data = response.val
        self.transportDetailResultModel = TransportDetailResultModel.new()
        self.transportDetailResultModel:InitWithProtocol(data)
    end
end

function TransportDetailResultCtrl:Init()
    self.playerInfoModel = PlayerInfoModel.new()
    self.view.onRobberyBtnClick = function () self:OnRobberyBtnClick() end
    self.view.onDetailBtnClick = function () self:OnDetailBtnClick() end
    self.view.onProtecDetailBtnClick = function () self:OnProtectDetailBtnClick() end
end

function TransportDetailResultCtrl:OnRobberyBtnClick()
    if self.isCanChallange and not self.startChalleng then
        self.startChalleng = true
        clr.coroutine(function()
            local pid = self.transportDetailResultModel:GetPid()
            local sid = self.transportDetailResultModel:GetSid()
            cache.setTransportIds({["pid"] = pid, ["sid"] = sid})
            local response = req.transportBattle(pid, sid)
            self.startChalleng = false
            if api.success(response) then
                local data = response.val
                self.view:CloseImmediate()
                MatchLoader.startMatch(data.matchData)
            end
        end)
    else
        DialogManager.ShowToast(lang.trans("transport_robbery_nil_challenge_tip"))
    end
end

function TransportDetailResultCtrl:Refresh()
    TransportDetailResultCtrl.super.Refresh(self)
    self.view:InitView(self.transportDetailResultModel)
end

function TransportDetailResultCtrl:OnDetailBtnClick()
    self:OnViewDetail(self.transportDetailResultModel:GetPid(), self.transportDetailResultModel:GetSid())
end

function TransportDetailResultCtrl:OnProtectDetailBtnClick()
    self:OnViewDetail(self.transportDetailResultModel:GetGuardPid(), self.transportDetailResultModel:GetGuardSid())
end

function TransportDetailResultCtrl:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function TransportDetailResultCtrl:GetStatusData()
    return self.pid, self.isCanChallange
end

function TransportDetailResultCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function TransportDetailResultCtrl:OnExitScene()
    self.view:OnExitScene()
end

return TransportDetailResultCtrl