local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require("ui.common.Timer")
local Button = clr.UnityEngine.UI.Button
local Object = clr.UnityEngine.Object
local GiftBoxItemPopView = class(unity.base)

local Path = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/%s.png"
local SuitNameLangKey = "store_special_tip_%s"

function GiftBoxItemPopView:ctor()
    GiftBoxItemPopView.super.ctor(self)

    self.closeBtn = self.___ex.closeBtn
    self.residualTime = self.___ex.residualTime
    self.firstLine = self.___ex.firstLine
    self.firstLineSpecial = self.___ex.firstLineSpecial
    self.secondLine = self.___ex.secondLine
    self.secondLineSpecial = self.___ex.secondLineSpecial
    self.content = self.___ex.content
    self.confirmBtn = self.___ex.confirmBtn
    self.btnTxt = self.___ex.btnTxt
    self.rewardType = self.___ex.rewardType
    self.title = self.___ex.title
    self.disableBtn = self.___ex.disableBtn
    self.desc = self.___ex.desc
    self.middleGO = self.___ex.middleGO
    self.middleSpecialGO = self.___ex.middleSpecialGO
    self.normalViewGO = self.___ex.normalViewGO
    self.specialViewGO = self.___ex.specialViewGO
    self.specialImg = self.___ex.specialImg
    self.bdkPay = self.___ex.bdkPay
    self.specialSuitTxt = self.___ex.specialSuitTxt

    self.residualTimer = nil

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.confirmBtn:regOnButtonClick(function ()
        self:BuyGiftBox()
    end)
    EventSystem.AddEvent("VIPLevelUp", self, self.ShowVIPTip)
end

function GiftBoxItemPopView:InitView(model)
    self.model = model
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
        self.residualTimer = nil
    end

    if model:GetLastTime() == 0 or model:GetLastTime() == nil then
        self.residualTime.gameObject:SetActive(false)
    else
        self.residualTimer = Timer.new(model:GetLastTime(), function (time)
            self.residualTime.text = lang.trans("store_time_tip", string.convertSecondToTime(time))
        end)
    end

    self.firstLine.text = model:GetDescInBoardFirstLine()
    self.firstLineSpecial.text = model:GetDescInBoardFirstLine()
    if model:GetDescInBoardSecondLine() == "" then
        self.secondLine.gameObject:SetActive(false)
    else
        self.secondLine.text = model:GetDescInBoardSecondLine()
        self.secondLineSpecial.text = model:GetDescInBoardSecondLine()
    end
    local isRMB = model:GetPayType()
    isRMB = tonumber(isRMB) == 1
    if isRMB then
        self.btnTxt.text = "¥" .. model:GetPrice()
        GameObjectHelper.FastSetActive(self.bdkPay, false)
    else
        self.btnTxt.text = tostring(model:GetPrice())
        GameObjectHelper.FastSetActive(self.bdkPay, true)
    end



    self.rewardType.overrideSprite = res.LoadRes(format(Path, model:GetRewardPicIndex()))
    self.title.text = model:GetTitle()
    self.desc.text = "-" .. model:GetDesc() .. "-"

    local rewardParams = {
        parentObj = self.content,
        rewardData = model:GetRewardContents(),
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }

    RewardDataCtrl.new(rewardParams)

    self:InitBtnState(model:IsCanBuy())
    self:InitBoardContent(model:IsSpecial() ~= "")
end

function GiftBoxItemPopView:InitBtnState(isCanBuy)
    GameObjectHelper.FastSetActive(self.disableBtn, not isCanBuy)
    GameObjectHelper.FastSetActive(self.confirmBtn.gameObject, isCanBuy)
end

function GiftBoxItemPopView:InitBoardContent(isSpecial)
    GameObjectHelper.FastSetActive(self.middleGO, not isSpecial)
    GameObjectHelper.FastSetActive(self.middleSpecialGO, isSpecial)
    GameObjectHelper.FastSetActive(self.normalViewGO, not isSpecial)
    GameObjectHelper.FastSetActive(self.specialViewGO, isSpecial)

    if isSpecial then
        local path = "Assets/CapstonesRes/Game/UI/Scene/Store/Images/%s.png"
        local suitName = self.model:IsSpecial()
        self.specialImg.overrideSprite = res.LoadRes(format(path, self.model:GetSpecialImg(suitName)))
        self.specialSuitTxt.text = lang.trans(format(SuitNameLangKey, suitName))
    end
end

function GiftBoxItemPopView:ShowVIPTip(vipLevel)
    self:Close()
    res.PushDialog("ui.controllers.charge.VIPTipCtrl", vipLevel)
end

function GiftBoxItemPopView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function GiftBoxItemPopView:BuyGiftBox()
    if self.buyGiftBox then
        self.buyGiftBox()
    end
end

function GiftBoxItemPopView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
        Object:Destroy(self.residualTimer.gameObject)
    end
    EventSystem.RemoveEvent("VIPLevelUp", self, self.ShowVIPTip)
end

return GiftBoxItemPopView
