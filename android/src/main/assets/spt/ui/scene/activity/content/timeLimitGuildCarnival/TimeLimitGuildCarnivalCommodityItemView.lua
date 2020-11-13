local GameObjectHelper = require("ui.common.GameObjectHelper")
local LimitType = require("ui.scene.itemList.LimitType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local TimeLimitGuildCarnivalCommodityItemView = class(unity.base, "TimeLimitGuildCarnivalCommodityItemView")

function TimeLimitGuildCarnivalCommodityItemView:ctor()
    -- 奖励容器
    self.itemRct = self.___ex.itemRct
    -- 购买后积分奖励
    self.txtPoint = self.___ex.txtPoint
    -- 限购文本
    self.txtLimit = self.___ex.txtLimit
    -- 物品名称
    self.txtName = self.___ex.txtName
    -- 原价
    self.txtOriginPrice = self.___ex.txtOriginPrice
    self.txtOriginPriceNum = self.___ex.txtOriginPriceNum
    -- 价格
    self.txtPrice = self.___ex.txtPrice
    -- 购买按钮
    self.btnPurchase = self.___ex.btnPurchase
    -- 货币图标
    self.iconCurrency = self.___ex.iconCurrency
    -- 原价货币图标
    self.oIconCurrency = self.___ex.oIconCurrency
end

function TimeLimitGuildCarnivalCommodityItemView:start()
    self:BindAll()
end

function TimeLimitGuildCarnivalCommodityItemView:InitView(data)
    self.data = data
    -- 物品图标
    self:InitItemArea()
    -- 积分
    self.txtPoint.text = lang.transstr("score") .. "  " .. data.guildPoint
    -- 物品名称
    self.txtName.text = self.data.itemName
    -- 原价
    GameObjectHelper.FastSetActive(self.txtOriginPrice.gameObject, tonumber(data.ordinalPrice) > 0)
    self.txtOriginPrice.text = lang.transstr("untranslated_2275")
    self.txtOriginPriceNum.text = tostring(data.ordinalPrice)
    -- 货币图标
    self:InitCurrencyType()
    -- 价格
    self.txtPrice.text = "X" .. tostring(data.price)
    -- 限购
    self.txtLimit.text = self:InitLimitTxt(tonumber(self.data.limitType), self.data.buyNum, self.data.limitAmount)
end

function TimeLimitGuildCarnivalCommodityItemView:BindAll()
    self.btnPurchase:regOnButtonClick(function()
        self:OnClickPurchase()
    end)
end

-- 初始化货币类型
function TimeLimitGuildCarnivalCommodityItemView:InitCurrencyType()
    local icon = res.LoadRes(CurrencyImagePath[self.data.currencytype])
    self.iconCurrency.overrideSprite = icon
    self.oIconCurrency.overrideSprite = icon
end

-- 初始化物品图标及名称
function TimeLimitGuildCarnivalCommodityItemView:InitItemArea()
    assert(self.data.contents, "data.contents is nil")

    res.ClearChildren(self.itemRct)
    local rewardParams = {
        parentObj = self.itemRct,
        rewardData = self.data.contents,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

-- 初始化购买限制文本
function TimeLimitGuildCarnivalCommodityItemView:InitLimitTxt(limitType, currAmount, limitAmount)
    if limitType == LimitType.NoLimit then-- 不限购
        return lang.trans("time_limit_guild_carnival_guild_limit_1")
    elseif limitType == LimitType.DayLimit then-- 每日限购
        return lang.trans("time_limit_guild_carnival_guild_limit_2", limitAmount - currAmount, limitAmount)
    elseif limitType == LimitType.ForeverLimit then-- 整期活动限购
        return lang.trans("time_limit_guild_carnival_guild_limit_3", limitAmount - currAmount, limitAmount)
    else
        return ""
    end
end

-- 购买按钮事件函数
function TimeLimitGuildCarnivalCommodityItemView:OnClickPurchase()
    if self.data.limitAmount - self.data.buyNum <= 0 then
        DialogManager.ShowToastByLang("can_buy_is_full")
        return
    end

    local args = {
        boughtTime = self.data.buyNum,
        limitAmount = self.data.limitAmount,
        itemId = self.data.itemId,
        currencyType = self.data.currencytype,
        price = self.data.price,
        limitType = self.data.limitType,
        plateType = tonumber(self.data.plate),
        itemType = self.data.itemType,
        attachInfo = lang.transstr("time_limit_guild_carnival_commody_attach_point", self.data.guildPoint)
    }

    local BuyCallback = function(num)
        EventSystem.SendEvent("GuildCarnival_PurchaseItem", self.data.subID, num)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function(num) BuyCallback(num) end)
end


return TimeLimitGuildCarnivalCommodityItemView