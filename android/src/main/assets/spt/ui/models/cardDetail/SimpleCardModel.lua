local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local Card = require("data.Card")
local BaseCardModel = require("ui.models.cardDetail.BaseCardModel")
local SimpleCardModel = class(BaseCardModel, "SimpleCardModel")

-- 获取缓存数据与静态数据(包括其它玩家卡牌)
function SimpleCardModel:ctor(pcid, cardsMapModel)
    SimpleCardModel.super.ctor(self)
    self.pcid = pcid
    self.playerCardsMapModel = cardsMapModel or PlayerCardsMapModel.new()
    self:InitWithCache(self.playerCardsMapModel:GetCardData(pcid))
end

function SimpleCardModel:InitWithCache(cache)
    if not cache then
        dump(self.pcid, 'error, not exist this pcid')
    end
    self.cacheData = cache or {}
    local cid = self.cacheData and self.cacheData.cid
    self.staticData = Card[tostring(cid)]
end

function SimpleCardModel:GetCardsMapModel()
    return self.playerCardsMapModel
end

return SimpleCardModel