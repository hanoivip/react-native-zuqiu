local ItemModel = require("ui.models.ItemModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")
local Vector2 = clr.UnityEngine.Vector2
local TimeLimitGiftBoxItemView = class(unity.base)

local diamondPath = "Assets/CapstonesRes/Game/UI/Common/Images/Common/Icon_Diamond.png"
local goldPath = "Assets/CapstonesRes/Game/UI/Common/Images/Common/Icon_Gold.png"
local bgPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Image/GiftBox/GiftBoxBg%s.png"

function TimeLimitGiftBoxItemView:ctor()
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

    self.vipAreaObj = self.___ex.vipAreaObj
    self.vipNumText = self.___ex.vipNumText
    self.vipRect = self.___ex.vipRect
end

function TimeLimitGiftBoxItemView:SetVipNumActive(isDIgit, isLargerThanTen)
    GameObjectHelper.FastSetActive(self.vipNum.gameObject, isDIgit)
    GameObjectHelper.FastSetActive(self.vipNum1.gameObject, isLargerThanTen)
    GameObjectHelper.FastSetActive(self.vipNum2.gameObject, isLargerThanTen)
end

function TimeLimitGiftBoxItemView:InitView(data)
    if not data or not data.vip or data.vip == 0 then
        GameObjectHelper.FastSetActive(self.vipAreaObj, false)
    else
        GameObjectHelper.FastSetActive(self.vipAreaObj, true)
        self.vipNumText.text = tostring(data.vip)
        local posX = data.vip < 10 and 6 or 0
        self.vipRect.anchoredPosition = Vector2(posX, 0)
    end

    assert(data.contents)
    local id = nil
    local itemType = nil
    for k, v in pairs(data.contents) do
        itemType = k
        id = v[1].id
    end
    if itemType == "item" then
        self.nameTxt.text = ItemModel.new(id):GetName()
    end
    if itemType == "card" then
        self.nameTxt.text = StaticCardModel.new(id):GetName()
    end
    if itemType == "paster" then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(id)
        self.nameTxt.text = pasterModel:GetName()
    end
    if itemType == "cardPiece" then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.nameTxt.text = pieceModel:GetName() .. lang.transstr("piece")
    end
    if itemType == "pasterPiece" then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.nameTxt.text = pieceModel:GetName()
    end
    if itemType == "eqs" then
        self.nameTxt.text = EquipModel.new(id):GetName()
    end
    if data.ordinalPrice ~= nil then
        self.oldPriceTxt.text = string.formatIntWithTenThousands(data.ordinalPrice)
    end
    GameObjectHelper.FastSetActive(self.oldPrice, data.ordinalPrice ~= nil)
    self.priceTxt.text = "x" .. string.formatIntWithTenThousands(data.price)
    self.payTypeImg.overrideSprite = res.LoadRes(CurrencyImagePath[data.currencytype])
    self.payTypeImg1.overrideSprite = res.LoadRes(CurrencyImagePath[data.currencytype])
    self.bgImg.overrideSprite = res.LoadRes(format(bgPath, data.baseboard))
    -- 每日限制
    if data.limitType == 1 then
        self.timeTxt.text = lang.trans("giftbox_limit", data.limitAmount - data.buyCount, data.limitAmount)
    -- 整期活动限制
    elseif data.limitType == 2 then
        self.timeTxt.text = lang.trans("giftbox_limit_1", data.limitAmount - data.buyCount, data.limitAmount)
    -- 不限制
    elseif data.limitType == 0 then
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
            self.onClickBuy()
        end
    end)
end

return TimeLimitGiftBoxItemView