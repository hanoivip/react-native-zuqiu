local EventSystem = require("EventSystem")

local FriendsMatchRecordBoardView = class(unity.base)

function FriendsMatchRecordBoardView:ctor()
    self.btnDeleteAll = self.___ex.btnDeleteAll
    self.deleteAllButton = self.___ex.deleteAllButton
    self.scrollView = self.___ex.scrollView
end

function FriendsMatchRecordBoardView:start()
    self.btnDeleteAll:regOnButtonClick(function()
        if self.onDeleteAll then
            self.onDeleteAll()
        end
    end)
end

function FriendsMatchRecordBoardView:EventUpdateMatchRecordsList()
    if self.updateMatchRecordsListCallBack then
        self.updateMatchRecordsListCallBack()
    end
end

function FriendsMatchRecordBoardView:SetDeleteAllBtnState(isEnable)
    self.deleteAllButton.interactable = isEnable
    self.btnDeleteAll:onPointEventHandle(isEnable)
end

function FriendsMatchRecordBoardView:EnterScene()
    EventSystem.AddEvent("FriendsMatchRecordModel_UpdateMatchRecordsList", self, self.EventUpdateMatchRecordsList)
end

function FriendsMatchRecordBoardView:ExitScene()
    EventSystem.RemoveEvent("FriendsMatchRecordModel_UpdateMatchRecordsList", self, self.EventUpdateMatchRecordsList)
end

return FriendsMatchRecordBoardView