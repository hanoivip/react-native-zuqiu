local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local CurrencyNameMap = require("ui.models.itemList.CurrencyNameMap")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local AdventureShopCtrl = class(BaseCtrl, "AdventureShopCtrl")

AdventureShopCtrl.viewPath = ""

function AdventureShopCtrl:AheadRequest(eventModel)
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local response = req.greenswardAdventureOpenStore(row, col)
    if api.success(response) then
        local data = response.val
        eventModel:InitWithProtocol(data)
    end
end

function AdventureShopCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view.buyClick = function(data) self:OnBuyClick(data) end
end

function AdventureShopCtrl:Buy(id, num)
    local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
    self.view:coroutine(function ()
        local response = req.greenswardAdventureBuyStore(row, col, id, num)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
            local cost = data.cost
            local contents = data.contents
            local greenswardBuildModel = self.eventModel:GetBuildModel()
            greenswardBuildModel:RewardDetail(contents)
            greenswardBuildModel:CostDetail(cost)
            self.eventModel:InitWithProtocol(data.store)
            self:InitView(self.eventModel)
        end
    end)
end

function AdventureShopCtrl:OnBuyClick(data)
    local isCanBuyInBuyTime = self.eventModel:IsCanBuyInBuyTime()
    if not isCanBuyInBuyTime then
        DialogManager.ShowToastByLang("belatedGift_item_nil_time")
        return
    end
    local id = data.id
    local args = data.purchaseArgs
    if args.limitType ~= 0 and args.limitAmount - args.boughtTime <= 0 then
        DialogManager.ShowToastByLang("can_buy_is_full")
        return
    end
    local currencyType = data.purchaseArgs.currencyType
    local price = data.purchaseArgs.price
    local playerInfoModel = PlayerInfoModel.new()
    local isCostEnough = playerInfoModel:IsCostEnough(currencyType, price)
    if not isCostEnough then
        local currencyName = lang.transstr(CurrencyNameMap[currencyType])
        local tips = lang.trans("lack_item_tips", currencyName)
        if currencyType == CurrencyType.Diamond  then
            local callback = function() res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl") end
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip_1"), callback)
        elseif currencyType == CurrencyType.BlackDiamond then
            local callback = function() res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl") end
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_gacha_tip_3"), callback)
        elseif currencyType == CurrencyType.Morale then
            local callback = function() res.PushDialog("ui.controllers.greensward.GreenswardMoraleDialogCtrl", self.eventModel:GetBuildModel()) end
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("need_morale_enough2"), callback)
        else
            DialogManager.ShowToast(tips)
        end
        return
    end
    local ctrlPath = "ui.controllers.itemList.ItemPurchaseCtrl"
    res.PushDialog(ctrlPath, args, function(num) self:Buy(id, num) end)
end

-- virtual method
function AdventureShopCtrl:InitView(eventModel)

end

function AdventureShopCtrl:SetShopType(greenswardShopType)
    self.eventModel:SetShopType(greenswardShopType)
end

return AdventureShopCtrl
