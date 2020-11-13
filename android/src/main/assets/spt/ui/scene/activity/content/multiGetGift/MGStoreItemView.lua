local ItemPlateType = require("ui.scene.itemList.ItemPlateType")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local RewardNameHelper = require("ui.scene.itemList.RewardNameHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MGStoreItemView = class(unity.base)

function MGStoreItemView:ctor()
--------Start_Auto_Generate--------
    self.itemNameTxt = self.___ex.itemNameTxt
    self.itemLimitTxt = self.___ex.itemLimitTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
    self.rewardBtn = self.___ex.rewardBtn
    self.priceTxt = self.___ex.priceTxt
--------End_Auto_Generate----------
end

function MGStoreItemView:start()
    self.rewardBtn:regOnButtonClick(function()
        self:OnClickBtn()
    end)
end

function MGStoreItemView:InitView(storeData, multiGetGiftModel)
    self.model = multiGetGiftModel
    self.storeData = storeData
    local rewardName = RewardNameHelper.GetSingleContentName(storeData.contents)
    local buyCnt = storeData.buyCnt
    local limitStr, limitState = self:InitLimitTxt(storeData.limitType, buyCnt, storeData.limitAmount)
    self.priceTxt.text = "x" .. storeData.coinPrice
    self.itemNameTxt.text = rewardName
    self.itemLimitTxt.text = limitStr
    self:InitReward(storeData.contents)
end

function MGStoreItemView:InitReward(reward)
    res.ClearChildren(self.itemAreaTrans)
    local rewardParams = {
        parentObj = self.itemAreaTrans,
        rewardData = reward,
        isShowName = false,
        isReceive = false,
        isShowSymbol = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    RewardDataCtrl.new(rewardParams)
end

-- 初始化购买限制文本
function MGStoreItemView:InitLimitTxt(limitType, currAmount, limitAmount)
    self.limitState = true
    if limitType == 0 then     -- 不限购
        return ""
    elseif limitType == 1 then     -- 每日限购
        self.limitState = limitAmount - currAmount > 0
        return lang.trans("compete_store_limit1", limitAmount - currAmount, limitAmount)
    elseif limitType == 2 then     -- 整期活动限购
        self.limitState = limitAmount - currAmount > 0
        return lang.trans("compete_store_limit2", limitAmount - currAmount, limitAmount)
    else
        return ""
    end
end

function MGStoreItemView:OnClickBtn()
    local isTimeInActivity = self.model:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    if not self.limitState then
        DialogManager.ShowToastByLang("no_buy_times")
        return
    end
    local price = self.storeData.coinPrice
    local coin = self.model:GetCoin()
    if price > coin then
        local mes = lang.transstr("multi_get_coin")
        mes = lang.transstr("lack_item_tips", mes)
        DialogManager.ShowToast(mes)
        return
    end

    local itemType = nil
    local id = nil
    for k, v in pairs(self.storeData.contents) do
        itemType = k
        if type(v) == "number" then
            id = v
        else
            id = v[1].id
        end
    end
    -- 在这里弹出购买弹板
    local args = {
        currencyType = require("ui.models.itemList.CurrencyType").DayGiftCoin,
        price = price or 0,
        plateType = tonumber(self.storeData.plate),
        boughtTime = self.storeData.buyCnt,
        itemId = id,
        limitAmount = self.storeData.limitAmount,
        limitType = self.storeData.limitType,
        itemType = itemType,
        contents = self.storeData.contents,
        ownerCurrency = coin
    }

    local periodId = self.model:GetPeriodId()
    local function purchaseCallback(num)
        self:coroutine(function()
            local response = req.multiGetGiftBuyItem(periodId, self.storeData.subID, num)
            if api.success(response) then
                local data = response.val
                local rewards = data.contents
                CongratulationsPageCtrl.new(rewards)
                self.model:RefreshStoreData(data)
                self:InitView(self.storeData, self.model)
                EventSystem.SendEvent("MGStoreItemView_Buy")
            end
        end)
    end

    res.PushDialog("ui.controllers.itemList.ItemPurchaseCtrl", args, function (num)
        purchaseCallback(num)
    end)
end

return MGStoreItemView
