local FriendsMessagesMenuType = require("ui.models.friends.FriendsMessagesMenuType")
local FriendsReceiveStrengthCtrl = require("ui.controllers.friends.FriendsReceiveStrengthCtrl")
local FriendsMatchRecordCtrl = require("ui.controllers.friends.FriendsMatchRecordCtrl")

local FriendsMessagesCtrl = class()

function FriendsMessagesCtrl:ctor(view)
    self.friendsMessagesView = view
    self.friendsReceiveStrengthCtrl = FriendsReceiveStrengthCtrl.new(res.GetLuaScript(self.friendsMessagesView:GetFriendsMessagesBoard(FriendsMessagesMenuType.RECEIVE_STRENGTH)))
    self.friendsMatchRecordCtrl = FriendsMatchRecordCtrl.new(res.GetLuaScript(self.friendsMessagesView:GetFriendsMessagesBoard(FriendsMessagesMenuType.MATCH_RECORD)))
end

function FriendsMessagesCtrl:InitView(mainModel, model)
    self.friendsMainModel = mainModel
    self.friendsMessagesModel = model
    self.friendsMessagesView.clickMenu = function(index) self:OnMenuClick(index) end
    self.friendsMessagesView:InitView(self.friendsMessagesModel)
end

function FriendsMessagesCtrl:OnMenuClick(index)
    self.friendsMessagesModel:SetCurrentMenu(index)
    if index == FriendsMessagesMenuType.RECEIVE_STRENGTH then
        self:OnFriendsReceiveStrength()
    elseif index == FriendsMessagesMenuType.MATCH_RECORD then
        self:OnFriendsMatchRecord()
    end
    self.friendsMessagesView:SwitchFriendsMessagesTab(self.friendsMessagesModel)
end

function FriendsMessagesCtrl:OnFriendsReceiveStrength()
    clr.coroutine(function()
        local respone = req.friendsIndex()
        if api.success(respone) then
            local data = respone.val
            self.friendsMainModel:SetFriendsCountAndLimit(data.friendsCount, data.friendsLimit)
            local friendsReceiveStrengthModel = self.friendsMessagesModel:GetFriendsReceiveStrengthModel()
            friendsReceiveStrengthModel:InitWithProtocol(data)
            self.friendsReceiveStrengthCtrl:InitView(friendsReceiveStrengthModel)
        end
    end)
end

function FriendsMessagesCtrl:OnFriendsMatchRecord()
    clr.coroutine(function()
        local respone = req.friendsListRecords()
        if api.success(respone) then
            local friendsMatchRecordModel = self.friendsMessagesModel:GetFriendsMatchRecordModel()
            friendsMatchRecordModel:InitWithProtocol(respone.val)
            self.friendsMatchRecordCtrl:InitView(friendsMatchRecordModel)
        end
    end)
end

function FriendsMessagesCtrl:OnEnterScene()
    self.friendsMessagesView:EnterScene()
    self.friendsReceiveStrengthCtrl:OnEnterScene()
    self.friendsMatchRecordCtrl:OnEnterScene()
end

function FriendsMessagesCtrl:OnExitScene()
    self.friendsMessagesView:ExitScene()
    self.friendsReceiveStrengthCtrl:OnExitScene()
    self.friendsMatchRecordCtrl:OnExitScene()
end

return FriendsMessagesCtrl