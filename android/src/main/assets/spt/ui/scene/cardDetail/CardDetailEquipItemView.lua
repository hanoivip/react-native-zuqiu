local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardDetailEquipItemView = class(unity.base)
local tostring = tostring
local tobool = tobool

function CardDetailEquipItemView:ctor()
    self.nameTxt = self.___ex.name
    self.equipSign = self.___ex.equipSign
    self.button = self.___ex.button
    self.equipIcon = self.___ex.equipIcon
    self.board = self.___ex.board
    self.equipTipObject = self.___ex.equipTipObject
    self.equipTip = self.___ex.equipTip
    -- װ����Ч
    self.baseIcon = self.___ex.baseIcon
    self.equipEffect1 = self.___ex.equipEffect1
    self.equipEffect2 = self.___ex.equipEffect2
    self.equipAnimation = self.___ex.equipAnimation
    self.equipObject = self.___ex.equipObject
    self.iconImageRes = nil
end

function CardDetailEquipItemView:InitView(equipItemModel, cardDetailModel, eid)
    self.slot = equipItemModel:GetSlot()
    local isReachCondition = cardDetailModel:IsOperable() and cardDetailModel:IsReachWearEquipCondition(self.slot) or false
    self.nameTxt.text = tostring(equipItemModel:GetName())
    self.iconImageRes = AssetFinder.GetEquipIcon(equipItemModel:GetIconIndex())
    self.equipIcon.overrideSprite = self.iconImageRes
    self.board.overrideSprite = AssetFinder.GetItemQualityBoard(equipItemModel:GetQuality())

    local isShowLevelCondition = false
    local isReachLevel, needCardLevel = false, 0
    local isEquip = equipItemModel:IsEquip()
    local showColor = Color(1, 1, 1)
    if not isEquip then 
        showColor = Color(0, 1, 1)
        if isReachCondition then 
            isReachLevel, needCardLevel = cardDetailModel:IsEquipToReachCardLevel(self.slot)
            if not isReachLevel then 
                local levelStr = "Lv." .. needCardLevel
                isShowLevelCondition = true
                self.equipTip.text = lang.trans("need_level", levelStr)
            end
        end
    end
    GameObjectHelper.FastSetActive(self.equipTipObject, isShowLevelCondition)
    GameObjectHelper.FastSetActive(self.equipSign, tobool(isReachCondition and isReachLevel))
    self.equipIcon.color = showColor
    self.board.color = showColor
    self:SetEquipEffectState(false)
    -- ��Чδ����ʱ���뻹ԭ
    self.equipObject.anchoredPosition = Vector2(0, 20)
    self.equipObject.localScale = Vector3(1, 1, 1)
    self.equipIcon.fillAmount = 1
end

function CardDetailEquipItemView:SetEquipEffectState(isEquip)
    GameObjectHelper.FastSetActive(self.baseIcon.gameObject, isEquip)
    GameObjectHelper.FastSetActive(self.equipEffect1, isEquip)
    GameObjectHelper.FastSetActive(self.equipEffect2, isEquip)
    self.equipAnimation.enabled = isEquip
    if isEquip then 
        self.baseIcon.overrideSprite = self.iconImageRes
    end
end

function CardDetailEquipItemView:WearEquip(slot)
    if tostring(self.slot) == tostring(slot) then 
        GameObjectHelper.FastSetActive(self.gameObject, false)
        self:SetEquipEffectState(true)
        GameObjectHelper.FastSetActive(self.gameObject, true)
    end
end

return CardDetailEquipItemView