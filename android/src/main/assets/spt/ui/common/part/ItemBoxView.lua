local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")
local CurrencyID = require("ui.models.itemList.CurrencyID")
local CurrencyType = require("ui.models.itemList.CurrencyType")

local ItemBoxView = class(unity.base)

function ItemBoxView:ctor()
    -- 图标
    self.icon = self.___ex.icon
    -- 品级框
    self.qualityBorder = self.___ex.qualityBorder
    -- 名称
    self.nameTxt = self.___ex.name
    -- 名称阴影
    self.nameShadow = self.___ex.nameShadow
    -- 获得的数量
    self.addNum = self.___ex.addNum
    self.addNumText = self.___ex.addNumText
    self.rectTrans = self.___ex.rectTrans
    self.itemModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否显示获得的数量
    self.isShowAddNum = false
    -- 是否要显示详情板
    self.isShowDetail = false
    self.btnClick = self.___ex.btnClick
    self.isFixNumFont = false
end

function ItemBoxView:InitView(itemModel, id, isShowName, isShowAddNum, isShowDetail, itemOriginType)
    self.itemModel = itemModel
    self.id = id
    self.isShowName = isShowName or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowDetail = isShowDetail or false
    self.itemOriginType = itemOriginType
    self:BuildPage()
end

function ItemBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnItemClick()
        end)
    end
end

function ItemBoxView:BuildPage()
    self.icon.sprite = AssetFinder.GetItemIcon(self.itemModel:GetIconIndex())
    self.qualityBorder.sprite = AssetFinder.GetItemQualityBoard(self.itemModel:GetQuality())

    self.nameTxt.text = self.itemModel:GetName()
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    if self.isShowAddNum then
        local addNum = self.itemModel:GetAddNum() or 0
        self.addNumText.text = "x" .. string.formatNumWithUnit(addNum)
        GameObjectHelper.FastSetActive(self.addNum.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.addNum.gameObject, false)
    end
end

function ItemBoxView:ResetAddNumSize()
    if self.isFixNumFont then return end
    self:coroutine(function ()
        unity.waitForEndOfFrame()
        if self.rectTrans then
            local boxRect = self.rectTrans.rect
            if boxRect.width ~= 82 then
                local scaleFactor = boxRect.width / 82
                scaleFactor = (scaleFactor - 1) / 2 + 1
                self.addNumText.fontSize = math.floor(16 * scaleFactor)
                local addNumSize = self.addNum.sizeDelta
                self.addNum.sizeDelta = Vector2(addNumSize.x, addNumSize.y * scaleFactor)
            end
        end
    end)
end

--- 设置名称颜色
function ItemBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

--- 设置名称字号
function ItemBoxView:SetNumFont(numFont)
    self.isFixNumFont = true
    self.addNumText.fontSize = numFont
    self.nameTxt.fontSize = numFont
end

function ItemBoxView:OnItemClick()
    local MenuType = require("ui.controllers.itemList.MenuType")
    local ItemModel = require("ui.models.ItemModel")
    local RedPacketModel = require("ui.models.RedPacketModel")
    local itemModel = ItemModel.new(self.id)
    if not itemModel:HasValid() then
        itemModel = RedPacketModel.new(self.id)
    end
    if self.itemOriginType == ItemOriginType.OTHER then
        if CurrencyID[tostring(self.id)] and CurrencyID[tostring(self.id)] ~= CurrencyType.Fs then
            return
        end
        res.PushDialog("ui.controllers.itemList.OtherItemDetailCtrl", MenuType.ITEM, itemModel)
    elseif self.itemOriginType == ItemOriginType.ITEMLIST then
        res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", MenuType.ITEM, itemModel)
    end
end

return ItemBoxView
