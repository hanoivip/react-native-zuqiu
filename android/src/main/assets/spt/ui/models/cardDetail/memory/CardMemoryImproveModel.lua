local AdditionType = require("ui.models.cardDetail.memory.CardMemoryAdditionType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local PlayerCardsMapModel = require("ui.models.PlayerCardsMapModel")
local Card = require("data.Card")
local CardMemory = require("data.CardMemory")
local Model = require("ui.models.Model")

-- 计算某卡牌带来的传奇记忆属性加成
local CardMemoryImproveModel = class(Model, "CardMemoryImproveModel")

function CardMemoryImproveModel:ctor(playerCardsMapModel)
    if not playerCardsMapModel then
        self.playerCardsMapModel = PlayerCardsMapModel.new()
    else
        self.playerCardsMapModel = playerCardsMapModel
    end
    CardMemoryImproveModel.super.ctor(self)
end

function CardMemoryImproveModel:Init()
end

-- 根据playerCardModel获得该cardModel带来的传奇记忆属性加成
function CardMemoryImproveModel:GetAttrImprove(cardModel)
    return self:GetAttrImproveByCache(cardModel:GetCacheData())
end

-- 根据pcid获得该卡牌带来的传奇记忆属性加成
function CardMemoryImproveModel:GetAttrImproveByPcid(pcid)
    return self:GetAttrImproveByCache(self.playerCardsMapModel:GetCardData(pcid))
end

-- @param cacheData: 标准服务器卡牌数据
function CardMemoryImproveModel:GetAttrImproveByCache(cacheData)
    local attrAdded = 0 -- 增加总和
    local attrs = {} -- 单项增加
    if table.isEmpty(cacheData) then
        return attrAdded, attrs
    end

    local cid = cacheData.cid
    local cardConfig = Card[cid]
    if table.isEmpty(cardConfig) then
        return attrAdded, attrs
    end

    local cardParams = {}
    local qualityKey = CardHelper.GetQualityConfigFixed(cardConfig.quality, cardConfig.qualitySpecial)

    -- 进阶
    cardParams[AdditionType.Upgrade] = tostring(cacheData.upgrade or 0)
    attrs[AdditionType.Upgrade] = 0
    -- 转生
    cardParams[AdditionType.Ascend] = tostring(cacheData.ascend or 0)
    attrs[AdditionType.Ascend] = 0
    -- 特训
    cardParams[AdditionType.TrainingBase] = tostring(cacheData.trainingBase ~= nil and cacheData.trainingBase.chapter or 0)
    attrs[AdditionType.TrainingBase] = 0

    for additionType, val in pairs(cardParams) do
        if CardMemory[additionType] and CardMemory[additionType][qualityKey] then
            local config = CardMemory[additionType][qualityKey][tostring(val)]
            if config ~= nil then
                attrs[additionType] = config.attributeImprove
                attrAdded = attrAdded + config.attributeImprove
            end
        end
    end

    return attrAdded, attrs
end

-- 判断某一cid卡牌是否可以带来属性加成
function CardMemoryImproveModel:HasImprove(cid)
    local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
    local cidsMap = self.playerCardsMapModel:GetCardCidMaps()
    local pcids = cidsMap[cid] or {}
    for pcid, flag in pairs(pcids) do
        if flag then
            local cardModel = SimpleCardModel.new(pcid, nil, self.playerCardsMapModel)
            local attrAdd = self:GetAttrImprove(cardModel)
            if attrAdd > 0 then
                return true
            end
        end
    end
    return false
end

return CardMemoryImproveModel
