local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")

local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local EquipsMapModel = require("ui.models.EquipsMapModel")
local EquipPieceMapModel = require("ui.models.EquipPieceMapModel")
local PlayerPiecesMapModel = require("ui.models.PlayerPiecesMapModel")
local PasterPiecesMapModel = require("ui.models.PasterPiecesMapModel")
local CardPastersMapModel = require("ui.models.CardPastersMapModel")
local RedPacketMapModel = require("ui.models.RedPacketMapModel")
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")
local FancyCardsMapModel = require("ui.models.fancy.FancyCardsMapModel")

local tonumber = tonumber
local tostring = tostring

local RewardUpdateCacheModel = class(Model)

function RewardUpdateCacheModel:ctor()
    RewardUpdateCacheModel.super.ctor(self)

    self.playerInfoModel = PlayerInfoModel.new()
    self.playerCardsMapModel = PlayerCardsMapModel.new()
    self.itemsMapModel = ItemsMapModel.new()
    self.equipsMapModel = EquipsMapModel.new()
    self.equipPieceMapModel = EquipPieceMapModel.new()
    self.playerGenericModel = PlayerGenericModel.new()
    self.playerPiecesMapModel = PlayerPiecesMapModel.new()
    self.cardPastersMapModel = CardPastersMapModel.new()
    self.pasterPiecesMapModel = PasterPiecesMapModel.new()
    self.redPacketMapModel = RedPacketMapModel.new()
    self.playerMedalsMapModel = PlayerMedalsMapModel.new()
    self.coachItemMapModel = CoachItemMapModel.new()
    self.greenswardItemMapModel = GreenswardItemMapModel.new()
    self.fancyCardsMapModel = FancyCardsMapModel.new()
end

function RewardUpdateCacheModel:UpdateCache(rewardTable)
    assert(rewardTable and type(rewardTable) == "table")

    self.playerInfoModel:UpdateFromReward(rewardTable)
    self.playerCardsMapModel:UpdateFromReward(rewardTable)
    self.itemsMapModel:UpdateFromReward(rewardTable)
    self.equipsMapModel:UpdateFromReward(rewardTable)
    self.equipPieceMapModel:UpdateFromReward(rewardTable)
    self.playerGenericModel:UpdateFromReward(rewardTable)
    self.playerPiecesMapModel:UpdateFromReward(rewardTable)
    self.cardPastersMapModel:UpdateFromReward(rewardTable)
    self.pasterPiecesMapModel:UpdateFromReward(rewardTable)
    self.redPacketMapModel:UpdateFromReward(rewardTable)
    self.playerMedalsMapModel:UpdateFromReward(rewardTable)
    self.coachItemMapModel:UpdateCoachItemFromRewards(rewardTable)
    self.greenswardItemMapModel:UpdateItemsFromRewards(rewardTable)
    self.fancyCardsMapModel:UpdateFromReward(rewardTable)
end

return RewardUpdateCacheModel
