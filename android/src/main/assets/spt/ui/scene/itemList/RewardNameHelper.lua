local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local EquipItemModel = require("ui.models.cardDetail.EquipItemModel")
local ItemModel = require("ui.models.cardDetail.ItemModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local MailRewardType = require("ui.scene.mail.MailRewardType")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local PlayerMedalModel = require("ui.models.medal.PlayerMedalModel")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local CoachItemMapModel = require("ui.models.coach.common.CoachItemMapModel")
local GreenswardItemModel = require("ui.models.greensward.item.GreenswardItemModel")
local FancyCardModel = require("ui.models.fancy.FancyCardModel")

local RewardNameHelper = {}

local SpecialItemTable = {
    ["m"] = "3",    -- 欧元
    ["d"] = "4",    -- 钻石
    ["sp"] = "5",   -- 体力
    ["exp"] = "6",  -- 玩家经验
    ["fp"] = "8",   -- 友情点
    ["lp"] = "9",   -- 天梯荣誉
    ["sd"] = "11",  -- 意志精华
    ["bs"] = "12",  -- 巨星气质
    ["pp"] = "13",  -- 巅峰币
    ["fan"] = "14", -- 球迷币
    ["dp"] = "20",  -- 梦幻卡包碎片
    ["dc"] = "21",  -- 梦幻币
    ["wtc"] = "23",  -- 豪门争霸币
    ["smd"] = "24",  -- 殿堂精华
    ["smb"] = "25",  -- 殿堂升阶石
    ["jxw"] = "26",  -- 吉祥物亲密度
    ["ce"] = "27",  -- 教练执教经验书
    ["ctp"] = "28", -- 教练天赋券
    ["ace"] = "29", -- 助理教练经验书
    ["morale"] = "31", -- [绿茵征途]士气
    ["fight"] = "32", -- [绿茵征途]斗志
    ["fs"] = "33", -- [梦幻卡]球魂
    ["fancyPiece"] = "34", -- [梦幻卡]梦幻卡碎片
}

function RewardNameHelper.GetTypeName(rewardTable, rewardType)
    if SpecialItemTable[rewardType] then
        local itemModel = ItemModel.new()
        itemModel:InitWithStaticId(SpecialItemTable[rewardType])
        return itemModel:GetName()
    end
    if rewardType == MailRewardType.Card then
        local cardModel = StaticCardModel.new(rewardTable.id)
        local perName = CardHelper.GetQualitySign(cardModel:GetCardFixQuality())
        return perName .. cardModel:GetName() .. lang.transstr("menu_players")
    end
    if rewardType == MailRewardType.CardPiece then
        local cardPieceModel = CardPieceModel.new()
        -- 配表碎片数据是id  奖励碎片数据是cid
        local id = rewardTable.id or rewardTable.cid
        cardPieceModel:InitWithStatic(id, rewardTable.num or 0)
        -- 万能碎片、传奇卡碎片等 cardPiece={id = generalPiece, num = xx}
        if cardPieceModel:IsUniversalPiece() then return cardPieceModel:GetName() end
        local perName = CardHelper.GetQualitySign(CardHelper.GetQualityFixed(cardPieceModel:GetQuality(), cardPieceModel:GetQualitySpecial()))
        local isUniversalPiece = cardPieceModel:IsUniversalPiece()
        local isLegendPiece = cardPieceModel:IsLegendPiece()
        perName = perName .. cardPieceModel:GetName()
        if isUniversalPiece then
            return perName
        elseif isLegendPiece then
            return cardPieceModel:GetOriginName()
        else
            return perName .. lang.transstr("piece")
        end
    end
    if rewardType == MailRewardType.Equipment then
        local equipItemModel = EquipItemModel.new()
        equipItemModel:InitWithStaticId(rewardTable.id)
        return equipItemModel:GetName()
    end
    if rewardType == MailRewardType.Item then
        local itemModel = ItemModel.new()
        itemModel:InitWithStaticId(rewardTable.id)
        return itemModel:GetName()
    end
    if rewardType == MailRewardType.EquipPiece then
        local equipItemModel = EquipItemModel.new()
        equipItemModel:InitWithStaticId(rewardTable.id)
        return equipItemModel:GetName() .. lang.transstr("itemList_equipPieceMenuItem")
    end
    if rewardType == MailRewardType.Paster then
        local cardPasterModel = CardPasterModel.new()
        local newData = {ptcid = rewardTable.id, add = rewardTable.num or 0}
        cardPasterModel:InitWithCache(newData)
        return cardPasterModel:GetName()
    end
    if rewardType == MailRewardType.PasterPiece then
        local cardPasterPieceModel = CardPasterPieceModel.new()
        -- 配表贴纸数据是id  奖励贴纸数据是type
        local id = rewardTable.id or rewardTable.type
        cardPasterPieceModel:InitWithStatic(id, rewardTable.num or 0)
        return cardPasterPieceModel:GetName()
    end
    if rewardType == MailRewardType.Medal then
        local medalModel = PlayerMedalModel.new()
        medalModel:InitWithStatic(rewardTable.id)
        return medalModel:GetName()
    end
    if rewardType == MailRewardType.CoachItem then -- 教练道具
        local coachItemMapModel = CoachItemMapModel.new()
        local coachItemModel = coachItemMapModel:GetCoachItemModelById(rewardTable.id)
        return coachItemModel:GetName()
    end
    if rewardType == MailRewardType.AdvItem then -- 绿茵征途道具
        local advItemModel = GreenswardItemModel.new(rewardTable.id)
        return advItemModel:GetName()
    end
    if rewardType == MailRewardType.FancyCard then -- 梦幻卡
        local advItemModel = FancyCardModel.new()
        advItemModel:InitData(rewardTable.id)
        return advItemModel:GetName()
    end
    return ""
end

function RewardNameHelper.GetSingleContentName(contents)
    local mType = contents and next(contents)
    local rewardTable = contents and contents[mType]
    if type(rewardTable) ~= "table" then
        rewardTable = {}
    end
    local name = " " .. RewardNameHelper.GetTypeName(next(rewardTable) and rewardTable[1], mType)
    return name
end

return RewardNameHelper