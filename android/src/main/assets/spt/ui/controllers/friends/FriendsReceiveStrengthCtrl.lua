local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local FriendsReceiveStrengthCtrl = class()

function FriendsReceiveStrengthCtrl:ctor(view)
    self.friendsReceiveStrengthView = view
end

function FriendsReceiveStrengthCtrl:InitView(model)
    self.friendsReceiveStrengthModel = model
    self.friendsReceiveStrengthView.onReceiveAll = function() self:OnReceiveAll() end
    self.friendsReceiveStrengthView.updateFriendsListCallBack = function() self:UpdateFriendsListCallBack() end
    self.friendsReceiveStrengthView:InitView(model)
    self:CreateItemList()
    self:SetReceiveAllBtnState()
end

function FriendsReceiveStrengthCtrl:CreateItemList()
    self.friendsReceiveStrengthView.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsReceiveStrengthItem.prefab")
        return obj, spt
    end
    self.friendsReceiveStrengthView.scrollView.onScrollResetItem = function(spt, index)
        local friendData = self.friendsReceiveStrengthView.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogoGameObject(), friendData.logo) end
        spt.onReceiveStrength = function() self:OnReceiveStrength(friendData.strengthId) end
        spt:InitView(friendData)
        self.friendsReceiveStrengthView.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function FriendsReceiveStrengthCtrl:RefreshScrollView()
    local friendsList = self.friendsReceiveStrengthModel:GetFriendsList()
    self.friendsReceiveStrengthView.scrollView:clearData()
    for i = 1, #friendsList do
        table.insert(self.friendsReceiveStrengthView.scrollView.itemDatas, friendsList[i])
    end
    self.friendsReceiveStrengthView.scrollView:refresh()
end

function FriendsReceiveStrengthCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function FriendsReceiveStrengthCtrl:OnReceiveStrength(strengthId)
    clr.coroutine(function()
        local respone = req.friendsReceiveSp(0, strengthId)
        if api.success(respone) then
            local data = respone.val
            DialogManager.ShowToastByLang("friends_receive_strength_success")
            self.friendsReceiveStrengthModel:UpdateFriendsList(data.received)
            self:SetReceiveAllBtnState()
            self.friendsReceiveStrengthView:InitReceiveNum(data.limit)
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:AddStrength(data.contents.sp or 0)
        end
    end)
end

function FriendsReceiveStrengthCtrl:OnReceiveAll()
    clr.coroutine(function()
        local respone = req.friendsReceiveSp(1, nil)
        if api.success(respone) then
            local data = respone.val
            DialogManager.ShowToastByLang("friends_receive_strength_success")
            self.friendsReceiveStrengthModel:UpdateFriendsList(data.received)
            self:SetReceiveAllBtnState()
            self.friendsReceiveStrengthView:InitReceiveNum(data.limit)
            local playerInfoModel = PlayerInfoModel.new()
            playerInfoModel:AddStrength(data.sp or 0)
        end
    end)
end

function FriendsReceiveStrengthCtrl:UpdateFriendsListCallBack()
    self:RefreshScrollView()
end

function FriendsReceiveStrengthCtrl:SetReceiveAllBtnState()
    local friendsList = self.friendsReceiveStrengthModel:GetFriendsList()
    if #friendsList > 0 then
        self.friendsReceiveStrengthView:SetReceiveAllBtnState(true)
    else
        self.friendsReceiveStrengthView:SetReceiveAllBtnState(false)
    end
end

function FriendsReceiveStrengthCtrl:OnEnterScene()
    self.friendsReceiveStrengthView:EnterScene()
end

function FriendsReceiveStrengthCtrl:OnExitScene()
    self.friendsReceiveStrengthView:ExitScene()
end

return FriendsReceiveStrengthCtrl