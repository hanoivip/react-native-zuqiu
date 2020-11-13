local UnityEngine = clr.UnityEngine

local AssetFinder = require("ui.common.AssetFinder")
local StoreModel = require("ui.models.store.StoreModel")
local StoreItemView = class(unity.base)

function StoreItemView:ctor()
    StoreItemView.super.ctor(self)

    self.itemName = self.___ex.itemName
    self.itemDesc = self.___ex.itemDesc
    self.itemImage = self.___ex.itemImage
    self.itemPrice = self.___ex.itemPrice
    self.hotImage = self.___ex.hotImage
    self.hotText = self.___ex.hotText

    self.qualityImage = self.___ex.qualityImage
    self.priceBtn = self.___ex.priceBtn
end

function StoreItemView:InitView(model)
    self.model = model

    if model:IsHot() then
        self.hotImage.gameObject:SetActive(true)
        self.hotImage.overrideSprite = AssetFinder.GetRecommendCornerIcon(model:GetHotColor())
        self.hotText.text = model:GetHotText()
    else
        self.hotImage.gameObject:SetActive(false)
    end

    self.itemName.text = model:GetItemName()
    self.itemDesc.text = model:GetItemDesc()
    local itemPriceText = model:GetItemPrice()
    itemPriceText = format("x%s", itemPriceText)
    self.itemPrice.text = itemPriceText

    local storeIcon, isFallbackItem = AssetFinder.GetStoreItemIcon(model:GetPicIndex())
    if isFallbackItem then
        self.itemImage.material = clr.null
    else
        self.itemImage.material = self.qualityImage.material
    end
    self.itemImage.overrideSprite = storeIcon
    
    self.qualityImage.overrideSprite = AssetFinder.GetItemQualityBoard(model:GetQuality())
end

function StoreItemView:RegOnPriceButtonClick(func)
    self.priceBtn:regOnButtonClick(func)
end

return StoreItemView

