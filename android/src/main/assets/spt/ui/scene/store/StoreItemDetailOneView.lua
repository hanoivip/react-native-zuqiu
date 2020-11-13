local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AssetFinder = require("ui.common.AssetFinder")
local StoreItemContentCtrl = require("ui.controllers.store.StoreItemContentCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local StoreItemDetailOneView = class(unity.base)

function StoreItemDetailOneView:ctor()
    self.buyBtn = self.___ex.buyBtn
    self.closeBtn = self.___ex.closeBtn
    self.itemIcon = self.___ex.itemIcon
    self.quality = self.___ex.quality
    self.price = self.___ex.price
    self.itemName = self.___ex.itemName
    self.desc = self.___ex.desc
    self.scroll = self.___ex.scroll
    self.content = self.___ex.content
    self.lawBtn = self.___ex.lawBtn
    self.buttonText = self.___ex.buttonText

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
    self.lawBtn:regOnButtonClick(function()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").MoneyLaw, res.GetMobcastUserAgentAppendStr())
    end)
end

function StoreItemDetailOneView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function StoreItemDetailOneView:Clear()
    for i = self.content.childCount, 1, -1 do
        Object.Destroy(self.content:GetChild(i - 1).gameObject)
    end
end

function StoreItemDetailOneView:Init(model)
    DialogAnimation.Appear(self.transform, nil)
    self:Clear()
    local itemPicIndex = model:GetPicIndex()
    local quality = model:GetQuality()
    local itemName = model:GetItemName()
    local price = model:GetItemPrice()
    local desc = model:GetDetailItemDesc()
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
    self.buttonText.text = self.price.text
    self.itemName.text = tostring(itemName)
    self.desc.text = desc

    if self.content.childCount <= 1 then
        self.scroll.enabled = false
    else
        self.scroll.enabled = true
    end
end

function StoreItemDetailOneView:RegOnBuyBtnClick(func)
    self.buyBtn:regOnButtonClick(func)
end

return StoreItemDetailOneView
