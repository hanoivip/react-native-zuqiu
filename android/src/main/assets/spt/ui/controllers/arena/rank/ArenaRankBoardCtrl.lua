local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local ArenaRankBoardCtrl = class()

function ArenaRankBoardCtrl:ctor(view)
    self.view = view
end

function ArenaRankBoardCtrl:InitView(arenaModel, arenaMainModel)
    self.playerInfoModel = PlayerInfoModel.new()
    self.arenaModel = arenaModel
    self.arenaMainModel = arenaMainModel
    self:CreateItemList()
    self.view:InitView(self.arenaModel)
end

function ArenaRankBoardCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(spt, index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Arena/ArenaRankItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.arenaMainModel = self.arenaMainModel
        -- rankData.gradeName = self.arenaModel:GetGradeName(tostring(rankData.stage))
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt.onViewDetail = function() self:OnViewDetail(rankData.pid, rankData.sid, self.arenaModel.zone) end
        spt:InitView(rankData, index)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function ArenaRankBoardCtrl:RefreshScrollView()
    local rankDataList = self.arenaModel:GetCurRankDataList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

function ArenaRankBoardCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

function ArenaRankBoardCtrl:OnViewDetail(pid, sid, arenaType)
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.arenaOtherTeam(pid, sid, arenaType) end, pid, sid, self.playerInfoModel:GetID() == pid, nil, nil, nil, arenaType)
end

return ArenaRankBoardCtrl