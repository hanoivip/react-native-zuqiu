local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")

local LadderMatchRecordMainCtrl = class(BaseCtrl)

LadderMatchRecordMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderMatchRecordBoard.prefab"

function LadderMatchRecordMainCtrl:Init(ladderModel)
    self.ladderModel = ladderModel
    clr.coroutine(function()
        local respone = req.ladderRecord()
        if api.success(respone) then
            local data = respone.val
            self.ladderModel:InitMatchRecordList(data)
            self:InitView()
        end
    end)
end

function LadderMatchRecordMainCtrl:Refresh(ladderModel)
    LadderMatchRecordMainCtrl.super.Refresh(self)
end

function LadderMatchRecordMainCtrl:GetStatusData()
    return self.ladderModel
end

function LadderMatchRecordMainCtrl:InitView()
    self:CreateItemList()
    self.view.onBack = function() self:OnBack() end
    self.view:InitView(self.ladderModel)
end

function LadderMatchRecordMainCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderMatchRecordItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local matchRecordData = self.view.scrollView.itemDatas[index]
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), matchRecordData.opponent.logo) end
        spt.onView = function() self:OnView(matchRecordData.vid) end
        -- spt.onShare = function() self:OnShare() end
        spt.onViewDetail = function() self:OnViewDetail(matchRecordData.opponent.pid, matchRecordData.opponent.sid) end
        spt:InitView(matchRecordData)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function LadderMatchRecordMainCtrl:RefreshScrollView()
    local matchRecordList = self.ladderModel:GetMatchRecordList()
    self.view.scrollView:clearData()
    for i = 1, #matchRecordList do
        table.insert(self.view.scrollView.itemDatas, matchRecordList[i])
    end
    self.view.scrollView:refresh()
end

function LadderMatchRecordMainCtrl:OnBack()
    res.PopScene()
end

function LadderMatchRecordMainCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

-- 查看录像
function LadderMatchRecordMainCtrl:OnView(vid)
    clr.coroutine(function()
        local respone = req.ladderVideo(vid)
        if api.success(respone) then
            local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
            ReplayCheckHelper.StartReplay(respone.val, vid)
        end
    end)
end

-- 查看对手信息
function LadderMatchRecordMainCtrl:OnViewDetail(pid, sid)
    sid = sid or require("ui.models.PlayerInfoModel").new():GetSID()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

-- 分享比赛
-- function LadderMatchRecordMainCtrl:OnShare()
-- end

return LadderMatchRecordMainCtrl