local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local CustomEvent = require("ui.common.CustomEvent")
local EventSystem = require("EventSystem")
local ChargeConfirmView = class(unity.base)

function ChargeConfirmView:ctor()
    self.closeBtn = self.___ex.closeBtn

    self.chargeItem = self.___ex.chargeItem

    self.itemDetail = self.___ex.itemDetail
    self.detailBoard = self.___ex.detailBoard

    self.baseDiamond = self.___ex.baseDiamond
    self.extraDiamond = self.___ex.extraDiamond
    self.totalDiamond = self.___ex.totalDiamond
    self.extraDiamondText = self.___ex.extraDiamondText

    self.full18Btn = self.___ex.full18Btn
    self.notFull18Btn = self.___ex.notFull18Btn
    self.lawBtn = self.___ex.lawBtn

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.lawBtn:regOnButtonClick(function()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").MoneyLaw, res.GetMobcastUserAgentAppendStr())
    end)
    self.full18Btn:regOnButtonClick(function()
        self:Buy(true)
        self:Close()
    end)
    self.notFull18Btn:regOnButtonClick(function()
        self:Buy(false)
        self:Close()
    end)
end

function ChargeConfirmView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function ChargeConfirmView:Init(model)
    DialogAnimation.Appear(self.transform, nil)
    self.model = model
    self.chargeItem:InitView(model)
    self.chargeItem:HideDesc()

    if model:IsMonthCard() then
        self.itemDetail.gameObject:SetActive(true)
        self.itemDetail.text = tostring(model:GetItemDesc())

        self.detailBoard:SetActive(false)
    else
        self.itemDetail.gameObject:SetActive(false)

        self.detailBoard:SetActive(true)
        self.baseDiamond.text = tostring(model:GetBaseDiamond())
        local extraDiamondValue, isFirst = model:GetExtraDiamond()
        self.extraDiamond.text = tostring(extraDiamondValue)
        if isFirst then
            self.extraDiamondText.text = lang.trans("double_diamond")
        end
        self.totalDiamond.text = tostring(model:GetDiamond())
    end
end

function ChargeConfirmView:Buy(full18)
    clr.coroutine(function()
        local productId = self.model:GetProductId()
        local initResp = req.payInit(productId, full18)
        if api.success(initResp) then
            local orderId = initResp.val.order_id
            if luaevt.trig("HasPurchaseSystem") then
                luaevt.trig("PurchaseItem", productId, orderId)
            else
                local testResp = req.payTest(orderId)
                if api.success(testResp) then
                    EventSystem.SendEvent("BuyStoreItem")
                    local testData = testResp.val
                    local playerInfoModel = PlayerInfoModel.new()
                    playerInfoModel:Init()
                    playerInfoModel:AddDiamond(testData.totalDiamond)
                    CustomEvent.GetDiamond("1", testData.totalDiamond)
                    local itemName = ""
                    if tonumber(testData.totalDiamond) == 0 then
                        itemName = self.model:GetItemDetail()
                    else
                        itemName = testData.totalDiamond .. lang.transstr("diamond")
                    end
                    DialogManager.ShowToast(lang.trans("charge_item_success", itemName))
                end
            end
        end
    end)
end

return ChargeConfirmView
