local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local FriendsApplyCtrl = require("ui.controllers.friends.FriendsApplyCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local FriendsAddCtrl = class()

function FriendsAddCtrl:ctor(view)
    self.friendsAddView = view
end

function FriendsAddCtrl:InitView(mainModel, model)
    self.friendsMainModel = mainModel
    self.friendsAddModel = model
    self.friendsAddView:InitView(self.friendsMainModel)
    self.friendsAddView.onSearch = function(inputText, inputTexSid) self:OnSearch(inputText, inputTexSid) end
    self.friendsAddView.onRefresh = function() self:OnRefresh() end
    self.friendsAddView.onApply = function() self:OnApply() end
    self.friendsAddView.onAddAll = function() self:OnAddFriend(self.friendsAddModel:GetPidList()) end
    self.friendsAddView.updateSearchListCallBack = function() self:UpdateSearchListCallBack() end
    self:CreateItemList()
end

function FriendsAddCtrl:CreateItemList()
    self.friendsAddView.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsAddItem.prefab")
        return obj, spt
    end
    self.friendsAddView.scrollView.onScrollResetItem = function(spt, index)
        local searchData = self.friendsAddView.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogoGameObject(), searchData.logo) end
        spt.onViewDetail = function() self:OnViewDetail(searchData.pid, searchData.sid) end
        local pidTable = {{sid = tostring(searchData.sid), pid = searchData.pid }}
        spt.onAddFriend = function() self:OnAddFriend(pidTable) end
        spt:InitView(searchData)
        self.friendsAddView.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function FriendsAddCtrl:RefreshScrollView()
    local searchList = self.friendsAddModel:GetSearchList()
    self.friendsAddView.scrollView:clearData()
    for i = 1, #searchList do
        table.insert(self.friendsAddView.scrollView.itemDatas, searchList[i])
    end
    self.friendsAddView.scrollView:refresh()
end

function FriendsAddCtrl:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function FriendsAddCtrl:OnAddFriend(pidTable)
    clr.coroutine(function()
        local respone = req.friendsRequest({pidArray = pidTable})
        if api.success(respone) then
            local data = respone.val
            if data["ok"] then
                DialogManager.ShowToastByLang("friends_applySendHint")
            end
        end
    end)
end

function FriendsAddCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function FriendsAddCtrl:OnSearch(inputText, inputTexSid)
    clr.coroutine(function()
        if not inputTexSid or string.len(inputTexSid) < 1  then
            inputTexSid = PlayerInfoModel.new():GetSID()
        end
        local respone = req.friendsFind(inputText, inputTexSid)
        if api.success(respone) then
            local data = respone.val
            if data then
                if data.list then
                    self.friendsAddModel:UpdateSearchList(data.list)
                end
                if data.count > 30 then
                    DialogManager.ShowAlertPopByLang("tips", "friends_add_search_hint")
                end
            end
        end
    end)
end

function FriendsAddCtrl:OnRefresh()
    clr.coroutine(function()
        local respone = req.friendsFind("", PlayerInfoModel.new():GetSID())
        if api.success(respone) then
            local data = respone.val
            if data and data.list then
                self.friendsAddModel:UpdateSearchList(data.list)
            end
        end
    end)
end

function FriendsAddCtrl:OnApply()
    FriendsApplyCtrl.new(self.friendsMainModel)
end

function FriendsAddCtrl:UpdateSearchListCallBack()
    self:RefreshScrollView()
end

function FriendsAddCtrl:OnEnterScene()
    self.friendsAddView:EnterScene()
end

function FriendsAddCtrl:OnExitScene()
    self.friendsAddView:ExitScene()
end

return FriendsAddCtrl