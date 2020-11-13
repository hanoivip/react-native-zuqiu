local EventSystem = require("EventSystem")
local ReqEventModel = require("ui.models.event.ReqEventModel")
local EventSystem = require("EventSystem")

local FriendsAddBoardView = class(unity.base)

function FriendsAddBoardView:ctor()
    self.btnSearch = self.___ex.btnSearch
    self.btnRefresh = self.___ex.btnRefresh
    self.btnApply = self.___ex.btnApply
    self.btnAddAll = self.___ex.btnAddAll
    self.searchKeyWord = self.___ex.searchKeyWord
    self.friendsNumber = self.___ex.friendsNumber
    self.friendsApplyCount = self.___ex.friendsApplyCount
    self.friendsApplyRedPoint = self.___ex.friendsApplyRedPoint
    self.scrollView = self.___ex.scrollView
    self.searchSidWord = self.___ex.searchSidWord
end

function FriendsAddBoardView:start()
    self.searchSidWord.onValueChanged:AddListener(function(value)
        self:CtrlWorldInput(value)
    end)
    self.btnSearch:regOnButtonClick(function()
        if self.onSearch then
            self.onSearch(self.searchKeyWord.text, self.searchSidWord.text)
        end
    end)
    self.btnRefresh:regOnButtonClick(function()
        if self.onRefresh then
            self.searchSidWord.text = ""
            self.searchSidWord.text = ""
            self.onRefresh()
        end
    end)
    self.btnApply:regOnButtonClick(function()
        if self.onApply then
            self.onApply()
        end
    end)
    self.btnAddAll:regOnButtonClick(function()
        if self.onAddAll then
            self.onAddAll()
        end
    end)

    self:IsShowFriendsApplyRedPoint()
end

function FriendsAddBoardView:CtrlWorldInput(text)
    local strLen = string.len(text)
    if strLen <= 0 then
        return
    end
    local num = tonumber(string.sub(text, -1))
    if string.sub(text, -1) ~= "0" and num == 0 then
        self.searchSidWord.text = string.sub(text, 1, strLen - 1)
    end
end

function FriendsAddBoardView:InitView(mainModel)
    self.friendsMainModel = mainModel
    self.friendsNumber.text = lang.trans("friends_friendsNumber", self.friendsMainModel:GetFriendsCount(), self.friendsMainModel:GetFriendsLimit())
end

function FriendsAddBoardView:EventUpdateSearchList()
    if self.updateSearchListCallBack then
        self.updateSearchListCallBack()
    end
end

function FriendsAddBoardView:EventUpdateFriendsCount(count)
    if self.friendsMainModel then
        self.friendsNumber.text = lang.trans("friends_friendsNumber", count, self.friendsMainModel:GetFriendsLimit())
    end
end

function FriendsAddBoardView:IsShowFriendsApplyRedPoint()
    local friendsApplyCount = ReqEventModel.GetInfo("friendReq")
    if tonumber(friendsApplyCount) > 0 then
        self.friendsApplyCount.text = tonumber(friendsApplyCount)
        self.friendsApplyRedPoint:SetActive(true)
    else
        self.friendsApplyRedPoint:SetActive(false)
    end
end

function FriendsAddBoardView:EnterScene()
    EventSystem.AddEvent("FriendsAddModel_UpdateSearchList", self, self.EventUpdateSearchList)
    EventSystem.AddEvent("FriendsMainModel_UpdateFriendsCount", self, self.EventUpdateFriendsCount)

    EventSystem.AddEvent("ReqEventModel_friendReq", self, self.IsShowFriendsApplyRedPoint)
end

function FriendsAddBoardView:ExitScene()
    EventSystem.RemoveEvent("FriendsAddModel_UpdateSearchList", self, self.EventUpdateSearchList)
    EventSystem.RemoveEvent("FriendsMainModel_UpdateFriendsCount", self, self.EventUpdateFriendsCount)
    EventSystem.RemoveEvent("ReqEventModel_friendReq", self, self.IsShowFriendsApplyRedPoint)
end

return FriendsAddBoardView
