local BaseCtrl = require("ui.controllers.BaseCtrl")
local EventGiftBoxCtrl = class(BaseCtrl, "EventGiftBoxCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local EventGiftBoxModel = require("ui.models.eventGiftBox.EventGiftBoxModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
EventGiftBoxCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/EventGiftBox/EventGiftBox.prefab"

function EventGiftBoxCtrl:Init()
    self.model = EventGiftBoxModel.new()
end

function EventGiftBoxCtrl:Refresh()
    self.view:InitView(self.model)
    self.view.onClickPurchase = function(data) self:OnClickPurchase(data) end
end

--判斷是否過期
function EventGiftBoxCtrl:IsOver(item)
    return self.model:GetLastTime(item) <= 0
end

-- 购买按钮事件函数
function EventGiftBoxCtrl:OnClickPurchase(data)
    if data.limitCount - data.buyCnt <= 0 then
        DialogManager.ShowToastByLang("can_buy_is_full")
        return
    end
    local currencyType = data.currencyType
    local price = data.price
    local playerInfoModel = PlayerInfoModel.new()
    local isCostEnough = playerInfoModel:IsCostEnough(currencyType, price)
    if not isCostEnough then
        local currencyName = lang.transstr(CurrencyNameMap[currencyType])
        local tips = lang.trans("lack_item_tips", currencyName)
        local callback = function() self:ToCharge(data) end
        if currencyType == CurrencyType.Diamond  then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip_1"), callback)
        elseif currencyType == CurrencyType.BlackDiamond then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip_3"), callback)
        else
            DialogManager.ShowToast(tips)
        end
        return
    end
    local title = lang.transstr("tips")
    local currencyName = lang.transstr(CurrencyNameMap[data.currencyType])
    local currencyCost = string.formatIntWithTenThousands(data.price)
    local content = lang.transstr("itemPurchase_buyTip", currencyName .. "x" .. currencyCost, data.name)
    DialogManager.ShowConfirmPop(title, content, function()
        if self:IsOver(data) then
            DialogManager.ShowToastByLang("event_time_Over")
            return
        end
        self:Buy(data)
    end)
end

function EventGiftBoxCtrl:ToCharge(item)
    if self:IsOver(item) then
        DialogManager.ShowToastByLang("event_time_Over")
        return
    end
    if item.currencyType == CurrencyType.Diamond or item.currencyType == CurrencyType.BlackDiamond then
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    else
        DialogManager.ShowToast(tips)
    end
end

function EventGiftBoxCtrl:Buy(item)
    self.view:coroutine(function ()
        local response = req.eventGiftBagBuy(item.id)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            local cost = data.cost
            if cost.type == CurrencyType.Diamond then
                PlayerInfoModel.new():SetDiamond(cost.curr_num)
            elseif cost.type == CurrencyType.Money then
                PlayerInfoModel.new():SetMoney(cost.curr_num)
            elseif cost.type == CurrencyType.BlackDiamond then
                PlayerInfoModel.new():SetBlackDiamond(cost.curr_num)
            end
            item.buyCnt = item.buyCnt + 1
            self.view:RefreshBuyInfo()
            EventSystem.SendEvent("EventGiftBox_Change")
        end
    end)
end

return EventGiftBoxCtrl