local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PlayerDetailCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local LadderRankOtherSeasonCtrl = class()

function LadderRankOtherSeasonCtrl:ctor(view)
    self.view = view
end

function LadderRankOtherSeasonCtrl:InitView(ladderModel)
    self.ladderModel = ladderModel
    self:CreateItemList()
    self.view:InitView(self.ladderModel)
end

function LadderRankOtherSeasonCtrl:CreateItemList()
    self.view.scrollView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/Ladder/LadderRankOtherSeasonItemBar.prefab")
        return obj, spt
    end
    self.view.scrollView.onScrollResetItem = function(spt, index)
        local rankData = self.view.scrollView.itemDatas[index]
        spt.onView = function() self:OnView(rankData.id, rankData.sid) end
        spt.onInitTeamLogo = function() self:OnInitTeamLogo(spt:GetTeamLogo(), rankData.logo) end
        spt:InitView(rankData, index)
        
        local curRankSeason = self.ladderModel:GetCurRankSeason()
        if curRankSeason.type ~= "current" and curRankSeason.type ~= "season" then
            spt:SetBtnViewActive(false)
        else
            spt:SetBtnViewActive(true) 
        end
        
        self.view.scrollView:updateItemIndex(spt, index)
    end

    self:RefreshScrollView()
end

function LadderRankOtherSeasonCtrl:RefreshScrollView()
    local rankDataList = self.ladderModel:GetCurRankDataList()
    self.view.scrollView:clearData()
    for i = 1, #rankDataList do
        table.insert(self.view.scrollView.itemDatas, rankDataList[i])
    end
    self.view.scrollView:refresh()
end

-- 查看玩家详情
function LadderRankOtherSeasonCtrl:OnView(pid, sid)
    sid = sid or require("ui.models.PlayerInfoModel").new():GetSID()
    PlayerDetailCtrl.ShowPlayerDetailView(function() return req.friendsDetail(pid, sid) end, pid, sid)
end

function LadderRankOtherSeasonCtrl:OnInitTeamLogo(teamLogo, logoData)
    TeamLogoCtrl.BuildTeamLogo(teamLogo, logoData)
end

return LadderRankOtherSeasonCtrl