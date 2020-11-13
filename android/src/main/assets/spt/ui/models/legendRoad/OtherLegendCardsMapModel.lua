local OtherPlayerCardsMapModel = require("ui.models.OtherPlayerCardsMapModel")
local LegendCardsMapModel = require("ui.models.legendRoad.LegendCardsMapModel")
local OtherLegendCardsMapModel = class(LegendCardsMapModel, "OtherLegendCardsMapModel")

function OtherLegendCardsMapModel:ctor()
    OtherLegendCardsMapModel.super.ctor(self)
end

function OtherLegendCardsMapModel:Init(data)
    self.data = data
    if not self.data then
        self.data = {}
        self.data.legendCard = {}
        self.data.skillImprove = {}
    end
    self.playerCardsMapModel = OtherPlayerCardsMapModel.new()
end

function OtherLegendCardsMapModel:InitWithProtocol(data)
    local legendCardsMap = {}
    legendCardsMap.legendCard = data or {}
    legendCardsMap.skillImprove = {}
    self:Init(legendCardsMap)
    self:InitImproveMap()
end

function OtherLegendCardsMapModel:BuildTeamLegendInfo(teamModel, cardsMapModel)
    local cardsMapModel = cardsMapModel or self.playerCardsMapModel
    OtherLegendCardsMapModel.super.BuildTeamLegendInfo(self, teamModel, cardsMapModel)
end

return OtherLegendCardsMapModel