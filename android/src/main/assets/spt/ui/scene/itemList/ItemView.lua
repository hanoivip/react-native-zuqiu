local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require("EventSystem")
local MenuType = require("ui.controllers.itemList.MenuType")

local ItemView = class(unity.base)

function ItemView:ctor()
    self.icon = self.___ex.icon
    self.pieceIcon = self.___ex.pieceIcon
    self.qualityBorder = self.___ex.qualityBorder
    self.nameTxt = self.___ex.name
    self.addNumText = self.___ex.addNumText
    self.btnClick = self.___ex.btnClick
    self.pieceSign = self.___ex.pieceSign
end

function ItemView:InitView(model, itemType)
    self.model = model
    self.itemType = itemType
    if itemType == MenuType.EQUIPPIECE then
        self.pieceIcon.sprite = AssetFinder.GetEquipIcon(self.model:GetIconIndex())
    elseif self.itemType ~= MenuType.ITEM then
        self.icon.sprite = AssetFinder.GetEquipIcon(self.model:GetIconIndex())
    else
        self.icon.sprite = AssetFinder.GetItemIcon(self.model:GetIconIndex())
    end
    self.qualityBorder.sprite = AssetFinder.GetItemQualityBoard(self.model:GetQuality())
    self.nameTxt.text = self.model:GetName()
    local addNum = self.model:GetAddNum() or 0
    self.addNumText.text = "x" .. addNum

    local isPiece = tobool(itemType == MenuType.EQUIPPIECE)
    GameObjectHelper.FastSetActive(self.pieceSign.gameObject, isPiece)
    GameObjectHelper.FastSetActive(self.icon.gameObject, not isPiece)
end

function ItemView:start()
    self.btnClick:regOnButtonClick(function()
        if self.onClick then
            self.onClick()
        end
    end)
end

function ItemView:SetItemNum(num)
    self.addNumText.text = "x" .. num
end

function ItemView:EventEquipNumChanged(eid, num)
    if self.itemType == MenuType.EQUIP then
        if tonumber(self.model:GetEid()) == tonumber(eid) then
            self:SetItemNum(num)
        end
    end
end

function ItemView:EventEquipPieceNumChanged(pid, num)
    if self.itemType == MenuType.EQUIPPIECE then
        if tonumber(self.model:GetPid()) == tonumber(pid) then
            self:SetItemNum(num)
        end
    end
end

function ItemView:EventItemNumChanged(id, num)
    if self.itemType == MenuType.ITEM then
        if tonumber(self.model:GetId()) == tonumber(id) then
            self:SetItemNum(num)
        end
    end
end

function ItemView:onEnable()
    EventSystem.AddEvent("EquipsMapModel_ResetEquipNum", self, self.EventEquipNumChanged)
    EventSystem.AddEvent("EquipPieceMapModel_ResetItemNum", self, self.EventEquipPieceNumChanged)
    EventSystem.AddEvent("ItemsMapModel_ResetItemNum", self, self.EventItemNumChanged)
end

function ItemView:onDisable()
    EventSystem.RemoveEvent("EquipsMapModel_ResetEquipNum", self, self.EventEquipNumChanged)
    EventSystem.RemoveEvent("EquipPieceMapModel_ResetItemNum", self, self.EventEquipPieceNumChanged)
    EventSystem.RemoveEvent("ItemsMapModel_ResetItemNum", self, self.EventItemNumChanged)
end

return ItemView