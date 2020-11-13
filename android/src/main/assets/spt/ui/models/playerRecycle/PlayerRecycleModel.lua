local PlayerRecycle = require("data.PlayerRecycle")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local Model = require("ui.models.Model")

local PlayerRecycleModel = class(Model, "PlayerRecycleModel")

-- 做个便捷开关 以后好修改一点
PlayerRecycleModel.RecycleLable = 
{
    {labelName = "recycle_cultivate", tag = "cultivate", isOpen = true},  -- 维他命还原
    {labelName = "recycle_skillImprove", tag = "skillImprove", isOpen = true},  -- 技能券还原
    {labelName = "recycle_ascend", tag = "ascend", isOpen = true},  -- 转生还原
    {labelName = "recycle_upgrade", tag = "upgrade", isOpen = false},  -- 进阶还原
    {labelName = "recycle_trainingBase", tag = "trainingBase", isOpen = false},  -- 特训还原
}
--这里是后加的变色
PlayerRecycleModel.RecycleLableRed = 
{
    {labelName = "recycle_cultivateRed", tag = "cultivate"},  -- 维他命还原
    {labelName = "recycle_skillImproveRed", tag = "skillImprove"},  -- 技能券还原
    {labelName = "recycle_ascend", tag = "ascend"},  -- 转生还原
    {labelName = "recycle_upgrade", tag = "upgrade"},  -- 进阶还原
    {labelName = "recycle_trainingBase", tag = "trainingBase"},  -- 特训还原
}

PlayerRecycleModel.CostPercentKey = 
{
    m = "mReceoverPercent",
    d = "dReceoverPercent",
    bkd = "bkdReceoverPercent",
}

function PlayerRecycleModel:ctor(carModel)
    self.tag = nil
    self.carModel = carModel
    self.playerInfoModel = PlayerInfoModel.new()
end

function PlayerRecycleModel:GetLableContent()
    local lableContent = {}
    for i, v in ipairs(PlayerRecycleModel.RecycleLable) do
        local tag = v.tag
        local cost = self:GetBKDCost(tag)
        v.canUse =  type(cost) == "number" and cost > 0
        table.insert(lableContent, v)
    end
    return lableContent
end  

function PlayerRecycleModel:GetCarModel()
    return self.carModel
end

function PlayerRecycleModel:SetCurrentTag(tag)
    self.tag = tag
end

function PlayerRecycleModel:GetCurrentTag()
    return self.tag or self:GetDefaultTag()
end

function PlayerRecycleModel:GetDefaultTag()
    local defaultTag = self.defaultTag or PlayerRecycleModel.RecycleLable[1].tag
    return defaultTag
end

function PlayerRecycleModel:SetDefaultTag(tag)
    self.defaultTag = tag
end

function PlayerRecycleModel:SetCurrentLableData(lableData)
    self.lableData = lableData
end

function PlayerRecycleModel:GetCurrentLableData()
    return self.lableData or self:GetDefaultLableData()
end

function PlayerRecycleModel:GetDefaultLableData()
    local defaultLableData = PlayerRecycleModel.RecycleLable[1]
    return defaultLableData
end

function PlayerRecycleModel:SetCurrentCostType(costType)
    self.costType = costType
end

function PlayerRecycleModel:GetCurrentCostType()
    return self.costType or "m"
end

function PlayerRecycleModel:GetPcid()
    local pcid = self.carModel:GetPcid()
    return pcid
end

function PlayerRecycleModel:GetBaseAndPasterSkillLevel()
    local lvlPlus = 0
    local skillList = self.carModel.cacheData and self.carModel.cacheData.skills
    if type(skillList) == "table" then
        for i,v in ipairs(skillList) do
            lvlPlus = lvlPlus + v.lvl
        end
        lvlPlus = lvlPlus - #skillList
    end
    return lvlPlus
end

function PlayerRecycleModel:GetVitaminCount()
    local consumePotent = self.carModel:GetConsumePotent()
    return consumePotent / 5
end

function PlayerRecycleModel:GetAscendCount()
    local ascendCount = tonumber(self.carModel:GetAscend())
    return ascendCount
end

function PlayerRecycleModel:GetMoneyRecyclePriceAndPercent(tag)
    local recycleStaticData = PlayerRecycle[tag]
    local mPrice, mReceoverPercent = 0, 0
    if recycleStaticData then
        if tag == "ascend" then
            local carModel = self:GetCarModel()
            local quality = carModel:GetCardQuality()
            local qualitySpecial = carModel:GetCardQualitySpecial()
            local fixedquality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
            local qualityAsendData = recycleStaticData[fixedquality]
            if qualityAsendData then
                mPrice = tonumber(qualityAsendData.m)
                mReceoverPercent = tonumber(qualityAsendData.mReceoverPercent) / 100
            end
        else
            mPrice = tonumber(recycleStaticData.m)
            mReceoverPercent = tonumber(recycleStaticData.mReceoverPercent) / 100
        end
    end
    return mPrice, mReceoverPercent
end

function PlayerRecycleModel:GetMoneyCost(tag)
    local mPrice, mReceoverPercent = self:GetMoneyRecyclePriceAndPercent(tag)
    if tag == "skillImprove" then
        local lvlPlus = self:GetBaseAndPasterSkillLevel()
        local skillCount = math.ceil(lvlPlus * mReceoverPercent)
        return math.ceil(skillCount * mPrice)
    elseif tag == "cultivate" then
        local totalVitaminCount = self:GetVitaminCount()
        local vitaminCount = math.ceil(totalVitaminCount * mReceoverPercent)
        return math.ceil(vitaminCount * mPrice)
    elseif tag == "ascend" then
        local totalAscend = self:GetAscendCount()
        local cardCount = math.ceil(totalAscend * mReceoverPercent)
        return math.ceil(cardCount * mPrice)
    end
end

function PlayerRecycleModel:GetDiamondRecyclePriceAndPercent(tag)
    local recycleStaticData = PlayerRecycle[tag]
    local dPrice, dReceoverPercent = 0, 0
    if recycleStaticData then
        if tag == "ascend" then
            local carModel = self:GetCarModel()
            local quality = carModel:GetCardQuality()
            local qualitySpecial = carModel:GetCardQualitySpecial()
            local fixedquality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
            local qualityAsendData = recycleStaticData[fixedquality]
            if qualityAsendData then
                dPrice = tonumber(qualityAsendData.d)
                dReceoverPercent = tonumber(qualityAsendData.dReceoverPercent) / 100
            end
        else
            dPrice = tonumber(recycleStaticData.d)
            dReceoverPercent = tonumber(recycleStaticData.dReceoverPercent) / 100
        end
    end
    return dPrice, dReceoverPercent
end

function PlayerRecycleModel:GetDiamondCost(tag)
    local dPrice, dReceoverPercent = self:GetDiamondRecyclePriceAndPercent(tag)
    if tag == "skillImprove" then
        local lvlPlus = self:GetBaseAndPasterSkillLevel()
        local skillCount = math.ceil(lvlPlus * dReceoverPercent)
        return math.ceil(skillCount * dPrice)
    elseif tag == "cultivate" then
        local totalVitaminCount = self:GetVitaminCount()
        local vitaminCount = math.ceil(totalVitaminCount * dReceoverPercent)
        return math.ceil(vitaminCount * dPrice)
    elseif tag == "ascend" then
        local totalAscend = self:GetAscendCount()
        local cardCount = math.ceil(totalAscend * dReceoverPercent)
        return math.ceil(cardCount * dPrice)
    end
end

function PlayerRecycleModel:GetBKDRecyclePriceAndPercent(tag)
    local recycleStaticData = PlayerRecycle[tag]
    local bkdPrice, bkdReceoverPercent = 0, 0
    if recycleStaticData then
        if tag == "ascend" then
            local carModel = self:GetCarModel()
            local quality = carModel:GetCardQuality()
            local qualitySpecial = carModel:GetCardQualitySpecial()
            local fixedquality = CardHelper.GetQualityConfigFixed(quality, qualitySpecial)
            local qualityAsendData = recycleStaticData[fixedquality]
            if qualityAsendData then
                bkdPrice = tonumber(qualityAsendData.bkd)
                bkdReceoverPercent = tonumber(qualityAsendData.bkdReceoverPercent) / 100
            end
        else
            bkdPrice = tonumber(recycleStaticData.bkd)
            bkdReceoverPercent = tonumber(recycleStaticData.bkdReceoverPercent) / 100
        end
    end
    return bkdPrice * 0.1, bkdReceoverPercent
end

function PlayerRecycleModel:GetBKDCost(tag)
    local bkdPrice, bkdReceoverPercent = self:GetBKDRecyclePriceAndPercent(tag)
    if tag == "skillImprove" then
        local lvlPlus = self:GetBaseAndPasterSkillLevel()
        local skillCount = math.ceil(lvlPlus * bkdReceoverPercent)
        local totalPrice = skillCount * bkdPrice
        return math.ceil(totalPrice)
    elseif tag == "cultivate" then
        local totalVitaminCount = self:GetVitaminCount()
        local vitaminCount = math.ceil(totalVitaminCount * bkdReceoverPercent)
        return math.ceil(vitaminCount * bkdPrice)
    elseif tag == "ascend" then
        local totalAscend = self:GetAscendCount()
        local cardCount = math.ceil(totalAscend * bkdReceoverPercent)
        return math.ceil(cardCount * bkdPrice)
    end
end

function PlayerRecycleModel:GetPrice(tag)
    local m = self:GetMoneyCost(tag)
    local d = self:GetDiamondCost(tag)
    local bkd = self:GetBKDCost(tag)
    return m, d, bkd
end

function PlayerRecycleModel:GetRecycleItemContent(tag, costType)
    if tag == "skillImprove" then
        local contents = {}
        contents.item = {}
        local costPercentKey = PlayerRecycleModel.CostPercentKey[costType]
        local recycleStaticData = PlayerRecycle[tag]
        local percent = tonumber(recycleStaticData[costPercentKey]) / 100
        local lvlPlus = self:GetBaseAndPasterSkillLevel()
        local lvlTicketNum = math.ceil(lvlPlus * percent)
        local ticketData = {}
        ticketData.id = "10"
        ticketData.num = lvlTicketNum
        table.insert(contents.item, ticketData)
        return contents
    elseif tag == "cultivate" then
        local contents = {}
        contents.item = {}
        local costPercentKey = PlayerRecycleModel.CostPercentKey[costType]
        local recycleStaticData = PlayerRecycle[tag]
        local percent = tonumber(recycleStaticData[costPercentKey]) / 100
        local vitaminPlus = self:GetVitaminCount()
        local vitaminNum = math.ceil(vitaminPlus * percent)
        local vitaminData = {}
        vitaminData.id = "1"
        vitaminData.num = vitaminNum
        table.insert(contents.item, vitaminData)
        return contents
    else
        local contents = {}
        contents.card = {}
        local cardData = {}
        local carModel = self:GetCarModel()
        local cardId = carModel:GetCid()
        local cardNum = self:GetAscendCount()
        cardData.id = cardId
        cardData.num = cardNum
        cardData.lvl = 1
        cardData.upgrade = 1
        table.insert(contents.card, cardData)
        return contents
    end    
end

function PlayerRecycleModel:GetNowCost(tag, costType)
    local cost, now = 0, 0
    if costType == "m" then
        cost = self:GetMoneyCost(tag)
        now = self.playerInfoModel:GetMoney()
    elseif costType == "d" then
        cost = self:GetDiamondCost(tag)
        now = self.playerInfoModel:GetDiamond()
    elseif costType == "bkd" then
        cost = self:GetBKDCost(tag)
        now = self.playerInfoModel:GetBlackDiamond()
    else
        return 0
    end
    if cost > 0 then
        if cost <= now then
            return cost
        else
            return 0
        end
    else
        return -1
    end
end

function PlayerRecycleModel:GetRecycleTag()
    local vitaminPlus = self:GetVitaminCount()
    if vitaminPlus > 0 then
        return PlayerRecycleModel.RecycleLable[1].tag
    end
    local lvlPlus = self:GetBaseAndPasterSkillLevel()
    if lvlPlus > 0 then
        return PlayerRecycleModel.RecycleLable[2].tag
    end
    local ascendCount = self:GetAscendCount()
    if ascendCount > 0 then
        return PlayerRecycleModel.RecycleLable[3].tag
    end
    return false
end

-- 该球员 助阵球员/助阵其他球员 时禁止转生还原
function PlayerRecycleModel:GetClosedBySupporterMessage()
    local isSupportOtherCard = self.carModel:IsSupportOtherCard()
    local isHasSupportCard = self.carModel:IsHasSupportCard()
    local tag = self:GetCurrentTag()
    if tag == PlayerRecycleModel.RecycleLable[3].tag then
        if isSupportOtherCard then
            return lang.transstr("support_support_recycle")
        elseif isHasSupportCard then
            return lang.transstr("support_self_recycle")
        end
    end
    return false
end

return PlayerRecycleModel
