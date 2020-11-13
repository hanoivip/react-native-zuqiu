local BaseCtrl = require("ui.controllers.BaseCtrl")
local FriendsInviteRecordCtrl = class(BaseCtrl, "FriendsInviteRecordCtrl")

FriendsInviteRecordCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

FriendsInviteRecordCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsInvite/FriendsInviteRecord.prefab"

function FriendsInviteRecordCtrl:ctor()
end

function FriendsInviteRecordCtrl:Init(friendsInviteModel)
    self.friendsInviteModel = friendsInviteModel
    self.view:InitView(self.friendsInviteModel)
end

function FriendsInviteRecordCtrl:GetStatusData()
    return self.friendsInviteModel
end

function FriendsInviteRecordCtrl:OnEnterScene()
end

function FriendsInviteRecordCtrl:OnExitScene()
end

return FriendsInviteRecordCtrl