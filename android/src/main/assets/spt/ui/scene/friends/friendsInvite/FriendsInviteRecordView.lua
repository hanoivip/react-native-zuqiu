local GameObjectHelper = require("ui.common.GameObjectHelper")
local FriendsInviteRecordItemModel = require("ui.models.friends.friendsInvite.FriendsInviteRecordItemModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local FriendsInviteRecordView = class(unity.base)

function FriendsInviteRecordView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.scrollView = self.___ex.scrollView
    self.scrollContentObj = self.___ex.scrollContentObj
    self.noRecordTipObj = self.___ex.noRecordTipObj

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function FriendsInviteRecordView:start()
end

function FriendsInviteRecordView:InitView(friendsInviteModel)
    self.friendsInviteModel = friendsInviteModel
    self:RefreshScroll()
end

function FriendsInviteRecordView:RefreshScroll()
    local recordList = self.friendsInviteModel:GetInviteRecordList()
    GameObjectHelper.FastSetActive(self.scrollContentObj, next(recordList))
    GameObjectHelper.FastSetActive(self.noRecordTipObj, not next(recordList))

    self.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsInvite/FriendsInviteRecordScrollItem.prefab")
        return obj, spt
    end
    self.scrollView.onScrollResetItem = function(spt, index)
        local itemData = self.scrollView.itemDatas[index]
        local friendsInviteRecordItemModel = FriendsInviteRecordItemModel.new(itemData)
        spt.onBtnDetailClick = function(pid, friendsInviteRecordItemModel) self:OnDetailClick(pid, friendsInviteRecordItemModel) end
        spt:InitView(friendsInviteRecordItemModel, self.friendsInviteModel)
        self.scrollView:updateItemIndex(spt, index)
    end

    self.scrollView:clearData()
    self.scrollView:refresh(recordList)
end

function FriendsInviteRecordView:OnDetailClick(pid, friendsInviteRecordItemModel)
    local sid = friendsInviteRecordItemModel:GetSid()
    if not sid then 
        local playerInfoModel = self.friendsInviteModel:GetPlayerInfoModel()
        sid = playerInfoModel:GetSID()
    end
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function FriendsInviteRecordView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return FriendsInviteRecordView