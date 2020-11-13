local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")

local LadderRankCurrentSeasonCtrl = class()

function LadderRankCurrentSeasonCtrl:ctor(view)
    self.view = view
end

function LadderRankCurrentSeasonCtrl:InitView(ladderModel)
    self.ladderModel = ladderModel
    self:CreateItemList()
    self.view:InitView(self.ladderModel)
end

function LadderRankCurrentSeasonCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRankCurrentSeasonItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onView = function() self:OnView(rankData.id, rankData.sid) end
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index)
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function LadderRankCurrentSeasonCtrl:RefreshScrollView()
    local rankDataList = self.ladderModel:GetCurRankDataList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

-- 查看玩家详情
function LadderRankCurrentSeasonCtrl:OnView(pid, sid)
    sid = sid or require("ui.models.PlayerInfoModel").new():GetSID()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function LadderRankCurrentSeasonCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return LadderRankCurrentSeasonCtrl