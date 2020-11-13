local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local DialogManager = require("ui.control.manager.DialogManager")

local FriendsManagerCtrl = class()

function FriendsManagerCtrl:ctor(view)
    self.friendsManagerView = view
end

function FriendsManagerCtrl:InitView(mainModel, model)
    self.friendsMainModel = mainModel
    self.friendsManagerModel = model
    self.friendsManagerView:InitView(self.friendsMainModel, self.friendsManagerModel)
    self.friendsManagerView.updateFriendsListCallBack = function(index) self:UpdateFriendsListCallBack(index) end
    self.friendsManagerView.onGiftPowerAll = function() self:OnGiftPowerAll() end
    self:CreateItemList()
end

function FriendsManagerCtrl:CreateItemList()
    self.friendsManagerView.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsManagerItem.prefab")
        return obj, spt
    end
    self.friendsManagerView.scrollView.onScrollResetItem = function(spt, index)
        local friendData = self.friendsManagerView.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogoGameObject(), friendData.logo) end
        spt.onGiftPower = function() self:OnGiftPower(friendData.pid, friendData.sid, function() spt:SetGiftPowerBtnState(false) end) end
        spt.onViewDetail = function() self:OnViewDetail(friendData.pid, friendData.sid) end
        spt.deleteFriendCallback = function(pid) self:OnDeleteFriend(pid) end
        spt:InitView(friendData)
        self.friendsManagerView.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function FriendsManagerCtrl:RefreshScrollView()
    local friendsList = self.friendsManagerModel:GetFriendsList()
    self.friendsManagerView.scrollView:clearData()
    for i = 1, #friendsList do
        table.insert(self.friendsManagerView.scrollView.itemDatas, friendsList[i])
    end
    self.friendsManagerView.scrollView:refresh()
end

function FriendsManagerCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function FriendsManagerCtrl:OnGiftPower(pid, sid, callBackFunc)
    clr.coroutine(function()
        local respone = req.friendsDonateSp(pid, sid)
        if api.success(respone) then
            local data = respone.val
            -- TODO:恭喜获得弹板，更新获得的友情点
            DialogManager.ShowToastByLang("friends_send_strength_success")
            local playerInfoModel = PlayerInfoModel.new()
            local friendshipPoint = playerInfoModel:GetFriendshipPoint()
            playerInfoModel:SetFriendshipPoint(friendshipPoint + data.contents.fp)
            self.friendsManagerModel:UpdateStrengthTimes(data.limit)
            self.friendsManagerModel:RefreshDataWithPids(pid)
            if callBackFunc and type(callBackFunc) == "function" then
                callBackFunc()
            end
        end
    end)
end

function FriendsManagerCtrl:OnGiftPowerAll()
    clr.coroutine(function()
        local respone = req.friendsDonateSpAll()
        if api.success(respone) then
            local data = respone.val
            DialogManager.ShowToastByLang("friends_send_strength_success")
            local playerInfoModel = PlayerInfoModel.new()
            local friendshipPoint = playerInfoModel:GetFriendshipPoint()
            if data.contents.fp then
                playerInfoModel:SetFriendshipPoint(friendshipPoint + data.contents.fp)
            end
            self.friendsManagerModel:UpdateStrengthTimes(data.limit)
            self.friendsManagerModel:RefreshDataWithPids(data.pids)
            self:RefreshScrollView()
            self.friendsManagerView:InitSendAllBtnState(self.friendsManagerModel)
        end
    end)
end

function FriendsManagerCtrl:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid, nil, nil, self.friendsManagerModel)
end

function FriendsManagerCtrl:UpdateFriendsListCallBack(index)
    if index then
        self.friendsManagerView.scrollView:removeItem(index)
        self.friendsMainModel:UpdateFriendsCount(self.friendsManagerModel:GetFriendsNumber())
    end
end

function FriendsManagerCtrl:OnEnterScene()
    self.friendsManagerView:EnterScene()
end

function FriendsManagerCtrl:OnExitScene()
    self.friendsManagerView:ExitScene()
end

return FriendsManagerCtrl