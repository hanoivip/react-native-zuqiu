local ItemDetailView = class(unity.base)

local EventSystem = require("EventSystem")
local QuestJumpNodeCtrl = require("ui.controllers.quest.QuestJumpNodeCtrl")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local UISoundManager = require("ui.control.manager.UISoundManager")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local tostring = tostring
local tonumber = tonumber
local tobool = tobool

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Color = UnityEngine.Color

-- 以中上第一个顺时针表示顺序
local normalPlayerOrder = {
    "shoot",
    "intercept",
    "steal",
    "dribble",
    "pass"
}
local goalKeeperOrder = {
    "goalkeeping",  -- 门线技术
    "anticipation", -- 球路判断
    "commanding",   -- 防线指挥
    "composure",    -- 心理素质
    "launching"     -- 发起进攻
}

local function GetPolygonColorAndMaxValue(value)
    local color
    local maxValue
    if value <= 100 then
        maxValue = 100
        color = Color(0, 1, 0, 0.8)
    elseif value <= 300 then
        maxValue = 300
        color = Color(0, 0, 1, 0.8)
    elseif value <= 900 then
        maxValue = 900
        color = Color(1, 0, 1, 0.8)
    elseif value <= 2700 then
        maxValue = 2700
        color = Color(1, 0.5, 0, 0.8)
    elseif value <= 8100 then
        maxValue = 8100
        color = Color(1, 0, 0, 0.8)
    elseif value <= 24300 then
        maxValue = 24300
        color = Color(1, 0.8, 0.1, 0.8)
    else
        maxValue = value
        color = Color(0, 1, 0, 0.8)
    end

    color = Color(0.58, 0.86, 0.25, 0.8)

    return color, maxValue
end

local langPackMap = {
    pass = "passWithValue",
    dribble = "dribbleWithValue",
    shoot = "shootWithValue",
    intercept = "interceptWithValue",
    steal = "stealWithValue",
    save = "saveWithValue",
    goalkeeping = "goalkeepingWithValue",
    anticipation = "anticipationWithValue",
    commanding = "commandingWithValue",
    composure = "composureWithValue",
    launching = "launchingWithValue"
}

function ItemDetailView:ctor()
    self.close = self.___ex.close
    self.btnUse = self.___ex.btnUse
    self.btnComposite = self.___ex.btnComposite
    self.itemParent = self.___ex.itemParent
    self.itemName = self.___ex.itemName
    self.desc = self.___ex.desc
    self.useButton = self.___ex.useButton
    self.pieceResource = self.___ex.pieceResource
    self.commonResource = self.___ex.commonResource
    self.pieceTip = self.___ex.pieceTip
    self.pieceName = self.___ex.pieceName
    self.pieceNum = self.___ex.pieceNum
    self.compositeButton = self.___ex.compositeButton
    self.commonContent = self.___ex.commonContent
    self.pieceContent = self.___ex.pieceContent
    self.pieceIconParent = self.___ex.pieceIconParent

    self.ploygonCustom = self.___ex.ploygonCustom
    self.pentagonText = self.___ex.pentagonText     -- table
    self.pentagonValue = self.___ex.pentagonValue   -- table
    self.useText = self.___ex.useText
    self.compositeText = self.___ex.compositeText
    self.useNormalLight = self.___ex.useNormalLight
    self.useDisableLight = self.___ex.useDisableLight
    self.compositeNormalLight = self.___ex.compositeNormalLight
    self.compositeDisableLight = self.___ex.compositeDisableLight

    self.effectUseBtn = self.___ex.effectUseBtn
    self.effectCompositeButton = self.___ex.effectCompositeButton
end

function ItemDetailView:start()
    -- button事件注册
    self.btnUse:regOnButtonClick(function()
        UISoundManager.play('Player/encourageSound', 1)
        self:OnBtnUseClick()
    end)
    self.btnComposite:regOnButtonClick(function()
        self:OnBtnCompositeClick()
    end)
    self.close:regOnButtonClick(function()
        local closeFunc = function()
            if type(self.closeDialog) == "function" then
                self.closeDialog()
            end
            if type(self.clickClose) == "function" then
                self.clickClose()
            end
        end
        DialogAnimation.Disappear(self.transform, nil, closeFunc)
    end)
    DialogAnimation.Appear(self.transform)
end

function ItemDetailView:EnterScene()
    EventSystem.AddEvent("PlayerCardModel_WearEquip", self, self.EventWearEquip)
    EventSystem.AddEvent("ItemDetailModel_ResetEquipNum", self, self.EventResetEquipNum)
    EventSystem.AddEvent("ItemDetailModel_ResetEquipAndPiece", self, self.EventResetEquipAndPiece)
end

function ItemDetailView:ExitScene()
    EventSystem.RemoveEvent("PlayerCardModel_WearEquip", self, self.EventWearEquip)
    EventSystem.RemoveEvent("ItemDetailModel_ResetEquipNum", self, self.EventResetEquipNum)
    EventSystem.RemoveEvent("ItemDetailModel_ResetEquipAndPiece", self, self.EventResetEquipAndPiece)
end

function ItemDetailView:EventResetEquipAndPiece()
    if self.resetEquipAndPieceCallBack then
        self.resetEquipAndPieceCallBack()
    end
end

function ItemDetailView:EventWearEquip()
    if self.wearEquipCallBack then
        self.wearEquipCallBack()
    end
end

function ItemDetailView:EventResetEquipNum()
    if self.resetEquipNumCallBack then
        self.resetEquipNumCallBack()
    end
end

function ItemDetailView:OnBtnUseClick()
    if self.clickUse then
        self.clickUse()
    end
end

function ItemDetailView:OnBtnCompositeClick()
    if self.clickComposite then
        self.clickComposite()
    end
end


function ItemDetailView:ShowItem(equipItemModel)
    if  not self.itemScript then 
        local prefab, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Part/EquipBox.prefab")
        prefab.transform:SetParent(self.itemParent.transform, false)
        self.itemScript = spt
        spt:InitView(equipItemModel, nil, false, true)
    else
        self.itemScript:BuildPage()
    end
end

function ItemDetailView:SetUseButtonState(isUseActive)
    self.useButton.interactable = isUseActive
    self.effectUseBtn:SetActive(isUseActive)
    self.btnUse:onPointEventHandle(isUseActive)
    local color = isUseActive and Color(0.478, 0.306, 0.118) or Color(0.196, 0.196, 0.196)
    self.useText.color = color
    GameObjectHelper.FastSetActive(self.useNormalLight, isUseActive)
    GameObjectHelper.FastSetActive(self.useDisableLight, not isUseActive)
end

function ItemDetailView:SetCompositeButtonState(isComposite)
    self.compositeButton.interactable = isComposite
    if isComposite and not self.useButton.interactable and self.canWear then
        self.effectCompositeButton:SetActive(true)
    else
        self.effectCompositeButton:SetActive(false)
    end
    self.btnComposite:onPointEventHandle(isComposite)
    local color = isComposite and Color(0.478, 0.306, 0.118) or Color(0.196, 0.196, 0.196)
    self.compositeText.color = color
    GameObjectHelper.FastSetActive(self.compositeNormalLight, isComposite)
    GameObjectHelper.FastSetActive(self.compositeDisableLight, not isComposite)
end

function ItemDetailView:InitView(itemDetailModel, cardModel, isOperable, slot)
    self:ShowItem(itemDetailModel:GetEquipModel())
    self.canWear = cardModel:CanWearEquip(slot)
    
    self.itemName.text = tostring(itemDetailModel:GetName())
    self.desc.text = tostring(itemDetailModel:GetNote())

    if cardModel and cardModel:GetOwnershipType() == CardOwnershipType.SELF then
        local isUseActive = tobool(itemDetailModel:GetEquipNum() > 0 and cardModel:CanWearEquip(slot))
        self:SetUseButtonState(isUseActive)
    else
        self:SetUseButtonState(false)
    end

    local isChildSmall

    if itemDetailModel:GetCompositePieceNum() > 1 then
        self.pieceResource:SetActive(true)
        self.commonResource:SetActive(false)
        self.pieceTip:SetActive(true)

        self.pieceName.text = tostring(itemDetailModel:GetPieceName())
        local currentPieceNum = itemDetailModel:GetEquipPieceNum()
        local compositePieceNum = itemDetailModel:GetCompositePieceNum()
        self.pieceNum.text = tostring(currentPieceNum) .. " / " .. tostring(compositePieceNum)
        self:SetCompositeButtonState(tobool(currentPieceNum >= compositePieceNum))
        isChildSmall = true
        self.contentTransform = self.pieceContent.transform
    else
        self.pieceResource:SetActive(false)
        self.commonResource:SetActive(true)
        self.pieceTip:SetActive(false)
        self:SetCompositeButtonState(false)
        self.contentTransform = self.commonContent.transform      
    end

    -- clear scroll comp
    local count = self.contentTransform.childCount
    for i = 1, count do
        Object.Destroy(self.contentTransform:GetChild(i - 1).gameObject)
    end

    if not isOperable then
        self:SetCompositeButtonState(false)
        self:SetUseButtonState(false)
    end

    local plusTable = cardModel:GetEquipAbilityPlus(slot)

    local pentagonOrder
    if cardModel:IsGKPlayer() then
        pentagonOrder = goalKeeperOrder
    else
        pentagonOrder = normalPlayerOrder
    end

    local fiveAbilityValueList = {}
    local maxAbilityValue = -1
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus = cardModel:GetAbility(abilityIndex)
        if base + plus > maxAbilityValue then
            maxAbilityValue = base + plus
        end
        table.insert(fiveAbilityValueList, base + plus)
        self.pentagonText["p" .. tostring(i)].text = lang.trans(abilityIndex)
        if plusTable[abilityIndex] then
            self.pentagonValue["p" .. tostring(i)].text = "+" .. tostring(plusTable[abilityIndex])
        else
            self.pentagonValue["p" .. tostring(i)].text = "-"
        end
    end

    local color, maxValue = GetPolygonColorAndMaxValue(maxAbilityValue)
    local abilityValues = {
        math.sqrt(fiveAbilityValueList[1] / maxValue),
        math.sqrt(fiveAbilityValueList[2] / maxValue),
        math.sqrt(fiveAbilityValueList[3] / maxValue),
        math.sqrt(fiveAbilityValueList[4] / maxValue),
        math.sqrt(fiveAbilityValueList[5] / maxValue),
    }
    self.ploygonCustom.color = color
    self.ploygonCustom.maxValue = 1
    self.ploygonCustom.abilityValues = clr.array(abilityValues, clr.System.Single)
    self.ploygonCustom:SetAllDirty()
end

function ItemDetailView:onDestroy()
end

function ItemDetailView:SetEquipSource(itemDetailModel, isSmall, isAllowChangeScene)
    local sourceIdTable = itemDetailModel:GetEquipSource()

    if #sourceIdTable > 0 then
        for i, v in ipairs(sourceIdTable) do
            QuestJumpNodeCtrl.new(v, self.contentTransform, isSmall, isAllowChangeScene, self.requiredEquipId)
        end
    end
end

return ItemDetailView
