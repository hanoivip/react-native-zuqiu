local MenuType = require("ui.models.friends.MenuType")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require("EventSystem")

local FriendsMainView = class(unity.base)

local MenuMap = {
    [MenuType.MESSAGES] = "messages",
    [MenuType.MANAGER] = "manager",
    [MenuType.ADD] = "add",
    [MenuType.INVITE] = "invite",
}

function FriendsMainView:ctor()
    self.infoBarDynParent = self.___ex.infoBar
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.friendsManagerBoard = self.___ex.friendsManagerBoard
    self.friendsMessagesBoard = self.___ex.friendsMessagesBoard
    self.friendsAddBoard = self.___ex.friendsAddBoard
    self.friendsInviteBoard = self.___ex.friendsInviteBoard
    self.friendsMessagesRedPoint = self.___ex.friendsMessagesRedPoint
    self.friendsAddRedPoint = self.___ex.friendsAddRedPoint
    self.friendsManagerRedPoint = self.___ex.friendsManagerRedPoint
    self.friendsInviteRedPoint = self.___ex.friendsInviteRedPoint
    self.friendshipNmuber = self.___ex.friendshipNmuber
    self.friendsAnim = self.___ex.friendsAnim
    self.btnGacha = self.___ex.btnGacha
end

function FriendsMainView:start()
    local menuTransform = self.menuButtonGroup.transform
    if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN") then
        local friendsInviteBtnObj = self.menuButtonGroup.menu[MenuMap[MenuType.INVITE]].gameObject
        GameObjectHelper.FastSetActive(friendsInviteBtnObj, false)
    end

    for i = 1, menuTransform.childCount do
        local btnObject = menuTransform:GetChild(i - 1).gameObject
        btnObject:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function()
            self:OnMenuClick(i)
        end)
    end

    self.btnGacha:regOnButtonClick(function()
        if self.clickGacha then
            self.clickGacha()
        end
    end)

    self:IsShowFriendsAddRedPoint()
    self:IsShowFriendsMessagesRedPoint()
    self:IsShowManagerRedPoint()
    self:IsShowFriendsInviteRedPoint()
end

function FriendsMainView:InitView(model)
    local playerInfoModel = PlayerInfoModel.new()
    self.friendshipNmuber.text = "x" .. tostring(playerInfoModel:GetFriendshipPoint())
    local menuType = model:GetCurrentMenu()
    self.menuButtonGroup:selectMenuItem(MenuMap[menuType])
    self:OnMenuClick(menuType)
end

function FriendsMainView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function FriendsMainView:OnMenuClick(index)
    if self.clickMenu then
        self.clickMenu(index)
    end
end

function FriendsMainView:SwitchFriendsTab(model)
    local menuType = model:GetCurrentMenu()
    if menuType == MenuType.MESSAGES then
        self:ShowOrHideFriendsBoard(true, false, false, false)
    elseif menuType == MenuType.MANAGER then
        self:ShowOrHideFriendsBoard(false, true, false, false)
    elseif menuType == MenuType.ADD then
        self:ShowOrHideFriendsBoard(false, false, true, false)
    elseif menuType == MenuType.INVITE then
        self:ShowOrHideFriendsBoard(false, false, false, true)
    end
end

function FriendsMainView:ShowOrHideFriendsBoard(isShowMessageBoard, isShowManagerBoard, isShowAddBoard, isShowInviteBoard)
    self.friendsMessagesBoard:SetActive(isShowMessageBoard)
    self.friendsManagerBoard:SetActive(isShowManagerBoard)
    self.friendsAddBoard:SetActive(isShowAddBoard)
    self.friendsInviteBoard:SetActive(isShowInviteBoard)
end

function FriendsMainView:GetFriendsBoard(menuType)
    if menuType == MenuType.MESSAGES then
        return self.friendsMessagesBoard
    elseif menuType == MenuType.MANAGER then
        return self.friendsManagerBoard
    elseif menuType == MenuType.ADD then
        return self.friendsAddBoard
    elseif menuType == MenuType.INVITE then
        return self.friendsInviteBoard
    end
end

function FriendsMainView:IsShowFriendsAddRedPoint()
    local friendsApplyCount = ReqEventModel.GetInfo("friendReq")
    if tonumber(friendsApplyCount) > 0 then
        self.friendsAddRedPoint:SetActive(true)
    else
        self.friendsAddRedPoint:SetActive(false)
    end
end

function FriendsMainView:IsShowFriendsMessagesRedPoint()
    local friendsReceiveStrengthCount = ReqEventModel.GetInfo("friendSp")
    local friendsMatchRecordCount = ReqEventModel.GetInfo("friendMatch")
    if tonumber(friendsReceiveStrengthCount) > 0 or tonumber(friendsMatchRecordCount) > 0 then
        self.friendsMessagesRedPoint:SetActive(true)
    else
        self.friendsMessagesRedPoint:SetActive(false)
    end
end

function FriendsMainView:IsShowManagerRedPoint()
    local acpCount = ReqEventModel.GetInfo("friendAcp")
    GameObjectHelper.FastSetActive(self.friendsManagerRedPoint, tonumber(acpCount) > 0)
end

function FriendsMainView:IsShowFriendsInviteRedPoint()
    local isShowRedPoint = ReqEventModel.GetInfo("friendInvite")
    GameObjectHelper.FastSetActive(self.friendsInviteRedPoint, tonumber(isShowRedPoint) > 0)
end

function FriendsMainView:OnPlayerInfoChanged(playerInfoModel)
    self.friendshipNmuber.text = "x" .. tostring(playerInfoModel:GetFriendshipPoint())
    self.friendsAnim:Play("FriendPointChanged")
end

function FriendsMainView:EnterScene()
    EventSystem.AddEvent("ReqEventModel_friendReq", self, self.IsShowFriendsAddRedPoint)
    EventSystem.AddEvent("ReqEventModel_friendSp", self, self.IsShowFriendsMessagesRedPoint)
    EventSystem.AddEvent("ReqEventModel_friendMatch", self, self.IsShowFriendsMessagesRedPoint)
    EventSystem.AddEvent("ReqEventModel_friendAcp", self, self.IsShowManagerRedPoint)
    EventSystem.AddEvent("ReqEventModel_friendInvite", self, self.IsShowFriendsInviteRedPoint)
    EventSystem.AddEvent("FriendsShipChanged", self, self.OnPlayerInfoChanged)
end

function FriendsMainView:ExitScene()
    EventSystem.RemoveEvent("ReqEventModel_friendReq", self, self.IsShowFriendsAddRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_friendSp", self, self.IsShowFriendsMessagesRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_friendMatch", self, self.IsShowFriendsMessagesRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_friendAcp", self, self.IsShowManagerRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_friendInvite", self, self.IsShowFriendsInviteRedPoint)
    EventSystem.RemoveEvent("FriendsShipChanged", self, self.OnPlayerInfoChanged)
end

return FriendsMainView
