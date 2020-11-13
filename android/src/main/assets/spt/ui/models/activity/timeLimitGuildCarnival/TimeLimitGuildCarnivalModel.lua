local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")
local ItemType = require("ui.scene.itemList.ItemType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local ActivityModel = require("ui.models.activity.ActivityModel")

local TimeLimitGuildCarnivalModel = class(ActivityModel, "TimeLimitGuildCarnivalModel")

function TimeLimitGuildCarnivalModel:ctor(data)
    TimeLimitGuildCarnivalModel.super.ctor(self, data)
end

function TimeLimitGuildCarnivalModel:InitWithProtocol()
end

--- 获取活动开始时间
function TimeLimitGuildCarnivalModel:GetBeginTime()
    local singleData = self:GetActivitySingleData()
    return singleData.beginTime
end

--- 获取活动结束时间
function TimeLimitGuildCarnivalModel:GetEndTime()
    local singleData = self:GetActivitySingleData()
    return singleData.endTime
end

-- 获取【所属公会】名称
function TimeLimitGuildCarnivalModel:GetGuildName()
    local singleData = self:GetActivitySingleData()
    return singleData.guildName or ""
end

-- 获得公会ID，未加入为nil，加入过退出为nil，公会解散为公会ID
function TimeLimitGuildCarnivalModel:GetGuildID()
    local singleData = self:GetActivitySingleData()
    return singleData.gid or ""
end

-- 获取公会积分
function TimeLimitGuildCarnivalModel:GetGuildPoint()
    local singleData = self:GetActivitySingleData()
    return tonumber(singleData.guildPoint)
end

-- 获得商品列表
function TimeLimitGuildCarnivalModel:GetCommodityList()
    local singleData = self:GetActivitySingleData()
    for index, commodity in pairs(singleData.list) do
        local itemId = ""
        local itemNum = 0
        local itemType = ""
        for k, v in pairs(commodity.contents) do
            itemType = k
            if type(v) == "table" then
                for i, item in pairs(v) do
                    itemId = item.id
                    itemNum = item.num
                end
            end
        end

        local itemName = ""
        if itemType == ItemType.Item then
            itemName = ItemModel.new(itemId):GetName()
        elseif itemType == ItemType.Card then
            itemName = StaticCardModel.new(itemId):GetName()
        elseif itemType == ItemType.Paster then
            local pasterModel = CardPasterModel.new()
            pasterModel:InitWithStatic(itemId)
            itemName = pasterModel:GetName()
        elseif itemType == ItemType.CardPiece then
            local pieceModel = CardPieceModel.new()
            pieceModel:InitWithStatic(itemId)
            if pieceModel:IsUniversalPiece() then
                itemName = pieceModel:GetName()
            else
                local qualityStr = CardHelper.GetQualitySign(CardHelper.GetQualityFixed(pieceModel:GetQuality(), pieceModel:GetQualitySpecial()))
                itemName = qualityStr .. lang.transstr("itemList_quality") .. pieceModel:GetName() .. lang.transstr("piece")
            end
        elseif itemType == ItemType.PasterPiece then
            local pieceModel = CardPasterPieceModel.new()
            pieceModel:InitWithStatic(itemId)
            itemName = pieceModel:GetName()
        elseif itemType == ItemType.Eqs then
            itemName = EquipModel.new(itemId):GetName()
        end
        commodity.itemId = itemId
        commodity.itemNum = itemNum
        commodity.itemType = itemType
        commodity.itemName = itemName
    end
    table.sort(singleData.list, function(a, b)
        return a.subID < b.subID
    end)
    return singleData.list
end

-- 获得奖励列表
function TimeLimitGuildCarnivalModel:GetRewardList()
    local singleData = self:GetActivitySingleData()
    local isDismissed = self:IsGuildDismissed()
    for k, v in ipairs(singleData.guildRewardList) do
        v.currGuildPoint = tonumber(singleData.guildPoint)
        v.isDismissed = isDismissed
    end
    table.sort(singleData.guildRewardList, function(a, b)
        return a.subID < b.subID
    end)
    return singleData.guildRewardList
end

-- 是否已经加入公会
function TimeLimitGuildCarnivalModel:IsInGuild()
    local gid = self:GetGuildID()
    local guildName = self:GetGuildName()
    return tobool(string.len(gid) > 0 and string.len(guildName) > 0)
end

-- 公会是否解散
function TimeLimitGuildCarnivalModel:IsGuildDismissed()
    local gid = self:GetGuildID()
    local guildName = self:GetGuildName()
    return tobool(string.len(gid) > 0 and string.len(guildName) <= 0)
end

-- 购买后更新
function TimeLimitGuildCarnivalModel:UpdateAfterPurchased(subID, num, addPoint)
    local singleData = self:GetActivitySingleData()
    -- 更新限购次数
    for index, commodity in pairs(singleData.list) do
        if commodity.subID == subID then
            commodity.buyNum = commodity.buyNum + num
            break
        end
    end
    -- 更新总积分
    singleData.guildPoint = singleData.guildPoint + addPoint
end

return TimeLimitGuildCarnivalModel
