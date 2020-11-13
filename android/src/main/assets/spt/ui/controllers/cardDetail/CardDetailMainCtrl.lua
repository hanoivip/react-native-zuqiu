local UnityEngine = clr.UnityEngine
local Screen = UnityEngine.Screen
local Tweening = clr.DG.Tweening
local Vector2 = UnityEngine.Vector2
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local TweenExtensions = Tweening.TweenExtensions
local BaseCtrl = require("ui.controllers.BaseCtrl")
local CardDetailModel = require("ui.models.cardDetail.CardDetailModel")
local PlayerLevelUpCtrl = require("ui.controllers.cardDetail.PlayerLevelUpCtrl")
local PlayerUpgradeCtrl = require("ui.controllers.cardDetail.PlayerUpgradeCtrl")
local PlayerSkillCtrl = require("ui.controllers.cardDetail.PlayerSkillCtrl")
local BasePageCtrl = require("ui.controllers.cardDetail.BasePageCtrl")
local ChemicalPageCtrl = require("ui.controllers.cardDetail.ChemicalPageCtrl")
local TrainPageCtrl = require("ui.controllers.cardDetail.TrainPageCtrl")
local AscendPageCtrl = require("ui.controllers.cardDetail.AscendPageCtrl")
local MedalPageCtrl = require("ui.controllers.cardDetail.MedalPageCtrl")
local FeaturePageCtrl = require("ui.controllers.cardDetail.feature.FeaturePageCtrl")
local MemoryPageCtrl = require("ui.controllers.cardDetail.memory.MemoryPageCtrl")
local CardPowerCtrl = require("ui.controllers.cardDetail.CardPowerCtrl")
local CardDetailPageType = require("ui.scene.cardDetail.CardDetailPageType")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local CardDetailMainCtrl = class(BaseCtrl, "CardDetailMainCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")

CardDetailMainCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/CardDetailCanvas.prefab"

-- @param cardList 由pcid组成的数组
-- @param cardIndex cardList元素的索引
function CardDetailMainCtrl:Init(cardList, cardIndex, currentModel)
    self.cardsPageMap = {}
    self.subCtrl = {}
    -- view event handlers
    self.view.clickLeft = function() self:OnBtnLeft() end
    self.view.clickRight = function() self:OnBtnRight() end
    self.view.clickInstruction = function() self:OnBtnInstruction() end
    self.view.clickUpgrade = function()
        if not self.subCtrl.upgradeCtrl then
            self.subCtrl.upgradeCtrl = PlayerUpgradeCtrl.new(self.cardDetailModel, self.view.mountPoint)
        else
            self.subCtrl.upgradeCtrl:InitView(self.cardDetailModel)
        end

        self.currentFunctionCtrl = self.subCtrl.upgradeCtrl
    end
    self.view.clickLevelUp = function()
        if not self.subCtrl.levelUpCtrl then
            self.subCtrl.levelUpCtrl = PlayerLevelUpCtrl.new(self.cardDetailModel, self.view.mountPoint)
        else
            self.subCtrl.levelUpCtrl:InitView(self.cardDetailModel)
        end
        self.view.closeArea.gameObject:SetActive(true)
        self.currentFunctionCtrl = self.subCtrl.levelUpCtrl
    end
    self.view.clickSkill = function()
        if not self.subCtrl.skillCtrl then
            self.subCtrl.skillCtrl = PlayerSkillCtrl.new(self.cardDetailModel, self.view.mountPoint)
        else
            self.subCtrl.skillCtrl:InitView(self.cardDetailModel)
        end

        self.currentFunctionCtrl = self.subCtrl.skillCtrl
    end

    self.view.clickClose = function()
        if self.view.currentPageTag ~= nil then 
           --在转生-转会球员点击大卡时产生重复的currentPage
           --在Close时关闭
           local currentkey = self.view.currentPageTag
           self.cardsPageMap[currentkey]:ShowPageVisible(false)
           self.view.menuScript:selectMenuItem(CardDetailPageType.AscendPage)
        end
        clr.coroutine(function()
            unity.waitForEndOfFrame()
            res.PopSceneImmediate()
            -- 关闭球员大卡
            GuideManager.Show(res.curSceneInfo.ctrl)
        end)
    end

    self.view.resetCardDetailCallBack = function()
        self:RefreshViewWithCardIndex(self.cardIndex)
    end

    self.view.clickPage = function(key)
        self:OnBtnPage(key)
    end

    self.view.showDialog = function(cardDialogType)
        self:ShowDialog(cardDialogType)
    end

    self.view.onDestroy = function()
        self:OnDestroy()
    end

    self.view.clickPaster = function()
        self:OnBtnPaster()
    end

    self.view.clickFeatureInfo = function()
        self:OnBtnFeatureInfo()
    end
end

-- 技能和装备界面做了缓存，在大卡销毁时清理掉缓存
function CardDetailMainCtrl:OnDestroy()
    res.RemoveCache("Assets/CapstonesRes/Game/UI/Scene/SkillDetail/SkillDetail.prefab")
    res.RemoveCache("Assets/CapstonesRes/Game/UI/Scene/EquipDetail/EquipDetail.prefab")
end

function CardDetailMainCtrl:ShowDialog(cardDialogType)
    EventSystem.SendEvent("CardDetail_ShowDialog", cardDialogType)
end

-- 点击菜单按钮事件
function CardDetailMainCtrl:OnBtnPage(key)
    local prePage = self.cardDetailModel:GetCurrentPage()
    if self.cardsPageMap[prePage] then
        self.cardsPageMap[prePage]:ShowPageVisible(false)
    end

    if not self.cardsPageMap[key] then
        if key == CardDetailPageType.BasePage then
            self.cardsPageMap[key] = BasePageCtrl.new(nil, self.view.pageArea)
        elseif key == CardDetailPageType.ChemicalPage then
            self.cardsPageMap[key] = ChemicalPageCtrl.new(nil, self.view.pageArea)
        elseif key == CardDetailPageType.TrainPage then
            self.cardsPageMap[key] = TrainPageCtrl.new(nil, self.view.pageArea)
        elseif key == CardDetailPageType.AscendPage then
            self.cardsPageMap[key] = AscendPageCtrl.new(nil, self.view.pageArea)
        elseif key == CardDetailPageType.MedalPage then
            self.cardsPageMap[key] = MedalPageCtrl.new(nil, self.view.pageArea)
        elseif key == CardDetailPageType.FeaturePage then
            self.cardsPageMap[key] = FeaturePageCtrl.new(nil, self.view.pageArea)
        elseif key == CardDetailPageType.MemoryPage then
            self.cardsPageMap[key] = MemoryPageCtrl.new(nil, self.view.pageArea)
        end
        self.cardsPageMap[key]:EnterScene()
    end
    self.cardDetailModel:SetCurrentPage(key)
    self.cardsPageMap[key]:ShowPageVisible(true)
    self.cardsPageMap[key]:InitView(self.cardDetailModel)
end

function CardDetailMainCtrl:Refresh(cardList, cardIndex, currentModel, cardDetailModel, bShowScene)
    assert(cardList)
    CardDetailMainCtrl.super.Refresh(self)

    self.cardList = cardList
    self.cardIndex = cardIndex
    self.currentModel = currentModel
    self.bShowScene = bShowScene
    if cardDetailModel then 
        self.cardDetailModel = cardDetailModel
        self:InitCardDetailModel()
    else
        self.isInit = true -- 点击大卡标记
        self.cardDetailModel = CardDetailModel.new(currentModel)
        self.view:SetDefaultState(self.cardDetailModel)
    end
    self:InitView()
end

function CardDetailMainCtrl:GetStatusData()
    return self.cardList, self.cardIndex, nil, self.cardDetailModel, self.bShowScene
end

function CardDetailMainCtrl:OnEnterScene()
    self.view:EnterScene()
    for k, v in pairs(self.cardsPageMap) do
        v:EnterScene()
    end
    self.view.powerPlus:EnterScene()
end

function CardDetailMainCtrl:OnExitScene()
    self.view:ExitScene()
    for k, v in pairs(self.subCtrl) do
        if type(v.OnUnloadModule) == "function" then
            v:OnUnloadModule()
        end
    end
    for k, v in pairs(self.cardsPageMap) do
        v:ExitScene()
    end
    self.view.powerPlus:ExitScene()
end

function CardDetailMainCtrl:InitCardDetailModel()
    self.cardDetailModel:RefreshCardModel(self.cardList[self.cardIndex])
end

function CardDetailMainCtrl:InitView()
    self.view:InitView(self.cardDetailModel, nil, nil, self.bShowScene)
    self.view:SetRollAreaState(self.cardList)
    self:InitPower(self.cardDetailModel:GetCardModel():GetPower())
end

-- 默认玩家选择6位数，超R超过后会显示7位数
local PowerOverSize = 7
local DefaultSize = 6
local function GetPowerSize(powerValue)
    local size = 0
    while powerValue > 0 do
        powerValue = math.floor(powerValue / 10)
        size = size + 1
    end
    size = (size > DefaultSize) and size or DefaultSize
    return size
end

function CardDetailMainCtrl:InitPower(power)
    if not self.powerCtrl then 
        self.powerCtrl = CardPowerCtrl.new(self.view.powerParent)
    end

    local size = GetPowerSize(power)
    self.view:SetPowerAreaState(power, size)
    self.powerCtrl:InitWithProtocol(nil, size)
    self.powerCtrl:InitPower(power, self.isInit)
    self.isInit = false
end

local function GetRightIndex(currentIndex, arrayLength)
    return ((currentIndex + 1) > arrayLength) and 1 or (currentIndex + 1)
end

local function GetLeftIndex(currentIndex, arrayLength)
    return ((currentIndex - 1) < 1) and arrayLength or (currentIndex - 1)
end

function CardDetailMainCtrl:RepeatUntilVaildCardData(isLeft)
    local func
    if isLeft then
        func = GetLeftIndex
    else
        func = GetRightIndex
    end

    local tmpIndex = self.cardIndex
    repeat
        tmpIndex = func(tmpIndex, #self.cardList)
    until(self.cardDetailModel:IsExistCard(self.cardList[tmpIndex]))

    return tmpIndex
end

local MoveDistance = 1334
local FadeMinAlpha = 0.2
local PlayTime = 0.16
-- 向左移动对应卡牌向右选择
function CardDetailMainCtrl:OnBtnLeft()
    -- 转生功能会删除当前cardList中卡牌，所以要做一个判空的操作
    self:MoveEffect(true)
end

function CardDetailMainCtrl:OnBtnRight()
    self:MoveEffect(false)
end

function CardDetailMainCtrl:MoveEffect(isLeft)
    EventSystem.SendEvent("CardDetail_Change_Card")
    if self.moveOut then 
        TweenExtensions.Pause[Tweener](self.moveOut)
        TweenExtensions.Pause[Tweener](self.fadeOut)
    end
    if self.moveIn then 
        TweenExtensions.Pause[Tweener](self.moveIn)
        TweenExtensions.Pause[Tweener](self.fadeIn)
    end
    self.view.showAreaCanvasGroup.alpha = 1
    local ratio = isLeft and 1 or -1
    self.moveOut = ShortcutExtensions.DOAnchorPosX(self.view.showArea.transform, MoveDistance * ratio, PlayTime)
    self.fadeOut = ShortcutExtensions.DOFade(self.view.showAreaCanvasGroup, FadeMinAlpha, PlayTime)
    TweenSettingsExtensions.SetEase(self.moveOut, Ease.OutQuart)
    TweenSettingsExtensions.OnComplete(self.moveOut, function()  --Lua assist checked flag
        local cardIndex = self:RepeatUntilVaildCardData(isLeft)
        self.cardDetailModel:ClearChemicalChooseTag()
        self:RefreshViewWithCardIndex(cardIndex)
        self.view.showArea.transform.anchoredPosition = Vector2(MoveDistance * -ratio, 0)
        self.view.showAreaCanvasGroup.alpha = FadeMinAlpha
        self.moveIn = ShortcutExtensions.DOAnchorPosX(self.view.showArea.transform, 0, PlayTime * 2)
        TweenSettingsExtensions.SetEase(self.moveIn, Ease.OutQuart)
        self.fadeIn = ShortcutExtensions.DOFade(self.view.showAreaCanvasGroup, 1, PlayTime * 2)
    end)
end

function CardDetailMainCtrl:OnBtnInstruction()
    res.PushDialog("ui.controllers.cardMoreInfo.CardMoreInfoCtrl", self.cardDetailModel:GetCardModel():GetCid(), self.cardDetailModel:GetCardModel(), self.cardDetailModel)
end

function CardDetailMainCtrl:RefreshViewWithCardIndex(cardIndex)
    self.cardIndex = cardIndex
    self:InitCardDetailModel()
    self:InitView()
end

function CardDetailMainCtrl:OnBtnPaster()
    local cardModel = self.cardDetailModel:GetCardModel()
    local ownershipType = cardModel:GetOwnershipType()
    local showPasterPokedex =  cardModel:GetIsPasterPokedex()
    if ownershipType ~= CardOwnershipType.SELF and not showPasterPokedex then
        return
    end
    local hasPaster = cardModel:HasPaster()
    if showPasterPokedex then 
        res.PushDialog("ui.controllers.paster.PasterQueueCtrl", cardModel)
    elseif hasPaster then 
        res.PushDialog("ui.controllers.paster.PasterQueueCtrl", cardModel)
    else
        local hasPasterAvailable, hasPasterUsedByAll = cardModel:HasPasterAvailable()
        if hasPasterAvailable or hasPasterUsedByAll then
            res.PushDialog("ui.controllers.paster.PasterQueueCtrl", cardModel) 
        end
    end
end

function CardDetailMainCtrl:OnBtnFeatureInfo()
	local cardModel = self.cardDetailModel:GetCardModel()
	res.PushDialog("ui.controllers.cardDetail.feature.FeatureInfoCtrl", cardModel, self.bShowScene)
end

return CardDetailMainCtrl
