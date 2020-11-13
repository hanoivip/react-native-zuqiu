local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local BrainRankItemView = class(unity.base)

function BrainRankItemView:ctor()
    self.nameTxt = self.___ex.name
    self.teamLogo = self.___ex.teamLogo
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.bgNormal = self.___ex.bgNormal
    self.bgHighLight = self.___ex.bgHighLight
    self.count = self.___ex.count
    self.time = self.___ex.time
    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function BrainRankItemView:start()
    
end

function BrainRankItemView:InitView(rankData, index)
    self.nameTxt.text = rankData.name
    self.normalRank.text = lang.trans("ladder_rank", tostring(rankData.rank))
    self.count.text = tostring(rankData.result)
    self.time.text = lang.trans("time_second", rankData.useTime)
    self:InitTeamLogo()
    self:InitRankShowState(rankData.rank)
end

function BrainRankItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function BrainRankItemView:GetTeamLogo()
    return self.teamLogo
end

function BrainRankItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

return BrainRankItemView