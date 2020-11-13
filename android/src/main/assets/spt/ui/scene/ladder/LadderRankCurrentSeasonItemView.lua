local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")


local LadderRankCurrentSeasonItemView = class(unity.base)

function LadderRankCurrentSeasonItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.honorPoint = self.___ex.honorPoint
    self.teamLogo = self.___ex.teamLogo
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.bgNormal = self.___ex.bgNormal
    self.bgHighLight = self.___ex.bgHighLight
    self.btnView = self.___ex.btnView
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign

    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function LadderRankCurrentSeasonItemView:start()
    self:BindButtonHandler()
end

function LadderRankCurrentSeasonItemView:InitView(rankData, index)
    self.nameTxt.text = rankData.name
    self.level.text = "Lv " .. tostring(rankData.lvl)
    self.normalRank.text = lang.trans("ladder_rank", tostring(rankData.rank))
    self.honorPoint.text = tostring(rankData.seasonScore)
    self:InitTeamLogo()
    self:InitRankShowState(rankData.rank)
    self:InitBackGround(rankData.id, rankData.rank)
    self:InitCompeteSign(rankData)
end

function LadderRankCurrentSeasonItemView:BindButtonHandler()
    self.btnView:regOnButtonClick(function()
        if self.onView then
            self.onView()
        end
    end)
end

function LadderRankCurrentSeasonItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function LadderRankCurrentSeasonItemView:GetTeamLogo()
    return self.teamLogo
end

function LadderRankCurrentSeasonItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

function LadderRankCurrentSeasonItemView:InitBackGround(id, rank)
    if self.playerInfoModel:GetID() == id then
         GameObjectHelper.FastSetActive(self.bgNormal, false)
         GameObjectHelper.FastSetActive(self.bgHighLight, true)
    else
         GameObjectHelper.FastSetActive(self.bgNormal, rank % 2 == 0)
         GameObjectHelper.FastSetActive(self.bgHighLight, false)
    end
end

function LadderRankCurrentSeasonItemView:InitCompeteSign(data)
    local worldTournamentLevel = data.worldTournamentLevel
    if worldTournamentLevel ~= nil then
        local signData = CompeteSignConvert[tostring(worldTournamentLevel)]
        if signData then
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, true)
            self.competeSign.overrideSprite = AssetFinder.GetCompeteSign(signData.path)
        else
            GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
        end
    else
        GameObjectHelper.FastSetActive(self.competeSign.gameObject, false)
    end
end

return LadderRankCurrentSeasonItemView