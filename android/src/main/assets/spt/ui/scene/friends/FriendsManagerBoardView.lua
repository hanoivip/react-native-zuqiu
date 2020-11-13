local EventSystem = require("EventSystem")

local FriendsManagerBoardView = class(unity.base)

function FriendsManagerBoardView:ctor()
    self.friendsNumber = self.___ex.friendsNumber
    self.strengthTimes = self.___ex.strengthTimes
    self.scrollView = self.___ex.scrollView
    self.sendAllButton = self.___ex.sendAllButton
    self.sendAllButtonScript = self.___ex.sendAllButtonScript
end

function FriendsManagerBoardView:start()
    self.sendAllButton:regOnButtonClick(function()
        if self.onGiftPowerAll then
            self.onGiftPowerAll()
        end
    end)
end

function FriendsManagerBoardView:InitView(mainModel, model)
    self.friendsMainModel = mainModel
    self:InitFriendsNumber(self.friendsMainModel:GetFriendsCount())
    self:InitStrengthTimes(model:GetStrengthTimes())
    self:InitSendAllBtnState(model)
end

function FriendsManagerBoardView:InitFriendsNumber(number)
    if self.friendsMainModel then
        self.friendsNumber.text = lang.trans("friends_friendsNumber", number, self.friendsMainModel:GetFriendsLimit())
    end
end

function FriendsManagerBoardView:InitStrengthTimes(times)
    self.strengthTimes.text = lang.trans("friends_manager_strengthTimes", times)
end

function FriendsManagerBoardView:EventUpdateFriendsList(index)
    if self.updateFriendsListCallBack then
        self.updateFriendsListCallBack(index)
    end
end

function FriendsManagerBoardView:EventUpdateStrengthTimes(times)
    self:InitStrengthTimes(times)
end

function FriendsManagerBoardView:InitSendAllBtnState(model)
    local state = model:GetSendAllButtonState()
    self.sendAllButtonScript.interactable = state
    self.sendAllButton:onPointEventHandle(state)
end

function FriendsManagerBoardView:EventUpdateFriendsCount(count)
    self:InitFriendsNumber(count)
end

function FriendsManagerBoardView:EnterScene()
    EventSystem.AddEvent("FriendsManagerModel_UpdateFriendsList", self, self.EventUpdateFriendsList)
    EventSystem.AddEvent("FriendsManagerModel_UpdateStrengthTimes", self, self.EventUpdateStrengthTimes)
    EventSystem.AddEvent("FriendsMainModel_UpdateFriendsCount", self, self.EventUpdateFriendsCount)
end

function FriendsManagerBoardView:ExitScene()
    EventSystem.RemoveEvent("FriendsManagerModel_UpdateFriendsList", self, self.EventUpdateFriendsList)
    EventSystem.RemoveEvent("FriendsManagerModel_UpdateStrengthTimes", self, self.EventUpdateStrengthTimes)
    EventSystem.RemoveEvent("FriendsMainModel_UpdateFriendsCount", self, self.EventUpdateFriendsCount)
end

return FriendsManagerBoardView