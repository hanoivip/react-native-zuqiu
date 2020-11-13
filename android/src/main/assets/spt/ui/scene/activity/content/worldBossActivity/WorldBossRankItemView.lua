local RankTabType = require("ui.scene.rank.RankTabType")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local WorldBossRankItemView = class(unity.base)

function WorldBossRankItemView:ctor()
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.score = self.___ex.score
    self.mName = self.___ex.mName
    self.btnView = self.___ex.btnView
end

function WorldBossRankItemView:start()
    self.btnView:regOnButtonClick(function()
        if self.onViewOpponentDetail then
            self.onViewOpponentDetail()
        end
    end)
end

function WorldBossRankItemView:InitView(rankData, isSelf)
    self.rankData = rankData
    GameObjectHelper.FastSetActive(self.btnView.gameObject, isSelf)
    self.mName.text = isSelf and rankData.name or rankData.serverName
    self.score.text = tostring(rankData.score)
    self:InitRankShowState(rankData.rank)
    self.normalRank.text = lang.trans("guildwar_rank", rankData.rank)
end

function WorldBossRankItemView:InitGuild(guildData, textComponet)
    if guildData then 
        textComponet.text = guildData.name
    else
        textComponet.text = lang.trans("no_guild")
    end 
end

function WorldBossRankItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

return WorldBossRankItemView