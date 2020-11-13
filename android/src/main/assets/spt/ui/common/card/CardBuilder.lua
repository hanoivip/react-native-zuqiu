local CardBuilder = {}
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local OtherCardModel = require("ui.models.cardDetail.OtherCardModel")
local GreenswardCardModel = require("ui.models.cardDetail.GreenswardCardModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local FormationType = require("ui.common.enum.FormationType")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")

------------
-- 以BaseCardModel为基类Model
------------
-- 首发阵容卡牌数据
function CardBuilder.GetStarterModel(pcid, teamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel, legendCardsMapModel, homeCourtModel)
    local model = PlayerCardModel.new(pcid, teamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel, legendCardsMapModel, homeCourtModel)
    model:SetTeamModel(teamsModel)
    model:SetOwnershipType(CardOwnershipType.SELF)
    model:SetFormationType(FormationType.DEFAULT)
    return model
end

-- 其它玩家卡牌数据
function CardBuilder.GetOtherCardModel(pcid, cids, otherPlayerCardsMapModel, otherTeamsModel, otherLegendCardsMapModel, homeCourtModel, otherCoachMainModel)
    local model = OtherCardModel.new(pcid, otherPlayerCardsMapModel, otherTeamsModel, otherLegendCardsMapModel, homeCourtModel)
    model:SetAllCardsCids(cids)
    model:SetOwnershipType(CardOwnershipType.OTHER)
    if otherCoachMainModel then
        otherCoachMainModel:SetPlayerCardModel(model)
        model:SetCoachMainModel(otherCoachMainModel)
    end
    return model
end

-- 卡牌基础数据
function CardBuilder.GetBaseCardModel(cid)
    local model = StaticCardModel.new(cid)
    model:SetOwnershipType(CardOwnershipType.NONE)
    model:SetFormationType(FormationType.DEFAULT)
    return model
end

-- 自身卡牌数据（背包） 暂时与首发数据一致
function CardBuilder.GetOwnCardModel(pcid, playerTeamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel)
    local model = PlayerCardModel.new(pcid, playerTeamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel)
    model:SetTeamModel(playerTeamsModel)
    model:SetOwnershipType(CardOwnershipType.SELF)
    return model
end

-- 阵型卡牌数据（阵型） 暂时与首发数据类似
function CardBuilder.GetFormationCardModel(pcid, teamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel, legendCardsMapModel, homeCourtModel)
    local model = CardBuilder.GetStarterModel(pcid, teamsModel, playerCardsMapModel, equipPieceMapModel, equipsMapModel, legendCardsMapModel, homeCourtModel)
    model:SetTeamModel(teamsModel)
    return model
end

-- 绿茵征途玩家卡牌数据
function CardBuilder.GetGreenswardCardModel(pcid, cids, otherPlayerCardsMapModel, otherTeamsModel, opRevise)
    local model = GreenswardCardModel.new(pcid, otherPlayerCardsMapModel, otherTeamsModel)
    model:SetOpponentEventRatio(opRevise)
    model:SetAllCardsCids(cids)
    model:SetOwnershipType(CardOwnershipType.OTHER)
    return model
end

return CardBuilder
