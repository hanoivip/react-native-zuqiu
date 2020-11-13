local CompeteChampionCardModel = require("ui.models.compete.championWall.CompeteChampionCardModel")
local OtherPlayerCardsMapModel = require("ui.models.OtherPlayerCardsMapModel")
local OtherPlayerTeamsModel = require("ui.models.OtherPlayerTeamsModel")
local OtherLegendCardsMapModel = require("ui.models.legendRoad.OtherLegendCardsMapModel")
local PlayerDetailModel = require("ui.models.playerDetail.PlayerDetailModel")

local CompeteChampionPlayerDetailModel = class(PlayerDetailModel, "CompeteChampionPlayerDetailModel")

-- 针对争霸赛冠军墙简略的卡牌信息，特殊的数据结构而做的PlayerDetailModel
function CompeteChampionPlayerDetailModel:ctor()
    CompeteChampionPlayerDetailModel.super.ctor(self)
end

function CompeteChampionPlayerDetailModel:InitWithProtocol(playerDetailData)
    if playerDetailData then
        self.cacheData = {}
        self.cacheData.player = {}
        self.cacheData.player._id = playerDetailData.pid
        self.cacheData.player.sid = playerDetailData.sid
        self.cacheData.player.name = playerDetailData.name
        self.cacheData.player.power = playerDetailData.power
        self.cacheData.serverName = playerDetailData.serverName

        if playerDetailData.init then
            local card = {}
            local team = {}
            team.init = {}
            team.formationID = playerDetailData.formationID
            for pos, cardData in pairs(playerDetailData.init) do
                cardData.pcid = tonumber(pos)
                card[pos] = cardData
                team.init[pos] = cardData.pcid
            end
            self.otherPlayerCardsMapModel = OtherPlayerCardsMapModel.new()
            self.otherPlayerCardsMapModel:InitWithProtocol(card)

            self.otherPlayerTeamsModel = OtherPlayerTeamsModel.new(self.otherPlayerCardsMapModel)
            self.otherPlayerTeamsModel:InitWithProtocol(team)

            if playerDetailData.legendRoad then
                self.cacheData.legendRoad = playerDetailData.legendRoad
                self.otherLegendCardsMapModel = OtherLegendCardsMapModel.new()
                self.otherLegendCardsMapModel:InitWithProtocol(self.cacheData.legendRoad)
                self.otherLegendCardsMapModel:BuildTeamLegendInfo(self:GetOtherPlayerTeamsModel())
            end

            self.cacheData.playerCardModelsMap = {}
            for pcid, v in pairs(card) do
                local otherPlayerCardModel = CompeteChampionCardModel.new(pcid, self.otherPlayerCardsMapModel, self.otherPlayerTeamsModel, self.otherLegendCardsMapModel)
                self.cacheData.playerCardModelsMap[tostring(pcid)] = otherPlayerCardModel
            end
        end
    end
end

return CompeteChampionPlayerDetailModel
