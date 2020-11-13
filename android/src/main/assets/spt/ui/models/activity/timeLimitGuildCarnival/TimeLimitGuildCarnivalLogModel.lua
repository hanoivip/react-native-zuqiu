local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")
local ItemType = require("ui.scene.itemList.ItemType")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local Model = require("ui.models.Model")

local TimeLimitGuildCarnivalLogModel = class(Model, "TimeLimitGuildCarnivalLogModel")

function TimeLimitGuildCarnivalLogModel:ctor()
    self.myRank = 0 -- 我的排名
    self.myPoint = 0 -- 我的积分总贡献
    self.rankList = {} -- 积分排行列表
    self.logList = {} -- 我的购买日志
end

function TimeLimitGuildCarnivalLogModel:HasRankData()
    return self.rankList ~= nil and table.nums(self.rankList) > 0
end

function TimeLimitGuildCarnivalLogModel:UpdateRankData(data)
    self.rankDataCache = data
    self.myRank = data.rank or 0
    self.myPoint = data.score or 0
    self.rankList = data.rankList or {}
    for index, v in pairs(self.rankList) do
        v.rank = index
    end
end

function TimeLimitGuildCarnivalLogModel:GetRankData()
    return self.rankList or {}
end

function TimeLimitGuildCarnivalLogModel:GetMyRank()
    return self.myRank or 0
end

function TimeLimitGuildCarnivalLogModel:GetMyPoint()
    return self.myPoint or 0
end

function TimeLimitGuildCarnivalLogModel:HasMyLogData()
    return self.logList ~= nil and table.nums(self.logList) > 0
end

function TimeLimitGuildCarnivalLogModel:UpdateMyLogData(data)
    self.logList = data.record or {}
    for index, log in pairs(self.logList) do
        local itemId = ""
        local itemNum = 0
        local itemType = ""
        for k, v in pairs(log.contents) do
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
        log.itemId = itemId
        log.itemNum = itemNum
        log.itemType = itemType
        log.itemName = itemName
    end
end

function TimeLimitGuildCarnivalLogModel:GetMyLogData()
    return self.logList
end

function TimeLimitGuildCarnivalLogModel:GetRankTitle()
    return lang.trans("time_limit_guild_carnival_log_rank")
end

function TimeLimitGuildCarnivalLogModel:GetLogTitle()
    return lang.trans("time_limit_guild_carnival_log_mylog")
end

return TimeLimitGuildCarnivalLogModel