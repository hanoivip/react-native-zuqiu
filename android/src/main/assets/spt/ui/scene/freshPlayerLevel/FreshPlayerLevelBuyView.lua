local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local ProbabilityType = require("ui.scene.itemList.ProbabilityType")
local CurrencyImagePath = require("ui.scene.itemList.CurrencyImagePath")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Timer = require('ui.common.Timer')
local ItemModel = require("ui.models.ItemModel")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local FreshPlayerLevelModel = require("ui.models.freshPlayerLevel.FreshPlayerLevelModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FreshPlayerLevelBuyView = class(unity.base)

function FreshPlayerLevelBuyView:ctor()
--------Start_Auto_Generate--------
    self.limitTxt = self.___ex.limitTxt
    self.timeTxt = self.___ex.timeTxt
    self.rewardTrans = self.___ex.rewardTrans
    self.firstDescTxt = self.___ex.firstDescTxt
    self.secondDescTxt = self.___ex.secondDescTxt
    self.buyTypeTxt = self.___ex.buyTypeTxt
    self.confirmBtn = self.___ex.confirmBtn
    self.freeGo = self.___ex.freeGo
    self.priceGo = self.___ex.priceGo
    self.priceImg = self.___ex.priceImg
    self.priceTxt = self.___ex.priceTxt
    self.closeBtn = self.___ex.closeBtn
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.canvasGroup = self.___ex.canvasGroup
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
end

function FreshPlayerLevelBuyView:start()
    self:BindButtonHandler()
    self:PlayInAnimator()
end

function FreshPlayerLevelBuyView:InitView(id, buyCallBack)
    self.freshPlayerLevelModel = FreshPlayerLevelModel.new()
    self.buyCallBack = buyCallBack
    self.id = id
    local levelData = self.freshPlayerLevelModel:GetStaticDataById(id)
    self.levelData = levelData
    local desc = levelData.desc
    local desc2 = levelData.desc2
    local price = levelData.price
    local index, itemContent = next(levelData.item)
    local itemId = itemContent.id
    local itemModel = ItemModel.new(itemId)
    self.probabilityType = itemModel:GetProbability()
    local content = itemModel:GetItemContent()
    self.content = content
    self.firstDescTxt.text = desc
    self.secondDescTxt.text = desc2
    self.buyTypeTxt.text = lang.trans("level_box_type" .. self.probabilityType)
    local mainItem = {}
    mainItem.item = levelData.item
    local rewardParams = {
        parentObj = self.rewardTrans,
        rewardData = mainItem,
        isShowName = true,
        isReceive = false,
        isShowBaseReward = true,
        isShowCardReward = true,
        isShowDetail = true,
    }
    res.ClearChildren(self.rewardTrans)
    RewardDataCtrl.new(rewardParams)
    self:RefreshReward(content)
    self:RefreshTimeArea()
    GameObjectHelper.FastSetActive(self.priceGo, price > 0)
    GameObjectHelper.FastSetActive(self.freeGo, price <= 0)
    if price > 0 then
        local priceType = levelData.priceType
        self.priceImg.overrideSprite = res.LoadRes(CurrencyImagePath[priceType])
        self.priceTxt.text = "x" .. price
        self.limitTxt.text = lang.trans("untranslated_2355")
    else
        self.limitTxt.text = lang.trans("level_box_received")
    end
end

function FreshPlayerLevelBuyView:RefreshReward(itemContent)
    res.ClearChildren(self.contentTrans)
    for i, v in ipairs(itemContent) do
        local rewardParams = {
            parentObj = self.contentTrans,
            rewardData = v.contents,
            isShowName = true,
            isReceive = false,
            isShowBaseReward = true,
            isShowCardReward = true,
            isShowDetail = true,
        }
        RewardDataCtrl.new(rewardParams)
    end
end

function FreshPlayerLevelBuyView:RefreshTimeArea()
    local remainTime = self.freshPlayerLevelModel:GetRemainTimeById(self.id)
    if remainTime < 1 then
        self.timeTxt.text = lang.trans("belatedGift_item_nil_time")
    end
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
    self.countDownTimer = Timer.new(remainTime, function(time)
        if time > 1 then
            self.timeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
        else
            if self.CloseView then
                self:CloseView()
            end
        end
    end)
end

function FreshPlayerLevelBuyView:BindButtonHandler()
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.confirmBtn:regOnButtonClick(function()
        self:OnConfirmClick()
    end)
end

function FreshPlayerLevelBuyView:OnConfirmClick()
    local price = self.levelData.price
    if price > 0 then
        local priceType = self.levelData.priceType
        if self.probabilityType == ProbabilityType.Options then
            CostDiamondHelper.CostCurrency(price, self, function() self:ShowOptionPage(self.id) end, priceType)
        else
            CostDiamondHelper.CostCurrency(price, self, function()
                self.buyCallBack(self.id)
                self:CloseView()
            end, priceType)
        end
    else
        self.buyCallBack(self.id)
        self:Close()
    end
end

function FreshPlayerLevelBuyView:ShowOptionPage(id)
    local prefabPath = "Assets/CapstonesRes/Game/UI/Scene/FreshPlayerLevelBox/FreshPlayerLevelOption.prefab"
    local dialog, dialogcomp = res.ShowDialog(prefabPath, "camera", true, true)
    local script = dialogcomp.contentcomp
    script:InitView(id, self.content, self.buyCallBack)
    self:Close()
end

function FreshPlayerLevelBuyView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FreshPlayerLevelBuyView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FreshPlayerLevelBuyView:CloseView()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
end

function FreshPlayerLevelBuyView:Close()
    self:PlayOutAnimator()
end

function FreshPlayerLevelBuyView:onDestroy()
    if self.countDownTimer ~= nil then
        self.countDownTimer:Destroy()
        self.countDownTimer = nil
    end
end


return FreshPlayerLevelBuyView
