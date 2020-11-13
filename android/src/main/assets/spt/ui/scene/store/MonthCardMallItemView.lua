local GameObjectHelper = require("ui.common.GameObjectHelper")
local LimitType = require("ui.scene.itemList.LimitType")
local ItemModel = require("ui.models.ItemModel")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardPasterModel = require("ui.models.cardDetail.CardPasterModel")
local CardPieceModel = require("ui.models.cardDetail.CardPieceModel")
local CardPasterPieceModel = require("ui.models.cardDetail.CardPasterPieceModel")
local EquipModel = require("ui.models.EquipModel")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local MonthCardType = require("ui.models.store.MonthCardType")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local MonthCardMallItemView = class(unity.base, "MonthCardMallItemView")

function MonthCardMallItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtLimit = self.___ex.txtLimit
    self.btnBuy = self.___ex.btnBuy
    self.txtPrice = self.___ex.txtPrice
    self.iconCurrency = self.___ex.iconCurrency
    self.itemArea = self.___ex.itemArea
    self.specialCornerObj = self.___ex.specialCornerObj
    self.txtSpecialCorner = self.___ex.txtSpecialCorner
    self.monthCardType = self.___ex.monthCardType
end

function MonthCardMallItemView:start()
    self.btnBuy:regOnButtonClick(function()
        if self.onClickBuy ~= nil and type(self.onClickBuy) == "function" then
            self.onClickBuy()
        end
    end)
end

function MonthCardMallItemView:InitView(itemData)
    GameObjectHelper.FastSetActive(self.specialCornerObj, false)
    self.data = itemData
    self:InitItemArea()
    self.txtLimit.text = self:InitLimitTxt(tonumber(self.data.limitType), self.data.cnt, self.data.limitAmount)
    self.txtPrice.text = tostring(self.data.price)
    self:InitCurrencyType()
    self:InitMonthCardType()
end

-- 初始化购买限制文本
function MonthCardMallItemView:InitLimitTxt(limitType, currAmount, limitAmount)
    if limitType == LimitType.NoLimit then-- 不限购
        return ""
    elseif limitType == LimitType.DayLimit then-- 每日限购
        return lang.trans("giftbox_limit", limitAmount - currAmount, limitAmount)
    elseif limitType == LimitType.ForeverLimit then-- 整期活动限购
        return lang.trans("month_card_buy_limit_2", limitAmount - currAmount, limitAmount)
    else
        return "limit type error"
    end
end

-- 初始化货币类型
function MonthCardMallItemView:InitCurrencyType()
    self.iconCurrency.overrideSprite = res.LoadRes(CurrencyImagePath[self.data.currencytype])
end

-- 初始化物品图标
function MonthCardMallItemView:InitItemArea()
    assert(self.data.itemID, "data.itemId is nil")

    local id = nil
    local num = nil
    local itemType = self.data.itemType
    local content = {}
    content[itemType] = {}
    for k, v in pairs(self.data.itemID) do
        id = v.id
        num = v.num
        table.insert(content[itemType], v)
    end

    if itemType == "item" then
        self.txtName.text = ItemModel.new(id):GetName()
    elseif itemType == "card" then
        self.txtName.text = StaticCardModel.new(id):GetName()
    elseif itemType == "paster" then
        local pasterModel = CardPasterModel.new()
        pasterModel:InitWithStatic(id)
        self.txtName.text = pasterModel:GetName()
    elseif itemType == "cardPiece" then
        local pieceModel = CardPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.txtName.text = pieceModel:GetName() .. lang.transstr("piece")
    elseif itemType == "pasterPiece" then
        local pieceModel = CardPasterPieceModel.new()
        pieceModel:InitWithStatic(id)
        self.txtName.text = pieceModel:GetName()
    elseif itemType == "eqs" then
        self.txtName.text = EquipModel.new(id):GetName()
    end

    res.ClearChildren(self.itemArea)
    local rewardParams = {
        parentObj = self.itemArea,
        rewardData = content,
        isShowName = false,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)

    local args = {
        boughtTime = self.data.cnt,
        limitAmount = self.data.limitAmount,
        itemId = id,
        currencyType = self.data.currencytype,
        price = self.data.price,
        limitType = self.data.limitType,
        plateType = tonumber(self.data.plate),
        itemType = itemType
    }

    self.onClickBuy = (function()
        -- 限购
        if self.data.limitAmount - self.data.cnt <= 0 and self.data.limitType ~= 0 then
            DialogManager.ShowToast(lang.trans("can_buy_is_full"))
            return
        end
        -- 月卡限制
        local title = lang.trans("tips")
        local msg = nil
        local confirmCallback = nil
        if table.nums(self.data.monthCardType) <= 1 then
            local monthCardType = nil
            for k, v in pairs(self.data.monthCardType) do
                monthCardType = tonumber(v)
            end
            if monthCardType == MonthCardType.MonthCardMap.Normal_MonthCard.configID then-- 月卡限购
                if not self.data.isMonthCard then-- 不允许购买
                    msg = lang.trans("month_card_buy_month_card_tip")
                    confirmCallback = function() self:GotoChargeAndVIP() end
                    DialogManager.ShowConfirmPop(title, msg, confirmCallback, nil)
                    return
                end
            end
            if monthCardType == MonthCardType.MonthCardMap.Supreme_MonthCard.configID then-- 至尊月卡限购
                if not self.data.isSupremeMonthCard then-- 不允许购买
                    msg = lang.trans("month_card_buy_month_card_supreme_tip")
                    confirmCallback = function() self:GotoSupremeMonthCard() end
                    DialogManager.ShowConfirmPop(title, msg, confirmCallback, nil)
                    return
                end
            end
        else-- 月卡/至尊月卡均可购买
            if not self.data.isMonthCard and not self.data.isSupremeMonthCard then
                msg = lang.trans("month_card_buy_month_card_tip")
                confirmCallback = function() self:GotoChargeAndVIP() end
                DialogManager.ShowConfirmPop(title, msg, confirmCallback, nil)
                return
            end
        end
        res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args,
            function(num)
                self:BuyCallback(num)
            end)
    end)
end

function MonthCardMallItemView:BuyCallback(num)
    clr.coroutine(function()
        local response = req.monthCardShopBuy(self.data.id, num)
        if api.success(response) then
            local data = response.val
            EventSystem.SendEvent("monthCardMall.refreshAfterBought", self.data.id, data.cnt)
            CongratulationsPageCtrl.new(data.gift)
            local cost = data.cost
            if cost.type == CurrencyType.Money then-- 欧元
                PlayerInfoModel.new():SetMoney(cost.curr_num)
            elseif cost.type == CurrencyType.Diamond then-- 钻石
                PlayerInfoModel.new():SetDiamond(cost.curr_num)
            elseif cost.type == CurrencyType.BlackDiamond then-- 豪门币
                PlayerInfoModel.new():SetBlackDiamond(cost.curr_num)
            else
                dump("illegal currency type, please check the config")
            end
        end
    end)
end

-- 初始化月卡类型
function MonthCardMallItemView:InitMonthCardType()
    if table.nums(self.data.monthCardType) <= 1 then
        local monthCardType = nil
        for k, v in pairs(self.data.monthCardType) do
            monthCardType = tonumber(v)
        end
        self.monthCardType.text = lang.trans(MonthCardType.MonthCardMap[MonthCardType.MonthCardConfigMap[monthCardType]].name)
    else-- 月卡/至尊月卡均可购买
        self.monthCardType.text = lang.trans("month_card_all")
    end
end

function MonthCardMallItemView:GotoChargeAndVIP()
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
end

function MonthCardMallItemView:GotoSupremeMonthCard()
    EventSystem.SendEvent("gotoSupremeMonthCard")
end

return MonthCardMallItemView
