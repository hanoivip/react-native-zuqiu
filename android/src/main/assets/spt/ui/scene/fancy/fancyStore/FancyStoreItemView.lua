local Vector3 = clr.UnityEngine.Vector3
local LimitType = require("ui.scene.itemList.LimitType")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local ItemType = require("ui.scene.itemList.ItemType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local FancyStoreItemView = class(unity.base)

function FancyStoreItemView:ctor()
--------Start_Auto_Generate--------
    self.itemNameTxt = self.___ex.itemNameTxt
    self.itemBuyTimesTxt = self.___ex.itemBuyTimesTxt
    self.buyBtn = self.___ex.buyBtn
    self.currencyImg = self.___ex.currencyImg
    self.priceTxt = self.___ex.priceTxt
    self.itemTrans = self.___ex.itemTrans
--------End_Auto_Generate----------
    self.itemLayout = self.___ex.itemLayout
end

function FancyStoreItemView:start()
    self.buyBtn:regOnButtonClick(function()
        self:OnBuyClick()
    end)
end

function FancyStoreItemView:InitView(itemData)
    self.periodId = itemData:GetID()
    self.plateType = itemData:GetPlate()
    self.currencyType = itemData:GetCurrencyType()
    self.limitType = itemData:GetLimitType()
    self.limitAmount = itemData:GetLimitAmount()
    self.currAmount = itemData:GetCnt()
    self.price = itemData:GetPrice()
    self.currencyImg.overrideSprite = res.LoadRes(CurrencyImagePath[self.currencyType])
    local priceTxt = string.formatNumWithUnit(self.price)
    self.priceTxt.text = "x"  .. priceTxt
    local limitStr = self:InitLimitTxt(self.limitType, self.currAmount, self.limitAmount)
    self.itemBuyTimesTxt.text = limitStr
    self.subId = itemData:GetSubID()
    self.goodsType = itemData:GetGoodsType()
    self.goodsId = itemData:GetGoodsID()
    self.goodsNum = itemData:GetCount()
    self.contents = {}
    self.contents[self.goodsType] = {}
    table.insert(self.contents[self.goodsType], {id = self.goodsId, num = self.goodsNum})
    local rewardName = RewardNameHelper.GetSingleContentName(self.contents)
    self.itemNameTxt.text = string.sub(rewardName, 2, #rewardName)
    if self.goodsType == ItemType.FancyCard then
        self.itemTrans.localScale = Vector3(1.18, 1.18, 1)
        self.itemLayout.padding.left = -16
    else
        self.itemTrans.localScale = Vector3(1, 1, 1)
        self.itemLayout.padding.left = 0
    end
    local rewardParams = {
        parentObj = self.itemTrans,
        rewardData = self.contents,
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
        hideCount = true,
    }
    res.ClearChildren(self.itemTrans)
    RewardDataCtrl.new(rewardParams)
end

-- 限购提示
function FancyStoreItemView:InitLimitTxt(limitType, currAmount, limitAmount)
    self.currAmount = currAmount
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

-- 购买响应
function FancyStoreItemView:OnBuyClick()
    local canBuy = self.limitAmount > self.currAmount or self.limitAmount == 0
    if not canBuy then
        DialogManager.ShowToast(lang.trans("peak_bought_time_none"))
        return
    end
    -- 购买弹板
    local args = {
        currencyType = self.currencyType,
        price = self.price or 0,
        plateType = self.plateType,
        boughtTime = self.currAmount,
        itemId = self.goodsId,
        limitAmount = self.limitAmount,
        limitType = self.limitType,
        itemType = self.goodsType,
        contents = self.contents
    }
    -- 购买回调
    local function purchaseCallback(num)
        clr.coroutine(function()
            local respone = req.fancyCardMallBuy(self.periodId, self.subId, num)
            if api.success(respone) then
                local data = respone.val
                if data.contents then
                    CongratulationsPageCtrl.new(data.contents) 
                end
                if data.cost then
                    if data.cost.type == CurrencyType.Fs then
                        PlayerInfoModel.new():SetFs(data.cost.curr_num)
                    elseif data.cost.type == CurrencyType.FancyPiece then
                        PlayerInfoModel.new():SetFancyPiece(data.cost.curr_num)
                    end
                end
                if self.limitAmount ~= 0 then
                    local limitStr = self:InitLimitTxt(self.limitType, self.currAmount + num, self.limitAmount)
                    self.itemBuyTimesTxt.text = limitStr
                end
            end
        end)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function (num)
        purchaseCallback(num)
    end)
end

return FancyStoreItemView
