local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local Timer = require("ui.common.Timer")
local PeakStoreView = class(unity.base)

function PeakStoreView:ctor()
    self.pDiamondCountTxt = self.___ex.pDiamondCountTxt
    self.refreshTimeTxt = self.___ex.refreshTimeTxt
    self.refreshBtn = self.___ex.refreshBtn
    self.giftBoxContentRect = self.___ex.giftBoxContentRect
    self.itemParentRect = self.___ex.itemParentRect
    self.dPurchaseBtn = self.___ex.dPurchaseBtn
    self.pdPurchaseBtn = self.___ex.pdPurchaseBtn
    self.pPurchaseTimeTxt = self.___ex.pPurchaseTimeTxt
    self.dPurchaseTimeTxt = self.___ex.dPurchaseTimeTxt
    self.giftboxNameTxt = self.___ex.giftboxNameTxt
    self.pdPriceTxt = self.___ex.pdPriceTxt
    self.dPriceTxt = self.___ex.dPriceTxt

    DialogAnimation.Appear(self.transform)
end

function PeakStoreView:start()
    self:BindButtonHandler()
end

function PeakStoreView:InitView(peakStoreModel)
    self.pDiamondCountTxt.text = peakStoreModel:GetPDiamondCount()
    self.pPurchaseTimeTxt.text = lang.trans("peak_store_recv_tip", peakStoreModel:GetPCanPurchaseTime(), peakStoreModel:GetPPurchaseMaxTime())
    self.dPurchaseTimeTxt.text = lang.trans("giftbox_limit", peakStoreModel:GetDCanPurchaseTime(), peakStoreModel:GetDiamondMaxTime())
    self.pdPriceTxt.text = "x" .. peakStoreModel:GetPDiamondPrice()
    self.dPriceTxt.text = "x" .. peakStoreModel:GetDiamondPriceByTime()
    self:InitGiftBoxContent(peakStoreModel)

    if self.cdTimer then
        self.cdTimer:Destroy()
        self.cdTimer = nil
    end
    self.cdTimer = Timer.new(peakStoreModel:GetNextRefreshTime(), function (time)
        self.refreshTimeTxt.text = string.convertSecondToTime(toint(time))
        if toint(time) <= 0 then
            EventSystem.SendEvent("Refresh_Peak_Store_Main_Page")
            self.cdTimer:Destroy()
            self.cdTimer = nil
        end
    end)

    self:RefreshItem()
end

function PeakStoreView:InitGiftBoxContent(peakStoreModel)
    res.ClearChildren(self.giftBoxContentRect)
    self.giftboxNameTxt.text = peakStoreModel:GetGiftBoxName()
    local contents = peakStoreModel:GetGiftBoxContents()
    for k, v in pairs(contents) do
        local rewardParams = {
            parentObj = self.giftBoxContentRect,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function PeakStoreView:BindButtonHandler()
    self.refreshBtn:regOnButtonClick(function ()
        if self.refreshBtnClick then
            self.refreshBtnClick()
        end
    end)
    self.dPurchaseBtn:regOnButtonClick(function ()
        if self.dPurchaseBtnClick then
            self.dPurchaseBtnClick()
        end
    end)
    self.pdPurchaseBtn:regOnButtonClick(function ()
        if self.pdPurchaseBtnClick then
            self.pdPurchaseBtnClick()
        end
    end)
end

function PeakStoreView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function PeakStoreView:ClearItemContent()
    res.ClearChildren(self.itemParentRect)
end

function PeakStoreView:RefreshItem()
    if self.refreshItem then
        self.refreshItem()
    end
end

function PeakStoreView:AddItemView(obj)
    obj.transform:SetParent(self.itemParentRect, false)
end

function PeakStoreView:RefreshPDiamond(playerInfoModel)
    self.pDiamondCountTxt.text = tostring(playerInfoModel:GetPeakDiamond())
end

function PeakStoreView:OnEnterScene()
    EventSystem.AddEvent("PlayerInfo", self, self.RefreshPDiamond)
end

function PeakStoreView:onDestroy()
    EventSystem.RemoveEvent("PlayerInfo", self, self.RefreshPDiamond)
    if self.cdTimer then
        self.cdTimer:Destroy()
        self.cdTimer = nil
    end
end

return PeakStoreView
