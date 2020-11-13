local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local LuaButton = require("ui.control.button.LuaButton")
local CardEquipView = class(LuaButton)

function CardEquipView:ctor()
    CardEquipView.super.ctor(self)
    self.equipArea = self.___ex.equipArea
    self.animator = self.___ex.animator
    self.currentEquip = self.___ex.currentEquip
    self.nextEquip = self.___ex.nextEquip
    self.advanceEffect = self.___ex.advanceEffect
    self.equipItemView = nil
end

function CardEquipView:start()
    self:regOnButtonClick(function()
        self:OnBtnEquip(self.slot)
    end)
end

function CardEquipView:OnBtnEquip(slot)
    if self.clickEquip then 
        self.clickEquip(slot)
    end
end

function CardEquipView:SetDefaultEquip(isDefault)
    GameObjectHelper.FastSetActive(self.equipArea.gameObject, not isDefault)
end

function CardEquipView:InitView(equipItemModel, cardDetailModel)
    if equipItemModel then 
        self.slot = equipItemModel:GetSlot()
        if not self.equipItemView then
            local viewObj, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/EquipItem.prefab")
            viewObj.transform:SetParent(self.equipArea, false)
            self.equipItemView = viewSpt
        end
        self.equipItemView:InitView(equipItemModel, cardDetailModel)
        self:SetDefaultEquip(false)
    else
        self:SetDefaultEquip(true)
    end
    self.animator.enabled = false
end

function CardEquipView:ShowWearEquipEffect()
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(0.4))
        self.animator.enabled = true
        self.equipItemView:ShowWearEquipEffect()
        self.animator:Play("CardDetailEquipMaskAnimation", 0, 0)
    end)
end

function CardEquipView:ShowAdvanceEffect(currentEquipItemModel, nextEquipItemModel)
    self.animator.enabled = true
    self.animator:Play("CardDetailAdvanceEquipItemImagaAnimation")
    GameObjectHelper.FastSetActive(self.advanceEffect, true)
    GameObjectHelper.FastSetActive(self.gameObject, false)
    GameObjectHelper.FastSetActive(self.gameObject, true)
    GameObjectHelper.FastSetActive(self.equipArea.gameObject, false)

    self.currentEquip.overrideSprite = AssetFinder.GetEquipIcon(currentEquipItemModel:GetIconIndex())
    self.nextEquip.overrideSprite = AssetFinder.GetEquipIcon(nextEquipItemModel:GetIconIndex())
end

function CardEquipView:DisableAdvanceEffect()
    self.animator.enabled = false
    GameObjectHelper.FastSetActive(self.advanceEffect, false)
    GameObjectHelper.FastSetActive(self.equipArea.gameObject, true)
end

return CardEquipView
