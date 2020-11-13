local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransporInvitationModel = require("ui.models.transfort.TransporInvitationModel")
local DialogManager = require("ui.control.manager.DialogManager")
local TransporInvitationType = require("ui.models.transfort.TransporInvitationType")

local TransportInvitationCtrl = class(BaseCtrl)

TransportInvitationCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportInvitation.prefab"

TransportInvitationCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}


function TransportInvitationCtrl:AheadRequest()
    local response = req.transportGuardList()
    if api.success(response) then
        local data = response.val
        self.transporInvitationModel = TransporInvitationModel.new()
        self.transporInvitationModel:InitWithProtocol(data)
    end
end

function TransportInvitationCtrl:Init()
    self.view:RegOnMenuGroup(TransporInvitationType.GUILDMEMBERS, function () self:SwitchMenu(TransporInvitationType.GUILDMEMBERS) end)
    self.view:RegOnMenuGroup(TransporInvitationType.FRIENDS, function () self:SwitchMenu(TransporInvitationType.FRIENDS) end)
    self.view.onInviteAllBtnClick = function () self:OnInviteAllBtnClick() end
    self.view.onInviteBestBtnClick = function () self:OnInviteBestBtnClick() end
    self.view:InitView(self.transporInvitationModel)
end

function TransportInvitationCtrl:Refresh()
    TransportInvitationCtrl.super.Refresh(self)
    self:SwitchMenu(TransporInvitationType.FRIENDS)
end

function TransportInvitationCtrl:OnInviteAllBtnClick()
    local info = self.transporInvitationModel:GeAllPlayerPidList()
    if not next(info) then
        local menuType  = self.transporInvitationModel:GetMenuType()
        local tipInfo
        if menuType == TransporInvitationType.FRIENDS then
            tipInfo = lang.trans("transport_invitation_tip")
        else
            tipInfo = lang.trans("transport_invitation_tip_1")
        end
        DialogManager.ShowToast(tipInfo)
        return
    end
    clr.coroutine(function ()
        local response = req.transportGuardApply(info)
        if api.success(response) then
            DialogManager.ShowToastByLang("transport_key_invite_finish")
            EventSystem.SendEvent("Refresh_Transport_Invitation_Main_View")
        end
    end)
end

function TransportInvitationCtrl:OnInviteBestBtnClick()
    local info = self.transporInvitationModel:GetHigherPlayerList()
    if not next(info) then
        local menuType  = self.transporInvitationModel:GetMenuType()
        local tipInfo
        if menuType == TransporInvitationType.FRIENDS then
            tipInfo = lang.trans("transport_invitation_tip_2")
        else
            tipInfo = lang.trans("transport_invitation_tip_3")
        end
        DialogManager.ShowToast(tipInfo)
        return
    end
    clr.coroutine(function ()
        local response = req.transportGuardApply(info)
        if api.success(response) then
            DialogManager.ShowToastByLang("transport_key_invite_finish")
            EventSystem.SendEvent("Refresh_Transport_Invitation_Main_View")
        end
    end)
end

function TransportInvitationCtrl:RefreshMainView()
    clr.coroutine(function ()
        local response = req.transportGuardList()
        if api.success(response) then
            local data = response.val
            self.transporInvitationModel:InitWithProtocol(data)
            self.view:InitView(self.transporInvitationModel)
            self:SwitchMenu(self.transporInvitationModel:GetMenuType())
        end
    end)
end

function TransportInvitationCtrl:SwitchMenu(tag)
    if tag == TransporInvitationType.GUILDMEMBERS then
        self.transporInvitationModel:SetMenuType(TransporInvitationType.GUILDMEMBERS)
        self.view:InitGuildView()
    elseif tag == TransporInvitationType.FRIENDS then
        self.transporInvitationModel:SetMenuType(TransporInvitationType.FRIENDS)
        self.view:InitFriendsView()
    end
end

function TransportInvitationCtrl:OnEnterScene()
    EventSystem.AddEvent("Refresh_Transport_Invitation_Main_View", self, self.RefreshMainView)
end

function TransportInvitationCtrl:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Transport_Invitation_Main_View", self, self.RefreshMainView)
end

return TransportInvitationCtrl