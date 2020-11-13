local FriendsApplyModel = require("ui.models.friends.FriendsApplyModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")

local FriendsApplyCtrl = class()

function FriendsApplyCtrl:ctor(mainModel)
    self.friendsMainModel = mainModel
    clr.coroutine(function()
        local respone = req.friendsListRequest()
        if api.success(respone) then
            local data = respone.val
            self.friendsApplyModel = FriendsApplyModel.new()
            self.friendsApplyModel:InitWithProtocol(data)
            local friendsApplyBoard, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsApplyBoard.prefab", "camera", true, true)
            self.friendsApplyBoardView = dialogcomp.contentcomp
            self:InitView()
        end
    end)
end

function FriendsApplyCtrl:InitView()
    self.friendsApplyBoardView.updateApplicantsListCallBack = function() self:UpdateApplicantsListCallBack() end
    self:CreateItemList()
end

function FriendsApplyCtrl:CreateItemList()
    self.friendsApplyBoardView.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsApplyItem.prefab")
        return obj, spt
    end
    self.friendsApplyBoardView.scrollView.onScrollResetItem = function(spt, index)
        local applicantData = self.friendsApplyBoardView.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogoGameObject(), applicantData.logo) end
        spt.onAgree = function() self:OnAgree(applicantData.pid, applicantData.sid) end
        spt.onRefuse = function() self:OnRefuse(applicantData.pid, applicantData.sid) end
        spt.onViewDetail = function() self:OnViewDetail(applicantData.pid, applicantData.sid) end
        spt:InitView(applicantData)
        self.friendsApplyBoardView.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function FriendsApplyCtrl:RefreshScrollView()
    local applicantsList = self.friendsApplyModel:GetApplicantsList()
    self.friendsApplyBoardView.scrollView:clearData()
    for i = 1, #applicantsList do
        table.insert(self.friendsApplyBoardView.scrollView.itemDatas, applicantsList[i])
    end
    self.friendsApplyBoardView.scrollView:refresh()
end

function FriendsApplyCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function FriendsApplyCtrl:OnAgree(pid, sid)
    clr.coroutine(function()
        local respone = req.friendsAccept(pid, sid)
        if api.success(respone) then
            local data = respone.val
            local newFriendPid = nil
            for k, v in pairs(data) do
                newFriendPid = k
            end
            self.friendsApplyModel:UpdateApplicantsList(newFriendPid)
            self.friendsMainModel:AddOneFriend()
            local playerInfoModel = PlayerInfoModel.new()
            local friendNum = playerInfoModel:GetFriendsCount() + 1
            playerInfoModel:SetFriendsCount(friendNum)
            DialogManager.ShowToastByLang("friends_add_success")
        end
    end)
end

function FriendsApplyCtrl:OnRefuse(pid, sid)
    clr.coroutine(function()
        local respone = req.friendsReject(pid, sid)
        if api.success(respone) then
            local data = respone.val
            self.friendsApplyModel:UpdateApplicantsList(data[1])
        end
    end)
end

function FriendsApplyCtrl:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function FriendsApplyCtrl:UpdateApplicantsListCallBack()
    self:RefreshScrollView()
end

return FriendsApplyCtrl