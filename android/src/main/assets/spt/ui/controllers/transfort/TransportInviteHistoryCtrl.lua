local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransporInvitationModel = require("ui.models.transfort.TransporInvitationModel")

local TransportInviteHistoryCtrl = class(BaseCtrl)

TransportInviteHistoryCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportInviteHistory.prefab"

TransportInviteHistoryCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function TransportInviteHistoryCtrl:AheadRequest()
    local response = req.transportRequestGuardList()
    if api.success(response) then
        local data = response.val
        self.data = data
    end
end

function TransportInviteHistoryCtrl:Init()
    self.view:InitView(self.data)
end

function TransportInviteHistoryCtrl:Refresh()
    TransportInviteHistoryCtrl.super.Refresh(self)
end

function TransportInviteHistoryCtrl:RefreshMainPage()
    local response = req.transportRequestGuardList()
    if api.success(response) then
        local data = response.val
        self.data = data
        self.view:InitView(self.data)
    end
end

function TransportInviteHistoryCtrl:OnEnterScene()
    EventSystem.AddEvent("Transport_Refresh_Invitation_History", self, self.RefreshMainPage)
end

function TransportInviteHistoryCtrl:OnExitScene()
    EventSystem.RemoveEvent("Transport_Refresh_Invitation_History", self, self.RefreshMainPage)
end

return TransportInviteHistoryCtrl