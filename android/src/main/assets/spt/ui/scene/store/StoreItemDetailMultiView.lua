local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AssetFinder = require("ui.common.AssetFinder")
local StoreItemContentCtrl = require("ui.controllers.store.StoreItemContentCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local DialogManager = require("ui.control.manager.DialogManager")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local StoreItemDetailMultiView = class(unity.base)

function StoreItemDetailMultiView:ctor()
    self.buyBtn = self.___ex.buyBtn
    self.closeBtn = self.___ex.closeBtn
    self.itemIcon = self.___ex.itemIcon
    self.quality = self.___ex.quality
    self.price = self.___ex.price
    self.itemName = self.___ex.itemName
    self.desc = self.___ex.desc
    self.cancelBtn = self.___ex.cancelBtn
    self.number = self.___ex.number
    self.addBtn = self.___ex.addBtn
    self.minusBtn = self.___ex.minusBtn
    self.scroll = self.___ex.scroll
    self.content = self.___ex.content
    self.lawBtn = self.___ex.lawBtn
    self.buttonText = self.___ex.buttonText

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)

    -- self.cancelBtn:regOnButtonClick(function()
    --     self:Close()
    -- end)

    -- self.lawBtn:regOnButtonClick(function()
    --     luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").MoneyLaw, res.GetMobcastUserAgentAppendStr())
    -- end)
    local pressAddData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:AddBuyCount()
        end,
        durationCallback = function(count)
            self:AddBuyCount()
        end,
    }
    self.addBtn:regOnButtonPressing(pressAddData)
    self.addBtn:regOnButtonUp(function()
        self.hasShownDiamondNotEnough = false
    end)
    local pressMinusData = {
        acceleration = 1,   -- 加速度，执行的越来越快
        clickCallback = function()
            self:MinusBuyCount()
        end,
        durationCallback = function(count)
            self:MinusBuyCount()
        end,
    }
    self.minusBtn:regOnButtonPressing(pressMinusData)
end

function StoreItemDetailMultiView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function StoreItemDetailMultiView:Clear()
    for i = self.content.childCount, 1, -1 do
        Object.Destroy(self.content:GetChild(i - 1).gameObject)
    end
end

function StoreItemDetailMultiView:UpdatePriceTotal()
    self.number.text = tostring(self.buyCount)
    self.buyPriceTotal = self.buyCount * self.model:GetItemPrice()
    self.buttonText.text = "x " .. tostring(self.buyPriceTotal)
end

function StoreItemDetailMultiView:InitBuyCount()
    self.buyCount = 1
    self:UpdatePriceTotal()
end

function StoreItemDetailMultiView:AddBuyCount()
    local playerInfoModel = PlayerInfoModel.new()
    local diamond = playerInfoModel:GetDiamond()
    if (self.buyCount + 1) * self.model:GetItemPrice() > diamond then
        if not self.hasShownDiamondNotEnough then
            DialogManager.ShowToastByLang("diamondNotEnough")
            self.hasShownDiamondNotEnough = true
        end
    else
        self.buyCount = self.buyCount + 1
        self:UpdatePriceTotal()
    end
end

function StoreItemDetailMultiView:MinusBuyCount()
    if self.buyCount > 1 then
        self.buyCount = self.buyCount - 1
        self:UpdatePriceTotal()
    end
end

function StoreItemDetailMultiView:Init(model)
    self.model = model
    DialogAnimation.Appear(self.transform, nil)
    local itemPicIndex = model:GetPicIndex()
    local quality = model:GetQuality()
    local itemName = model:GetItemName()
    local price = model:GetItemPrice()
    local desc = model:GetItemDesc()
    local contents = model:GetContents()
    StoreItemContentCtrl.new(self.content, contents, true, false, true, true, true)

    local storeIcon, isFallbackItem = AssetFinder.GetStoreItemIcon(itemPicIndex)
    if isFallbackItem then
        self.itemIcon.material = clr.null
    else
        self.itemIcon.material = self.quality.material
    end
    self.itemIcon.overrideSprite = storeIcon
    
    self.quality.overrideSprite = AssetFinder.GetItemQualityBoard(quality)
    self.price.text = "x " .. tostring(price)
    self.itemName.text = tostring(itemName)
    self.desc.text = desc
    self:InitBuyCount()

    if self.content.childCount <= 1 then
        self.scroll.enabled = false
    else
        self.scroll.enabled = true
    end
end

function StoreItemDetailMultiView:RegOnBuyBtnClick(func)
    self.buyBtn:regOnButtonClick(function()
        func(self.buyCount)
    end)
end

return StoreItemDetailMultiView

