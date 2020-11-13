local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemModel = require("ui.models.ItemModel")
local MenuType = require("ui.controllers.itemList.MenuType")
local DreamCardStoreItemView = class()

function DreamCardStoreItemView:ctor()
    self.title = self.___ex.title
    self.clickBuy = self.___ex.clickBuy
    self.flag = self.___ex.flag
    self.mainBack = self.___ex.mainBack
    self.quality = self.___ex.quality
    self.detailBtn = self.___ex.detailBtn
    self.timeText = self.___ex.timeText
    self.priceImage = self.___ex.priceImage
    self.priceText = self.___ex.priceText
    self.reflectionImg = self.___ex.reflectionImg
end

function DreamCardStoreItemView:InitView(cardItem)
    self.title.text = cardItem.name
    local cardPackImage = string.format("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/CardPack_%s.png", cardItem.background)
    local cardRes = res.LoadRes(cardPackImage)
    if not cardRes then
        cardPackImage = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/CardPack_1.png"
        cardRes = res.LoadRes(cardPackImage)
    end
    self.mainBack.overrideSprite = cardRes

    local cardReflectionImage = string.format("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/Reflection_%s.png", cardItem.background)
    local reflectionRes = res.LoadRes(cardReflectionImage)
    if not reflectionRes then
        cardReflectionImage = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/Reflection_1.png"
        reflectionRes = res.LoadRes(cardReflectionImage)
    end
    self.reflectionImg.overrideSprite = reflectionRes

    self.flag.overrideSprite = self:GetNationIcon(cardItem.picIndex)
    for k,v in pairs(self.quality) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    local index = 1
    for k,v in pairs(cardItem.qualityShow) do
        local qualityImage = string.format("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/QualityText_%s.png", v)
        self.quality[tostring(index)].overrideSprite = res.LoadRes(qualityImage)
        GameObjectHelper.FastSetActive(self.quality[tostring(index)].gameObject, true)
        index = index + 1
    end
    self.detailBtn:regOnButtonClick(function()
        self:OnDetailClick(cardItem.contents.item[1].id)
    end)
    if cardItem.beginTime and cardItem.endTime and cardItem.beginTime ~= "" and cardItem.endTime ~= "" then
        local bTime = string.formatTimestampNoYear(cardItem.beginTime)
        local eTime = string.formatTimestampNoYear(cardItem.endTime)
        self.timeText.text = lang.transstr("time_last", bTime, eTime)
    else
        GameObjectHelper.FastSetActive(self.timeText.gameObject, false)
    end
    local priceTypePath
    if cardItem.currencytype == "dc" then
        priceTypePath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/dc.png"
    else
        priceTypePath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/dp.png"
    end
    local priceRes = res.LoadRes(priceTypePath)
    if priceRes then
        self.priceImage.overrideSprite = priceRes
    else
        GameObjectHelper.FastSetActive(self.priceImage.gameObject, false)
    end
    self.priceText.text = "x " .. tostring(cardItem.price)
end
function DreamCardStoreItemView:OnDetailClick(itemId)
    local itemModel = ItemModel.new(tonumber(itemId))
    if itemModel then
        res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", MenuType.ITEM, itemModel)
    end
end

-- 获取国籍Icon
function DreamCardStoreItemView.GetNationIcon(iconIndex)
    local path = "Assets/CapstonesRes/Game/UI/Common/Images/Nationality/" .. tostring(iconIndex) .. ".png"
    local icon = res.LoadRes(path)
    if icon == nil then 
        return res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamStore/Image/Other.png")
    else
        return icon
    end
end

return DreamCardStoreItemView
