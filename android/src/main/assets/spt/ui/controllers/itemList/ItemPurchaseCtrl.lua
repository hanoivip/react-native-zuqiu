local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")

local ItemPurchaseCtrl = class(BaseCtrl)

ItemPurchaseCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/ItemPurchase.prefab"
ItemPurchaseCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

--[[
data = {
    -- 已购买次数
    boughtTime = 2,
    -- 货币类型
    currencyType = CurrencyType.Diamond,
    -- 道具的id
    itemId = 30037,
    -- 限购次数
    limitAmount = 0,
    -- 限购类型，对应枚举 LimitType
    limitType = 0,
    -- 购买弹板类型，对应枚举 ItemPlateType
    plateType = 5,
    -- 价格
    price = 10,
    -- 道具类型，用于选择model
    itemType = "item"
    -- 已按固定格式
    contents = {}
    -- 隐藏限购信息
    hideLimitText = false
    -- vip限购信息，vip的等级
    vip = 0
    -- 加号加满自定义提示
    tips = ""
    -- 附带信息，例公会嘉年华需要提示额外获得多少积分
    attachInfo = ""
    -- 所拥有的货币数量（可选）有些货币在全局无法获取到，比如 斗志 fight 士气 morale
    ownerCurrency = 100
}
--]]

function ItemPurchaseCtrl:Init(data, purchaseBtnCallback)
    self.view:InitView(data)
    self.view.purchaseBtn:regOnButtonClick(function ()
        local title = lang.transstr("tips")
        --默认购买数量为1
        local buyCount = 1
        if not self.view.isMultiPurchaseContentHidden then
            buyCount = self.view.numTxt and self.view.numTxt.text or 1
            buyCount = tonumber(buyCount)
        end

        local priceStr = ""
        if type(data.mulCurrencyTypes) == "table" and table.nums(data.mulCurrencyTypes) > 1 then
            if type(data.mulPrices) == "table" and table.nums(data.mulPrices) > 1 then
                for k, currency in pairs(data.mulCurrencyTypes) do
                    local currencyName = lang.transstr(CurrencyNameMap[currency])
                    local currencyCost = string.formatIntWithTenThousands(buyCount * tonumber(data.mulPrices[k]))
                    local prefix = priceStr == "" and "" or "、"
                    priceStr = priceStr .. prefix .. currencyName .. "x" .. currencyCost
                end
            end
        else
            local itemPrice = tonumber(data.price or 0)
            local currencyName = data.currencyType and lang.transstr(CurrencyNameMap[data.currencyType]) or lang.transstr("currency")
            local currencyCost = string.formatIntWithTenThousands(buyCount * itemPrice)
            priceStr = currencyName .. "x" .. currencyCost
        end

        local itemName = self.view.itemNameTxt and self.view.itemNameTxt.text or ""
        local content = lang.transstr("itemPurchase_buyTip", priceStr, itemName)
        DialogManager.ShowConfirmPop(title, content, function()
            self:BuyFunc(data, purchaseBtnCallback)
        end)
    end)
end

function ItemPurchaseCtrl:BuyFunc(data, purchaseBtnCallback)
    if data and data.vip then
        local playerInfo = cache.getPlayerInfo()
        local playerVipLevel = playerInfo.vip.lvl

        local callback = function ()
            self.view.closeDialog()
            res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", "charge")
        end

        if tonumber(data.vip) > tonumber(playerVipLevel) then
            local title = lang.transstr("tips")
            local str = self.view:GetBuyTipVIPStr(data.vip)
            local content = lang.transstr("timeLimit_giftBag_desc2", str)
            DialogManager.ShowConfirmPop(title, content, callback)
            return
        end
    end

    if data.currencyType == CurrencyType.Diamond then
        local playerInfoModel = PlayerInfoModel.new()
        local playerDiamondNum = playerInfoModel:GetDiamond()
        if data.price * self.view.number > tonumber(playerDiamondNum) then
            DialogManager.ShowConfirmPopByLang("tips", "store_gacha_tip_1", function() res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")end)
        else
            purchaseBtnCallback(self.view.number)
            self.view:Close()
        end
    elseif data.currencyType == CurrencyType.BlackDiamond then
        local bkdNum = PlayerInfoModel.new():GetBlackDiamond()
        if data.price * self.view.number > tonumber(bkdNum) then
            DialogManager.ShowConfirmPopByLang("tips", "store_gacha_tip_3", function() res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)end)
        else
            purchaseBtnCallback(self.view.number)
            self.view:Close()
        end
    elseif data.currencyType == CurrencyType.HonorDiamond then
        local isEnough, notEnoughTip = self.view:IsCurrencyEnough(false)
        if not isEnough then
            DialogManager.ShowToast(lang.trans("lack_item_tips", notEnoughTip))
            return
        else
            purchaseBtnCallback(self.view.number)
            self.view:Close()
        end
    elseif data.currencyType == CurrencyType.Money then
        local money = PlayerInfoModel.new():GetMoney()
        if data.price * self.view.number > tonumber(money) then
            DialogManager.ShowToast(lang.trans("goldCoinNotEnough"))
        else
            purchaseBtnCallback(self.view.number)
            self.view:Close()
        end
    else
        purchaseBtnCallback(self.view.number)
        self.view:Close()
    end
end

function ItemPurchaseCtrl:Refresh()
    ItemPurchaseCtrl.super.Refresh(self)
end

return ItemPurchaseCtrl