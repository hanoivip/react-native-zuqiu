local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ItemOriginType = require("ui.controllers.itemList.ItemOriginType")

local EquipBoxView = class(unity.base)

function EquipBoxView:ctor()
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
    -- 碎片图标
    self.pieceIcon = self.___ex.pieceIcon
    self.pieceSign = self.___ex.pieceSign
    self.rectTrans = self.___ex.rectTrans
    self.btnClick = self.___ex.btnClick
    self.equipUseSymbol = self.___ex.equipUseSymbol

    self.equipItemModel = nil
    -- 是否显示名称
    self.isShowName = false
    -- 是否显示获得的数量
    self.isShowAddNum = false
    -- 是否显示碎片图标
    self.isShowPiece = false
    -- 是否要显示详情板
    self.isShowDetail = false
end

function EquipBoxView:InitView(equipItemModel, id, isShowName, isShowAddNum, isShowPiece, isShowDetail, itemOriginType)
    self.equipItemModel = equipItemModel
    self.id = id
    self.isShowName = isShowName or false
    self.isShowAddNum = isShowAddNum or false
    self.isShowPiece = isShowPiece or false
    self.isShowDetail = isShowDetail or false
    self.itemOriginType = itemOriginType
    self:BuildPage()
end

function EquipBoxView:start()
    self:ResetAddNumSize()
    if self.isShowDetail then
        self.btnClick:regOnButtonClick(function()
            self:OnEquipBoxClick()
        end)
    end
end

function EquipBoxView:BuildPage()
    local iconRes = AssetFinder.GetEquipIcon(self.equipItemModel:GetIconIndex())

    self.qualityBorder.overrideSprite = AssetFinder.GetItemQualityBoard(self.equipItemModel:GetQuality())

    self.nameTxt.text = self.equipItemModel:GetName()
    GameObjectHelper.FastSetActive(self.nameTxt.gameObject, self.isShowName)

    if self.isShowAddNum then
        local addNum = self.equipItemModel:GetAddNum() or 0
        self.addNumText.text = "x" .. string.formatNumWithUnit(addNum)
        GameObjectHelper.FastSetActive(self.addNum.gameObject, true)
    else
        GameObjectHelper.FastSetActive(self.addNum.gameObject, false)
    end

    GameObjectHelper.FastSetActive(self.pieceSign.gameObject, self.isShowPiece)
    GameObjectHelper.FastSetActive(self.icon.gameObject, not self.isShowPiece)
    if self.isShowPiece then
        self.pieceIcon.overrideSprite = iconRes
    else
        self.icon.overrideSprite = iconRes
    end
end

function EquipBoxView:ResetAddNumSize()
    clr.coroutine(function ()
        unity.waitForEndOfFrame()
        local boxRect = self.rectTrans.rect
        if boxRect.width ~= 82 then
            local scaleFactor = boxRect.width / 82
            scaleFactor = (scaleFactor - 1) / 2 + 1
            self.addNumText.fontSize = math.floor(16 * scaleFactor)
            local addNumSize = self.addNum.sizeDelta
            self.addNum.sizeDelta = Vector2(addNumSize.x, addNumSize.y * scaleFactor)
        end
    end)
end

--- 设置名称颜色
function EquipBoxView:SetNameColor(nameColor, nameShadowColor)
    self.nameTxt.color = nameColor
    self.nameShadow.effectColor = nameShadowColor
end

function EquipBoxView:OnEquipBoxClick()
    local MenuType = require("ui.controllers.itemList.MenuType")
    if self.isShowPiece then
        local EquipPieceModel = require("ui.models.EquipPieceModel")
        local equipPieceModel = EquipPieceModel.new(self.id)
        if self.itemOriginType == ItemOriginType.OTHER then
            res.PushDialog("ui.controllers.itemList.OtherItemDetailCtrl", MenuType.EQUIPPIECE, equipPieceModel)
        elseif self.itemOriginType == ItemOriginType.ITEMLIST then
            res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", MenuType.EQUIPPIECE, equipPieceModel)
        end
    else
        local EquipModel = require("ui.models.EquipModel")
        local equipModel = EquipModel.new(self.id)
        if self.itemOriginType == ItemOriginType.OTHER then
            res.PushDialog("ui.controllers.itemList.OtherItemDetailCtrl", MenuType.EQUIP, equipModel)
        elseif self.itemOriginType == ItemOriginType.ITEMLIST then
            res.PushDialog("ui.controllers.itemList.ItemDetailCtrl", MenuType.EQUIP, equipModel)
        end
    end
end

function EquipBoxView:SetEquipUseSymbol(isShow)
    GameObjectHelper.FastSetActive(self.equipUseSymbol, isShow or false)
end

return EquipBoxView