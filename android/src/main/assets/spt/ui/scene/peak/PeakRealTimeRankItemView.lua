local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector2 = UnityEngine.Vector2
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteSignConvert = require("ui.scene.compete.main.CompeteSignConvert")
local AssetFinder = require("ui.common.AssetFinder")

local PeakRealTimeRankItemView = class(unity.base)

function PeakRealTimeRankItemView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.teamLogo = self.___ex.teamLogo
    self.firstRank = self.___ex.firstRank
    self.secondRank = self.___ex.secondRank
    self.thirdRank = self.___ex.thirdRank
    self.normalRank = self.___ex.normalRank
    self.bgNormal = self.___ex.bgNormal
    self.bgHighLight = self.___ex.bgHighLight
    self.btnView = self.___ex.btnView
    self.partition = self.___ex.partition
    -- 争霸赛标识
    self.competeSign = self.___ex.competeSign

    self.playerInfoModel = PlayerInfoModel.new()
    self.playerInfoModel:Init()
end

function PeakRealTimeRankItemView:start()
    self:BindButtonHandler()
end

function PeakRealTimeRankItemView:InitView(rankData, index)
    self.nameTxt.text = rankData.name
    self.level.text = "Lv " .. tostring(rankData.lvl)
    self.normalRank.text = lang.trans("ladder_rank", tostring(rankData.rank))
    self.partition.text = rankData.serverName
    self:InitTeamLogo() 
    self:InitRankShowState(rankData.rank)
    self:InitBackGround(rankData.pid, rankData.rank)
    self:InitCompeteSign(rankData)
end

function PeakRealTimeRankItemView:BindButtonHandler()
    self.btnView:regOnButtonClick(function()
        if self.onViewDetail then
            self.onViewDetail()
        end
    end)
end

function PeakRealTimeRankItemView:InitTeamLogo()
    if self.onInitTeamLogo then
        self.onInitTeamLogo()
    end
end

function PeakRealTimeRankItemView:GetTeamLogo()
    return self.teamLogo
end

function PeakRealTimeRankItemView:InitRankShowState(rank)
    GameObjectHelper.FastSetActive(self.firstRank, rank == 1)
    GameObjectHelper.FastSetActive(self.secondRank, rank == 2)
    GameObjectHelper.FastSetActive(self.thirdRank, rank == 3)
    GameObjectHelper.FastSetActive(self.normalRank.gameObject, rank >= 4)
end

function PeakRealTimeRankItemView:InitBackGround(pid, rank)
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

function PeakRealTimeRankItemView:InitCompeteSign(data)
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

return PeakRealTimeRankItemView