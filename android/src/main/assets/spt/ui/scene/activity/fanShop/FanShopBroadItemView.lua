local ItemModel = require("ui.models.ItemModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local LimitType = require("ui.scene.itemList.LimitType")
local EquipModel = require("ui.models.EquipModel")
local FanShopBroadItemView = class(unity.base)

local FanCoinPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/FanShop/FanShop_Coin.png"

function FanShopBroadItemView:ctor()
    self.nameTxt = self.___ex.nameTxt
    self.oldPrice = self.___ex.oldPrice
    self.oldPriceTxt = self.___ex.oldPriceTxt
    self.itemParentTrans = self.___ex.itemParentTrans
    self.buyBtn = self.___ex.buyBtn
    self.priceTxt = self.___ex.priceTxt
    self.payTypeImg = self.___ex.payTypeImg
    self.payTypeImg1 = self.___ex.payTypeImg1
    self.timeTxt = self.___ex.timeTxt
    self.bgImg = self.___ex.bgImg
end

function FanShopBroadItemView:InitView(data)
    assert(data.contents)
    local id = nil
    local itemType = nil
    for k, v in pairs(data.contents) do
        itemType = k
        id = v[1].id
    end
    if itemType == "item" then
        self.nameTxt.text = ItemModel.new(id):GetName()
    elseif itemType == "card" then
        self.nameTxt.text = StaticCardModel.new(id):GetName()
    elseif itemType == "paster" then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(id)
        self.nameTxt.text = pasterModel:GetName()
    elseif itemType == "cardPiece" then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(id)
        local pieceTransText = lang.transstr("piece")
        if id == "generalPiece" then
            pieceTransText = ""
        end
        self.nameTxt.text = pieceTransText .. " " .. pieceModel:GetName()
    elseif itemType == "pasterPiece" then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.nameTxt.text = pieceModel:GetName()
    elseif itemType == "eqs" then
        self.nameTxt.text = EquipModel.new(id):GetName()
    end
    data.ordinalPrice = "200"
    if data.ordinalPrice ~= nil then
        self.oldPriceTxt.text = string.formatIntWithTenThousands(data.ordinalPrice)
    end
    GameObjectHelper.FastSetActive(self.oldPrice, data.ordinalPrice ~= nil)
    self.priceTxt.text = "x" .. string.formatIntWithTenThousands(data.fanCoinPrice)
    self.payTypeImg.overrideSprite = res.LoadRes(FanCoinPath)
    self.payTypeImg1.overrideSprite = res.LoadRes(FanCoinPath)
    if data.limitType == LimitType.DayLimit then
        self.timeTxt.text = lang.trans("giftbox_limit", data.limitAmount - data.buyCount, data.limitAmount)
    -- 整期活动限制 + 永久
    elseif data.limitType == LimitType.ForeverLimit then
        self.timeTxt.text = lang.trans("giftbox_limit_1", data.limitAmount - data.buyCount, data.limitAmount)
    elseif data.limitType == LimitType.NoLimit then
        GameObjectHelper.FastSetActive(self.timeTxt.gameObject, false)
    end

    res.ClearChildren(self.itemParentTrans)
    local rewardParams = {
        parentObj = self.itemParentTrans,
        rewardData = data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    self.buyBtn:regOnButtonClick(function ()
        if type(self.onClickBuy) == "function" then
            self.onClickBuy(data, 1, function(itemData)
                self:InitView(itemData)
            end)
        end
    end)
end

return FanShopBroadItemView