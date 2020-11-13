local BaseCardModel = require("ui.models.cardDetail.BaseCardModel")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local Card = require("data.Card")

local InvalidCardModel = class(BaseCardModel, "InvalidCardModel")

function InvalidCardModel:ctor(cid, playerCardsMapModel)
    InvalidCardModel.super.ctor(self)
    self.cid = cid
    self:InitWithCache(cid)
    self.playerCardsMapModel = playerCardsMapModel or PlayerCardsMapModel.new()
    self:InitCardsMap(self.playerCardsMapModel)
    self.ownershipType = CardOwnershipType.NONE
end

function InvalidCardModel:InitWithCache(cid)
    self.staticData = Card[tostring(cid)]
end

function InvalidCardModel:InitCardsMap(playerCardsMapModel)
    self.cardsMap = playerCardsMapModel.data
end

function InvalidCardModel:GetName()
    return ""
end

-- 日文名，除了通用的卡牌之外，其他地方都应该显示日文名
function InvalidCardModel:GetNameJP()
    return ""
end

-- 对应每个版本中名字的英文语言
function InvalidCardModel:GetNameByEnglish()
    return ""
end

-- 头像的索引
function InvalidCardModel:GetAvatar()
    return ""
end

return InvalidCardModel
