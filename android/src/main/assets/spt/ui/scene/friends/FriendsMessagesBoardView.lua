local FriendsMessagesMenuType = require("ui.models.friends.FriendsMessagesMenuType")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local EventSystem = require("EventSystem")

local FriendsMessagesBoardView = class(unity.base)

local FriendsMessagesMenuMap = {
    [FriendsMessagesMenuType.RECEIVE_STRENGTH] = "receiveStrength",
    [FriendsMessagesMenuType.MATCH_RECORD] = "matchRecord",
}

function FriendsMessagesBoardView:ctor()
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.receiveStrengthBoard = self.___ex.receiveStrengthBoard
    self.matchRecordBoard = self.___ex.matchRecordBoard
    self.receiveStrengthRedPoint = self.___ex.receiveStrengthRedPoint
    self.receiveStrengthCount = self.___ex.receiveStrengthCount
    self.matchRecordRedPoint = self.___ex.matchRecordRedPoint
    self.matchRecordCount = self.___ex.matchRecordCount
end

function FriendsMessagesBoardView:start()
    local menuTransform = self.menuButtonGroup.transform
    for i = 1, menuTransform.childCount do
        local btnObject = menuTransform:GetChild(i - 1).gameObject
        btnObject:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function()
            self:OnMenuClick(i)
        end)
    end

    self:IsShowFriendsReceiveStrengthRedPoint()
    self:IsShowFriendsMatchRecordRedPoint()
end

function FriendsMessagesBoardView:InitView(model)
    local menuType = model:GetCurrentMenu()
    self.menuButtonGroup:selectMenuItem(FriendsMessagesMenuMap[menuType])
    self:OnMenuClick(menuType)
end

function FriendsMessagesBoardView:OnMenuClick(index)
    if self.clickMenu then
        self.clickMenu(index)
    end
end

function FriendsMessagesBoardView:SwitchFriendsMessagesTab(model)
    local menuType = model:GetCurrentMenu()
    if menuType == FriendsMessagesMenuType.RECEIVE_STRENGTH then
        self:ShowOrHideFriendsMessagesBoard(true, false)
    elseif menuType == FriendsMessagesMenuType.MATCH_RECORD then
        self:ShowOrHideFriendsMessagesBoard(false, true)
    end
end

function FriendsMessagesBoardView:ShowOrHideFriendsMessagesBoard(isShowreceiveStrengthBoard, isShowMatchRecordBoard)
    self.receiveStrengthBoard:SetActive(isShowreceiveStrengthBoard)
    self.matchRecordBoard:SetActive(isShowMatchRecordBoard)
end

function FriendsMessagesBoardView:GetFriendsMessagesBoard(menuType)
    if menuType == FriendsMessagesMenuType.RECEIVE_STRENGTH then
        return self.receiveStrengthBoard
    elseif menuType == FriendsMessagesMenuType.MATCH_RECORD then
        return self.matchRecordBoard
    end
end

function FriendsMessagesBoardView:IsShowFriendsReceiveStrengthRedPoint()
    local friendsReceiveStrengthCount = ReqEventModel.GetInfo("friendSp")
    if tonumber(friendsReceiveStrengthCount) > 0 then
        -- self.receiveStrengthCount.text = friendsReceiveStrengthCount
        self.receiveStrengthRedPoint:SetActive(true)
    else
        self.receiveStrengthRedPoint:SetActive(false)
    end
end

function FriendsMessagesBoardView:IsShowFriendsMatchRecordRedPoint()
    local friendsMatchRecordCount = ReqEventModel.GetInfo("friendMatch")
    if tonumber(friendsMatchRecordCount) > 0 then
        -- self.matchRecordCount.text = friendsMatchRecordCount
        self.matchRecordRedPoint:SetActive(true)
    else
        self.matchRecordRedPoint:SetActive(false)
    end
end

function FriendsMessagesBoardView:EnterScene()
    EventSystem.AddEvent("ReqEventModel_friendSp", self, self.IsShowFriendsReceiveStrengthRedPoint)
    EventSystem.AddEvent("ReqEventModel_friendMatch", self, self.IsShowFriendsMatchRecordRedPoint)
end

function FriendsMessagesBoardView:ExitScene()
    EventSystem.RemoveEvent("ReqEventModel_friendSp", self, self.IsShowFriendsReceiveStrengthRedPoint)
    EventSystem.RemoveEvent("ReqEventModel_friendMatch", self, self.IsShowFriendsMatchRecordRedPoint)
end

return FriendsMessagesBoardView
