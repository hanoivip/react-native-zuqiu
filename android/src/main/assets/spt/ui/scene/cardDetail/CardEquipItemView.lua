local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardEquipItemView = class(UnityEngine.base)

function CardEquipItemView:ctor()
    self.qualityBorder = self.___ex.qualityBorder
    self.icon = self.___ex.icon
    self.equipName = self.___ex.equipName
    self.condition = self.___ex.condition
    self.sign = self.___ex.sign
    self.sign_Condition = self.___ex.sign_Condition
    self.signText = self.___ex.signText
    self.equipSignText = self.___ex.equipSignText
    self.wearEquipObj = self.___ex.wearEquipObj
end

function CardEquipItemView:InitView(equipItemModel, cardDetailModel)
    self.equipName.text = equipItemModel:GetName()
    local isEquip = equipItemModel:IsEquip()
    self.icon.overrideSprite = AssetFinder.GetEquipIcon(equipItemModel:GetIconIndex())
    self.qualityBorder.overrideSprite = AssetFinder.GetItemQualityBoard(equipItemModel:GetQuality())
    
    local isOpenMask, isShowLevel, canEquipSign = false, false, false
    if not isEquip then
        local slot = equipItemModel:GetSlot()
        
        canEquipSign = cardDetailModel:IsOperable() and cardDetailModel:IsReachWearEquipCondition(slot) or false
        local isReachLevel, needCardLevel = cardDetailModel:IsEquipToReachCardLevel(slot)
        if canEquipSign and not isReachLevel then
            canEquipSign = false
            local levelStr = "Lv." .. needCardLevel
            isShowLevel = true
            self.signText.text = lang.trans("need_level", levelStr)
        elseif canEquipSign then 
            self.equipSignText.text = lang.trans("could_equip")
        end
        isOpenMask = true
    end

    self.icon.color = isOpenMask and Color(0, 1, 1, 0.8) or Color(1, 1, 1, 1)
    self.qualityBorder.color = isOpenMask and Color(0, 1, 1, 0.8) or Color(1, 1, 1, 1)

    GameObjectHelper.FastSetActive(self.sign, tobool(canEquipSign))
    GameObjectHelper.FastSetActive(self.sign_Condition, isShowLevel)
    GameObjectHelper.FastSetActive(self.condition, isOpenMask)
    GameObjectHelper.FastSetActive(self.wearEquipObj, false)
end

function CardEquipItemView:ShowWearEquipEffect()
    GameObjectHelper.FastSetActive(self.condition, true)
    GameObjectHelper.FastSetActive(self.wearEquipObj, true)
end

return CardEquipItemView