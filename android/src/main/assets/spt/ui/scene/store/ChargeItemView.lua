local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3

local AssetFinder = require("ui.common.AssetFinder")
local LuaButton = require("ui.control.button.LuaButton")
local StoreModel = require("ui.models.store.StoreModel")
local ChargeItemView = class(LuaButton)

function ChargeItemView:ctor()
    ChargeItemView.super.ctor(self)

    self.itemDesc = self.___ex.itemDesc
    self.itemImage = self.___ex.itemImage
    self.itemPrice = self.___ex.itemPrice
    self.hotImage = self.___ex.hotImage
    self.hotText = self.___ex.hotText
    self.titleWithDate = self.___ex.titleWithDate
    self.titleNormal = self.___ex.titleNormal
    self.titleWithDateNumber = self.___ex.titleWithDateNumber
    self.titleWithDateIcon = self.___ex.titleWithDateIcon
    self.titleWithDateDate = self.___ex.titleWithDateDate
    self.titleNormalIcon = self.___ex.titleNormalIcon
    self.titleNormalNumber = self.___ex.titleNormalNumber
end

function ChargeItemView:HideDesc()
    self.itemDesc.gameObject:SetActive(false)
end

function ChargeItemView:InitView(model)
    self.model = model

    if model:IsHot() then
        self.hotImage.gameObject:SetActive(true)
        self.hotImage.overrideSprite = AssetFinder.GetRecommendCornerIcon(model:GetHotColor())
        self.hotText.text = model:GetHotText()
    else
        self.hotImage.gameObject:SetActive(false)
    end

    local itemNameInfo = model:GetItemName()
    if type(itemNameInfo.date) == "string" and itemNameInfo.date ~= "" then
        self.titleWithDate:SetActive(true)
        self.titleNormal:SetActive(false)
        self.titleWithDateNumber.text = tostring(itemNameInfo.number)
        self.titleWithDateIcon.overrideSprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/%s.png", itemNameInfo.icon))
        self.titleWithDateDate.text = itemNameInfo.date
    else
        self.titleWithDate:SetActive(false)
        self.titleNormal:SetActive(true)
        self.titleNormalNumber.text = itemNameInfo.number
        self.titleNormalIcon.overrideSprite = res.LoadRes(format("Assets/CapstonesRes/Game/UI/Common/Images/CommonTrueColor/%s.png", itemNameInfo.icon))
    end

    self.itemDesc.text = model:GetItemDesc()
    local itemPriceText = model:GetItemPrice()
    itemPriceText = format("%s%s", itemPriceText, lang.transstr("money_unit"))
    self.itemPrice.text = itemPriceText

    self.itemImage.overrideSprite = AssetFinder.GetStoreItemIcon(model:GetPicIndex())
end

return ChargeItemView
