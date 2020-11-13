local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CommonConstants = require("ui.common.CommonConstants")
local ItemModel = require("ui.models.ItemModel")
local SupremeMonthCardView = class(unity.base)

local Path = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/%s.png"

function SupremeMonthCardView:ctor()
    SupremeMonthCardView.super.ctor(self)

    self.closeBtn = self.___ex.closeBtn
    self.confirmBtn = self.___ex.confirmBtn
    self.btnTxt = self.___ex.btnTxt
    self.rewardType = self.___ex.rewardType
    self.title = self.___ex.title
    self.disableBtn = self.___ex.disableBtn
    self.descTxt = self.___ex.descTxt
    self.oldPriceTxt = self.___ex.oldPriceTxt
    self.currPriceTxt = self.___ex.currPriceTxt
    self.bdkPay = self.___ex.bdkPay
    self.bdkPay1 = self.___ex.bdkPay1
    self.bdkPay2 = self.___ex.bdkPay2
    self.content = self.___ex.content

    EventSystem.AddEvent("VIPLevelUp", self, self.ShowVIPTip)
end
function SupremeMonthCardView:start()
    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.confirmBtn:regOnButtonClick(function ()
        self:BuyGiftBox()
    end)
end

function SupremeMonthCardView:InitView(model)
    self.model = model
    local isRMB = model:GetPayType()
    isRMB = tonumber(isRMB) == 1
    if isRMB then
        self.oldPriceTxt.text = lang.transstr("discountStore_originPrice") .. "：¥ " .. model:GetOldPrice()
        self.currPriceTxt.text = "¥ " .. model:GetPrice()
        self.btnTxt.text = "¥" .. model:GetPrice()
    else
        self.oldPriceTxt.text = tostring(model:GetOldPrice())
        self.currPriceTxt.text = tostring(model:GetPrice()) .. "  "
        self.btnTxt.text = tostring(model:GetPrice())
    end
    GameObjectHelper.FastSetActive(self.bdkPay, not isRMB)
    GameObjectHelper.FastSetActive(self.bdkPay1, not isRMB)
    GameObjectHelper.FastSetActive(self.bdkPay2, not isRMB)
    self.rewardType.overrideSprite = res.LoadRes(format(Path, model:GetRewardPicIndex()))
    self.title.text = model:GetTitle()
    self.descTxt.text = model:GetDescInBoardFirstLine()

    local itemList = ItemModel.new(CommonConstants.SupremeCardItemID):GetItemContent()
    res.ClearChildren(self.content.transform)
    for i, v in ipairs(itemList) do
        local rewardParams = {
            parentObj = self.content,
            rewardData = v.contents,
            isShowName = false,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
    self:InitBtnState(model:IsCanBuy())
end

function SupremeMonthCardView:InitBtnState(isCanBuy)
    GameObjectHelper.FastSetActive(self.disableBtn, not isCanBuy)
    GameObjectHelper.FastSetActive(self.confirmBtn.gameObject, isCanBuy)
end

function SupremeMonthCardView:ShowVIPTip(vipLevel)
    self:Close()
    res.PushDialog("ui.controllers.charge.VIPTipCtrl", vipLevel)
end

function SupremeMonthCardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function SupremeMonthCardView:BuyGiftBox()
    if self.buyGiftBox then
        self.buyGiftBox()
    end
end

function SupremeMonthCardView:onDestroy()
    EventSystem.RemoveEvent("VIPLevelUp", self, self.ShowVIPTip)
end

return SupremeMonthCardView