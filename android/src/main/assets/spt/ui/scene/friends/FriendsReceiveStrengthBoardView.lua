local EventSystem = require("EventSystem")

local FriendsReceiveStrengthBoardView = class(unity.base)

function FriendsReceiveStrengthBoardView:ctor()
    self.btnReceiveAll = self.___ex.btnReceiveAll
    self.receiveAllButton = self.___ex.receiveAllButton
    self.scrollView = self.___ex.scrollView
    self.strengthLimit = self.___ex.strengthLimit
end

function FriendsReceiveStrengthBoardView:start()
    self.btnReceiveAll:regOnButtonClick(function()
        if self.onReceiveAll then
            self.onReceiveAll()
        end
    end)
end

function FriendsReceiveStrengthBoardView:InitView(friendsReceiveStrengthModel)
    self:InitReceiveNum(friendsReceiveStrengthModel:GetReceiveLimit())
end

function FriendsReceiveStrengthBoardView:SetReceiveAllBtnState(isEnable)
    self.receiveAllButton.interactable = isEnable
    self.btnReceiveAll:onPointEventHandle(isEnable)
end

function FriendsReceiveStrengthBoardView:EventUpdateFriendsList()
    if self.updateFriendsListCallBack then
        self.updateFriendsListCallBack()
    end
end

function FriendsReceiveStrengthBoardView:InitReceiveNum(strengthCount)
    self.strengthLimit.text = lang.trans("friends_receieve_times",tostring(strengthCount) .. "/" .. "30")
end

function FriendsReceiveStrengthBoardView:EnterScene()
    EventSystem.AddEvent("FriendsReceiveStrengthModel_UpdateFriendsList", self, self.EventUpdateFriendsList)
end

function FriendsReceiveStrengthBoardView:ExitScene()
    EventSystem.RemoveEvent("FriendsReceiveStrengthModel_UpdateFriendsList", self, self.EventUpdateFriendsList)
end

return FriendsReceiveStrengthBoardView