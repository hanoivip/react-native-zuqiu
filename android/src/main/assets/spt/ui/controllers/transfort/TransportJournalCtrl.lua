local BaseCtrl = require("ui.controllers.BaseCtrl")
local TransporInvitationModel = require("ui.models.transfort.TransporInvitationModel")

local TransportJournalCtrl = class(BaseCtrl)

TransportJournalCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Transfort/TransportJournal.prefab"

TransportJournalCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function TransportJournalCtrl:AheadRequest()
    local response = req.transportBattleLog()
    if api.success(response) then
        local data = response.val
        self.data = data
    end
end

function TransportJournalCtrl:Init()
    self.view:RegOnMenuGroup("match", function () self:SwitchMenu("match") end)
    self.view:RegOnMenuGroup("sign", function () self:SwitchMenu("sign") end)
    self.view:RegOnMenuGroup("protect", function () self:SwitchMenu("protect") end)
    self.view:InitView(self.data)
end

function TransportJournalCtrl:Refresh()
    TransportJournalCtrl.super.Refresh(self)
    self:SwitchMenu("match")
end

function TransportJournalCtrl:SwitchMenu(tag)
    self.view.menuTag = tag
    if tag == "match" then
        self.view:InitMatchView()
    elseif tag == "sign" then
        self.view:InitSignView()
    elseif tag == "protect" then
        self.view:InitProtectView()
    end
end

function TransportJournalCtrl:RefreshMainView()
    local response = req.transportBattleLog()
    if api.success(response) then
        local data = response.val
        self.data = data
        self.view:InitView(self.data)
        self:SwitchMenu(self.view.menuTag)
    end
end

function TransportJournalCtrl:OnEnterScene()
    EventSystem.AddEvent("Refresh_Transport_Journal_Main_View", self, self.RefreshMainView)
end

function TransportJournalCtrl:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Transport_Journal_Main_View", self, self.RefreshMainView)
end

return TransportJournalCtrl