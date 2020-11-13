local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local SettingsCtrl = require("ui.controllers.settings.SettingsCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local DialogMultipleConfirmation = require("ui.control.manager.DialogMultipleConfirmation")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GiftBoxItemPopCtrl = class(BaseCtrl, "GiftBoxItemPopCtrl")

GiftBoxItemPopCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

GiftBoxItemPopCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Store/GiftBoxPopBoard.prefab"

local BuySuitSuccessLangKey = "buy_%s_success"

function GiftBoxItemPopCtrl:Init(model)
    self.model = model
    self.view.buyGiftBox = function() self:BuyGiftBox() end
    self.view:InitView(model)
end

function GiftBoxItemPopCtrl:BuyGiftBox()
    -- 豪门币不走支付SDK
    local isRMB = self.model:GetPayType()
    isRMB = tonumber(isRMB) == 1
    if isRMB then
        if luaevt.trig("HasPurchaseSystem") then
            luaevt.trig("Do_Pay_Special", self.model, self)
        else
            local initResp = req.buyGiftBox(self.model:GetID())
            if api.success(initResp) then
                local orderId = initResp.val.order_id
                local testResp = req.payTest(orderId)
                if api.success(testResp) then
                    self:BuyGiftBoxSuccess(testResp.val.contents, testResp.val.vip)
                    -- TODO 本地测试
                end
            end
        end
    else
        local price = self.model:GetPrice()
        local bkd = PlayerInfoModel.new():GetBlackDiamond()
        if tonumber(price) > tonumber(bkd) then
            DialogManager.ShowConfirmPop(lang.trans("tips"), lang.trans("store_bkd_not_enough"), function ()
                res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl", nil, nil, true)
            end)
            return
        end
		local confirmCallback = function()
			clr.coroutine(function ()
				local response = req.buyGiftBoxByBlackDiamond(self.model:GetID())
				if api.success(response) then
					PlayerInfoModel.new():SetBlackDiamond(response.val.bkd)
					self:BuyGiftBoxSuccess(response.val.contents, response.val.vip)
				end
			end)
		end
		DialogMultipleConfirmation.MultipleConfirmation(lang.trans("tips"), lang.trans("comfirm_tips"), confirmCallback)
    end
end

function GiftBoxItemPopCtrl:BuyGiftBoxSuccess(contents, vip)
    self.model:SetBuyCounter(1)
    self.view:InitBtnState(self.model:IsCanBuy())
    local specialSuit = self.model:IsSpecial()
    if specialSuit ~= "" then
        local content = lang.trans(format(BuySuitSuccessLangKey, specialSuit))
        -- 在购买完拜仁或皇马套装后，可以直接跳转到设置界面
        DialogManager.ShowConfirmPop(lang.trans("buy_item_success"), content, function ()
            clr.coroutine(function ()
                local response = req.setting()
                if api.success(response) then
                    local data = response.val
                    SettingsCtrl.new(data)
                    self.view:Close()
                end
            end)
        end)
    else
        CongratulationsPageCtrl.new(contents)
    end

    EventSystem.SendEvent("BuyStoreItem")
end

function GiftBoxItemPopCtrl:GetStatusData()
    return self.model
end

return GiftBoxItemPopCtrl
