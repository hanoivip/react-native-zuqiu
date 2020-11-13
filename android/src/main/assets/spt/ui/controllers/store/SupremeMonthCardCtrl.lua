local BaseCtrl = require("ui.controllers.BaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local SupremeMonthCardCtrl = class(BaseCtrl, "SupremeMonthCardCtrl")

SupremeMonthCardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

SupremeMonthCardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/SupremeMonthCardBoard.prefab"

function SupremeMonthCardCtrl:Init(model)
    self.model = model
    self.view.buyGiftBox = function() 
        DialogManager.ShowConfirmPop(lang.transstr("guild_homeTipTitle2"),  lang.transstr("untranslated_2737", model:GetPrice()), 
            function()
                self:BuyGiftBox() 
            end)
    end
    self.view:InitView(model)
end

function SupremeMonthCardCtrl:BuyGiftBox()
    local isRMB = self.model:GetPayType()
    isRMB = tonumber(isRMB) == 1
    if not isRMB then
        local price = self.model:GetPrice()
        local bkd = PlayerInfoModel.new():GetBlackDiamond()
        if tonumber(price) > tonumber(bkd) then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_bkd_not_enough"), function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
            end)
            return
        end
        clr.coroutine(function()
            local response = req.buyGiftBoxByBlackDiamond(self.model:GetID())
            if api.success(response) then
                PlayerInfoModel.new():SetBlackDiamond(response.val.bkd)
                self:BuyGiftBoxSuccess(response.val.contents, response.val.vip)
            end
        end)
    end
end

function SupremeMonthCardCtrl:BuyGiftBoxSuccess(contents, vip)
    DialogManager.ShowToastByLang("buy_item_success")
    EventSystem.SendEvent("BuyStoreItem")
end

function SupremeMonthCardCtrl:GetStatusData()
    return self.model
end

return SupremeMonthCardCtrl
