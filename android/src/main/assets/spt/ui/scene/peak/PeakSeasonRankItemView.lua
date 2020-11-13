local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local PeakSeasonRankItemView = class(unity.base)

function PeakSeasonRankItemView:ctor()
    self.nameTxt = self.___ex.name
    self.score = self.___ex.score
    self.teamLogo = self.___ex.teamLogo
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.bgNormal = self.___ex.bgNormal
    self.bgHighLight = self.___ex.bgHighLight
    self.btnView = self.___ex.btnView
    self.partition = self.___ex.partition
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function PeakSeasonRankItemView:start()
    self:BindButtonHandler()
end

function PeakSeasonRankItemView:InitView(rankData, index)
    self.nameTxt.text = rankData.name
    rankData.peakCount = rankData.peakCount or 0
    self.score.text = tostring(rankData.peakCount)
    self.normalRank.text = lang.trans("ladder_rank", tostring(rankData.rank))
    self.partition.text = rankData.serverName
    self:InitTeamLogo() 
    self:InitRankShowState(rankData.rank)
    self:InitBackGround(rankData.pid, rankData.rank)
end

function PeakSeasonRankItemView:BindButtonHandler()
    self.btnView:regOnButtonClick(function()
        if self.onViewDetail then
            self.onViewDetail()
        end
    end)
end

function PeakSeasonRankItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function PeakSeasonRankItemView:GetTeamLogo()
    return self.teamLogo
end

function PeakSeasonRankItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

function PeakSeasonRankItemView:InitBackGround(pid, rank)
    if self.playerInfoModel:GetID() == pid then
         GameObjectHelper.FastSetActive(self.bgNormal, false)
         GameObjectHelper.FastSetActive(self.bgHighLight, true)
         self.nameTxt.color = Color(1, 224/255, 0)
    else
        self.nameTxt.color = Color(1, 1, 1)
         GameObjectHelper.FastSetActive(self.bgNormal, rank % 2 == 0)
         GameObjectHelper.FastSetActive(self.bgHighLight, false)
    end
end

function PeakSeasonRankItemView:SetBtnViewActive(isActive)
    -- GameObjectHelper.FastSetActive(self.btnViewObj, isActive)
end

return PeakSeasonRankItemView