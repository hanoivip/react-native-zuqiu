local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local CardDialogType = require("ui.controllers.cardDetail.CardDialogType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardEnumerator = require("ui.common.card.CardEnumerator")
local AssetFinder = require("ui.common.AssetFinder")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local QuestInfoModel = require("ui.models.quest.QuestInfoModel")
local EventSystem = require("EventSystem")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local EventSystems = UnityEngine.EventSystems
local EquipDetailView = class(unity.base)

function EquipDetailView:ctor()
   self.btnClose = self.___ex.btnClose
   self.pieceQuality = self.___ex.pieceQuality
   self.pieceIcon = self.___ex.pieceIcon
   self.pieceName = self.___ex.pieceName
   self.quality = self.___ex.quality
   self.icon = self.___ex.icon
   self.nameTxt = self.___ex.name
   self.equipNum = self.___ex.equipNum
   self.pieceNeedNum = self.___ex.pieceNeedNum
   self.pieceAllNum = self.___ex.pieceAllNum
   self.desc = self.___ex.desc
   self.equipAttributeParent = self.___ex.equipAttributeParent
   self.scrollView = self.___ex.scrollView
   self.btnEquip = self.___ex.btnEquip
   self.equipDisable = self.___ex.equipDisable
   self.equipNormal = self.___ex.equipNormal
   self.animator = self.___ex.animator
   self.equipText = self.___ex.equipText
   self.pieceArea = self.___ex.pieceArea
   self.equipGradient = self.___ex.equipGradient
   self.equipArea = self.___ex.equipArea
   self.originCondition = self.___ex.originCondition
   self.originTip = self.___ex.originTip
   self.equipAttributeMap = {}
   self.transform.anchoredPosition = Vector2(10000, 10000) -- 在点击动画的时候先移走，让动画更流畅
end

function EquipDetailView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close(true)
    end)
    self.btnEquip:regOnButtonClick(function()
        self:OnBtnEquipClick()
    end)
end

-- isCloseButton 新手引导的时候屏蔽两侧点击关闭界面防止引导错误
function EquipDetailView:Close(isCloseButton)
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
        if not isCloseButton then 
            return 
        end
    end
    self.animator:Play("CardDialogRotateBackCN")
end

function EquipDetailView:ShowDialog(cardDialogType)
    if cardDialogType == CardDialogType.EQUIP then -- 在回到装备界面时还原位置
        self.transform.anchoredPosition = Vector2(0, 0)
        self.animator:Play("CardDialogRotateCN")
    end
end

function EquipDetailView:CloseDialog()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function EquipDetailView:OnShowDetail()
    if self.showDetail then 
        self.showDetail()
    end
end

function EquipDetailView:OnAnimationEnd()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem.enabled = true
    end
    self:CloseDialog()
end

local TheMinimumQuality = 1
function EquipDetailView:InitView(itemDetailModel, equipItemModel, model, slot)
    local equipNum = tonumber(itemDetailModel:GetEquipNum())
    self.equipNum.text = "x" .. tostring(equipNum)
    self.nameTxt.text = tostring(itemDetailModel:GetName())
    self.desc.text = tostring(itemDetailModel:GetNote())

    -- 只要满足装备不足但碎片够合成，装备或碎片满足等级不够都可点亮按钮
    self.isCanEquip = model:IsReachWearEquipCondition(slot)
    GameObjectHelper.FastSetActive(self.equipDisable, not self.isCanEquip)
    GameObjectHelper.FastSetActive(self.equipNormal, self.isCanEquip)
    if self.isCanEquip then 
        ButtonColorConfig.SetNormalGradientColor(self.equipGradient)
    else
        ButtonColorConfig.SetDisableGradientColor(self.equipGradient)
    end

    self:SetAttribute(itemDetailModel, model, slot)
    local isOpen = false
    if model and model:IsOperable() then
        isOpen = true
    end
    GameObjectHelper.FastSetActive(self.btnEquip.gameObject, isOpen)

    local iconSprite = AssetFinder.GetEquipIcon(equipItemModel:GetIconIndex())
    self.icon.overrideSprite = iconSprite
    local qualitySprite = AssetFinder.GetItemQualityBoard(equipItemModel:GetQuality())
    self.quality.overrideSprite = qualitySprite
    local isShowPiece = tobool(equipItemModel:GetQuality() > TheMinimumQuality)
    GameObjectHelper.FastSetActive(self.pieceArea.gameObject, isShowPiece)
    local equipMoveDis = 0
    if isShowPiece then
        self.pieceIcon.overrideSprite = iconSprite
        self.pieceQuality.overrideSprite = qualitySprite
        self.pieceName.text = tostring(itemDetailModel:GetName()) .. "\n" .. "<size=15>(" .. lang.transstr("piece") .. ")</size>"
        local currentPieceNum = tonumber(itemDetailModel:GetEquipPieceNum())
        local compositePieceNum = tonumber(itemDetailModel:GetCompositePieceNum())
        self.pieceAllNum.text = tostring(currentPieceNum)
        self.pieceNeedNum.text = tostring(compositePieceNum)
        equipMoveDis = 240
    end
    self.equipArea.anchoredPosition = Vector2(equipMoveDis, self.equipArea.anchoredPosition.y)

    local isEquiped = equipItemModel:IsEquip()
    if isEquiped then 
        self.equipText.text = lang.trans("be_equiped")
    else
        if equipNum <= 0 and self.isCanEquip then
            self.equipText.text = lang.trans("piece_compositeAndEquip")
        else
            self.equipText.text = lang.trans("equip")
        end
    end

    local originSource = itemDetailModel:GetEquipSource()
    local isAllowChangeScene = model:IsAllowChangeScene()
    self.scrollView:InitView(itemDetailModel, isAllowChangeScene)
    local isShowOriginTip = false
    if table.nums(originSource) > 0 then 
        local questInfoModel = QuestInfoModel.new()
        local longth = questInfoModel:MacthStageLongthToLastStageId(originSource[1])
        if longth > 0 then 
            isShowOriginTip = true
            self.originCondition.text = lang.trans("equip_origin_condition", longth)
        end
    end
    GameObjectHelper.FastSetActive(self.originTip.gameObject, isShowOriginTip)
end

-- 设置属性
function EquipDetailView:SetAttribute(itemDetailModel, model, slot)
    local plusTable = model:GetEquipAbilityPlus(slot)
    local pentagonOrder
    if model:IsGKPlayer() then
        pentagonOrder = CardEnumerator.GoalKeeperAttribute
    else
        pentagonOrder = CardEnumerator.NormalPlayerAttribute
    end

    local abilityValue = {}
    local count = 0
    for i, abilityIndex in ipairs(pentagonOrder) do
        local value = plusTable[abilityIndex]
        if value then 
            count = count + 1
            table.insert(abilityValue, { abilityIndex = abilityIndex, value = value})
        end
    end

    if count >= table.nums(pentagonOrder) then -- 检测五位属性值是否相同，相同则改为全属性
        local matchValue = abilityValue[1].value
        local isAllAttribute = true
        for i, v in ipairs(abilityValue) do
            if v.value ~= matchValue then     
                isAllAttribute = false
                break
            end
        end
        if isAllAttribute then
            abilityValue = { abilityIndex = "allAttribute", value = matchValue } 
        end
    end

    for i, v in ipairs(abilityValue) do
        local equipAttributeView = self.equipAttributeMap[i]
        if not equipAttributeView then 
            local attributeObj, attributeSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/EquipDetail/EquipAttributeItem.prefab")
            attributeObj.transform:SetParent(self.equipAttributeParent, false)
            self.equipAttributeMap[i] = attributeSpt
        end
        GameObjectHelper.FastSetActive(self.equipAttributeMap[i].gameObject, true)
        self.equipAttributeMap[i]:InitView(v.abilityIndex, v.value)
    end

    for i = table.nums(abilityValue) + 1, table.nums(self.equipAttributeMap) do
        GameObjectHelper.FastSetActive(self.equipAttributeMap[i].gameObject, false)
    end
end

function EquipDetailView:EnterScene()
    EventSystem.AddEvent("PlayerCardModel_WearEquip", self, self.EventWearEquip)
    EventSystem.AddEvent("ItemDetailModel_ResetEquipNum", self, self.EventResetEquipNum)
    EventSystem.AddEvent("ItemDetailModel_ResetEquipAndPiece", self, self.EventResetEquipAndPiece)
    EventSystem.AddEvent("CardDetail_ShowDialog", self, self.ShowDialog)
end

function EquipDetailView:ExitScene()
    EventSystem.RemoveEvent("PlayerCardModel_WearEquip", self, self.EventWearEquip)
    EventSystem.RemoveEvent("ItemDetailModel_ResetEquipNum", self, self.EventResetEquipNum)
    EventSystem.RemoveEvent("ItemDetailModel_ResetEquipAndPiece", self, self.EventResetEquipAndPiece)
    EventSystem.RemoveEvent("CardDetail_ShowDialog", self, self.ShowDialog)
end

function EquipDetailView:EventResetEquipAndPiece()
    if self.resetEquipAndPieceCallBack then
        self.resetEquipAndPieceCallBack()
    end
end

function EquipDetailView:EventWearEquip()
    if self.wearEquipCallBack then
        self.wearEquipCallBack()
    end
end

function EquipDetailView:EventResetEquipNum()
    if self.resetEquipNumCallBack then
        self.resetEquipNumCallBack()
    end
end

function EquipDetailView:OnBtnEquipClick()
    if self.clickEquip then
        self.clickEquip(self.isCanEquip)
    end
end

return EquipDetailView
