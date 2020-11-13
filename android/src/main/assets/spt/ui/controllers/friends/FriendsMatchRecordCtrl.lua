local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")

local FriendsMatchRecordCtrl = class()

function FriendsMatchRecordCtrl:ctor(view)
    self.friendsMatchRecordView = view
end

function FriendsMatchRecordCtrl:InitView(model)
    self.friendsMatchRecordModel = model
    self.playerInfoModel = PlayerInfoModel.new()
    self.friendsMatchRecordView.onDeleteAll = function() self:OnDeleteAll() end
    self.friendsMatchRecordView.updateMatchRecordsListCallBack = function() self:UpdateMatchRecordsListCallBack() end
    self:CreateItemList()
    self:SetDeleteAllBtnState()
end

function FriendsMatchRecordCtrl:CreateItemList()
    self.friendsMatchRecordView.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Friends/FriendsMatchRecordItem.prefab")
        return obj, spt
    end
    self.friendsMatchRecordView.scrollView.onScrollResetItem = function(spt, index)
        local matchRecordData = self.friendsMatchRecordView.scrollView.itemDatas[index]
        spt.onDeleteRecord = function() self:OnDeleteRecord(matchRecordData.id) end
        spt.onView = function() self:OnView(matchRecordData.vid) end
        local homeTeamLogoData = nil
        local awayTeamLogoData = nil
        -- 玩家是主场
        if matchRecordData.home == 1 then
            spt.onViewDetailLeft = function() self:OnViewPlayerDetail() end
            spt.onViewDetailRight = function() self:OnViewDetail(matchRecordData.opponent.pid, matchRecordData.opponent.sid) end
            homeTeamLogoData = self.playerInfoModel:GetTeamLogo()
            awayTeamLogoData = matchRecordData.opponent.logo
        -- 玩家是客场
        else
            spt.onViewDetailRight = function() self:OnViewPlayerDetail() end
            spt.onViewDetailLeft = function() self:OnViewDetail(matchRecordData.opponent.pid, matchRecordData.opponent.sid) end
            awayTeamLogoData = self.playerInfoModel:GetTeamLogo()
            homeTeamLogoData = matchRecordData.opponent.logo
        end
        spt.onInitHomePlayerTeamLogo = function() self:OnInitPlayerTeamLogo(spt:GetHomePlayerTeamLogoGameObject(), homeTeamLogoData) end
        spt.onInitAwayPlayerTeamLogo = function() self:OnInitPlayerTeamLogo(spt:GetAwayPlayerTeamLogoGameObject(), awayTeamLogoData) end
        spt:InitView(matchRecordData)
        self.friendsMatchRecordView.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function FriendsMatchRecordCtrl:RefreshScrollView()
    local matchRecordsList = self.friendsMatchRecordModel:GetMatchRecordsList()
    self.friendsMatchRecordView.scrollView:clearData()
    for i = 1, #matchRecordsList do
        table.insert(self.friendsMatchRecordView.scrollView.itemDatas, matchRecordsList[i])
    end
    self.friendsMatchRecordView.scrollView:refresh()
end

function FriendsMatchRecordCtrl:OnDeleteAll()
    clr.coroutine(function()
        local respone = req.friendsDelRecord(1, nil)
        if api.success(respone) then
            local data = respone.val
            self.friendsMatchRecordModel:UpdateMatchRecordsList(data)
            self:SetDeleteAllBtnState()
        end
    end)
end

function FriendsMatchRecordCtrl:OnView(vid)
    clr.coroutine(function()
        local respone = req.friendsVideo(vid)
        if api.success(respone) then
            local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
            ReplayCheckHelper.StartReplay(respone.val, vid)
        end
    end)
end

function FriendsMatchRecordCtrl:OnViewDetail(pid, sid)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function FriendsMatchRecordCtrl:OnViewPlayerDetail()
    --TODO:打开玩家个人信息界面
end

function FriendsMatchRecordCtrl:OnDeleteRecord(id)
    clr.coroutine(function()
        local respone = req.friendsDelRecord(0, id)
        if api.success(respone) then
            local data = respone.val
            self.friendsMatchRecordModel:UpdateMatchRecordsList(data)
            self:SetDeleteAllBtnState()
        end
    end)
end

function FriendsMatchRecordCtrl:SetDeleteAllBtnState()
    local matchRecordsList = self.friendsMatchRecordModel:GetMatchRecordsList()
    if #matchRecordsList > 0 then
        self.friendsMatchRecordView:SetDeleteAllBtnState(true)
    else
        self.friendsMatchRecordView:SetDeleteAllBtnState(false)
    end
end

function FriendsMatchRecordCtrl:UpdateMatchRecordsListCallBack()
    self:RefreshScrollView()
end

function FriendsMatchRecordCtrl:OnInitPlayerTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function FriendsMatchRecordCtrl:OnEnterScene()
    self.friendsMatchRecordView:EnterScene()
end

function FriendsMatchRecordCtrl:OnExitScene()
    self.friendsMatchRecordView:ExitScene()
end

return FriendsMatchRecordCtrl