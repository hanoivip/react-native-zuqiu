local LimitType = require("ui.scene.itemList.LimitType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AdventureStoreItem = class(unity.base)

function AdventureStoreItem:ctor()
--------Start_Auto_Generate--------
    self.itemNameTxt = self.___ex.itemNameTxt
    self.itemBuyTimesTxt = self.___ex.itemBuyTimesTxt
    self.buyBtn = self.___ex.buyBtn
    self.priceTxt = self.___ex.priceTxt
    self.currencyImg = self.___ex.currencyImg
    self.itemTrans = self.___ex.itemTrans
    self.ordinalPriceGo = self.___ex.ordinalPriceGo
    self.currencyOrdinalImg = self.___ex.currencyOrdinalImg
    self.ordinalPriceTxt = self.___ex.ordinalPriceTxt
--------End_Auto_Generate----------
end

function AdventureStoreItem:start()
    self.buyBtn:regOnButtonClick(function()
        self:OnBuyClick()
    end)
end

function AdventureStoreItem:InitView(itemData)
    self.itemNameTxt.text = tostring(itemData.id)
    local contents = itemData.staticData.contents
    local currencyType = itemData.staticData.currencyType
    local limitType = itemData.staticData.limitType
    local currAmount = itemData.buy
    local limitAmount = itemData.staticData.limitAmount
    local price = itemData.staticData.price
    local ordinalPrice = tonumber(itemData.staticData.ordinalPrice)
    local rewardName =RewardNameHelper.GetSingleContentName(contents)
    local limitStr = self:InitLimitTxt(limitType, currAmount, limitAmount)

    self.currencyImg.overrideSprite = res.LoadRes(CurrencyImagePath[currencyType])
    self.currencyOrdinalImg.overrideSprite = res.LoadRes(CurrencyImagePath[currencyType])
    self.itemNameTxt.text = rewardName
    local priceTxt = string.formatNumWithUnit(price)
    local ordinalPriceTxt = string.formatNumWithUnit(ordinalPrice)
    self.priceTxt.text = "x"  .. priceTxt
    self.ordinalPriceTxt.text = "x"  .. ordinalPriceTxt
    self.itemBuyTimesTxt.text = limitStr
    GameObjectHelper.FastSetActive(self.ordinalPriceGo, ordinalPrice > 0)
    GameObjectHelper.FastSetActive(self.itemBuyTimesTxt.gameObject, limitStr ~= "")

    local rewardParams = {
        parentObj = self.itemTrans,
        rewardData = contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    res.ClearChildren(self.itemTrans)
    RewardDataCtrl.new(rewardParams)
end

-- 初始化购买限制文本
function AdventureStoreItem:InitLimitTxt(limitType, currAmount, limitAmount)
    if limitType == LimitType.NoLimit then-- 不限购
        return lang.trans("time_limit_guild_carnival_guild_limit_1")
    elseif limitType == LimitType.DayLimit then-- 每日限购
        return lang.trans("time_limit_guild_carnival_guild_limit_2", limitAmount - currAmount, limitAmount)
    elseif limitType == LimitType.ForeverLimit or -- 整期活动限购
            limitType == LimitType.TimeLimit or
            limitType == LimitType.ExistLimit or
            limitType == LimitType.PlayerLimit then
        return lang.trans("time_limit_guild_carnival_guild_limit_3", limitAmount - currAmount, limitAmount)
    else
        return ""
    end
end

function AdventureStoreItem:OnBuyClick()
    if self.buyClick then
        self.buyClick()
    end
end

return AdventureStoreItem
