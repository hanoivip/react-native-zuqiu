local FriendsInviteMenuType = require("ui.models.friends.FriendsInviteMenuType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local FriendsInviteCtrl = class()

function FriendsInviteCtrl:ctor(content)
    self:Init(content)
end

function FriendsInviteCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsInvite/FriendsInvite.prefab")
    pageObject.transform:SetParent(content.transform, false)
    self.view = pageSpt
    self.view.clickMenu = function(index) self:OnMenuClick(index) end
    self.view.clickBtnRecord = function() self:OnBtnRecord() end
    self.view.clickBtnSubmit = function() self:OnBtnSubmit() end
end

function FriendsInviteCtrl:InitView(mainModel, model)
    self.friendsMainModel = mainModel
    self.friendsInviteModel = model
    self.view:InitView(self.friendsInviteModel)
end

function FriendsInviteCtrl:OnMenuClick(index)
    self.friendsInviteModel:SetCurrentMenu(index)
    self.view:SwitchFriendsInviteTab()
    if index ~= FriendsInviteMenuType.DIAMOND_RETURN then
        self:OnOtherThreeBtns()
    end
end

function FriendsInviteCtrl:OnBtnRecord()
    res.PushDialog("ui.controllers.friends.friendsInvite.FriendsInviteRecordCtrl", self.friendsInviteModel)
end

function FriendsInviteCtrl:OnBtnSubmit()
    self.view:coroutine(function()
        local code = self.view.inputCodeTxt.text
        if code == "" then
            DialogManager.ShowToast(lang.transstr("friendsInvite_desc13"))
            return
        end
        local response = req.fiCollectNewPlayerReward(code)
        if api.success(response) then
            local data = response.val
            if type(data) == "table" and next(data) then
                CongratulationsPageCtrl.new(data.contents, false)
                self.friendsInviteModel:SetNewPlayerRewardStatusCollected()
                self.view:InitNewPlayerRewardArea()
            end
        end
    end)
end

function FriendsInviteCtrl:OnOtherThreeBtns()
    self.view:RefreshRewardScroll(self.view.otherThreeScrollView, self.view.scrollItemType.other)
end

function FriendsInviteCtrl:OnEnterScene()
    self.view:EnterScene()
end

function FriendsInviteCtrl:OnExitScene()
    self.view:ExitScene()
end

return FriendsInviteCtrl
