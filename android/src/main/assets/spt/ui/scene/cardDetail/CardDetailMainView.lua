local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local EventSystem = require("EventSystem")
local CardDetailPageType = require("ui.scene.cardDetail.CardDetailPageType")
local CardConfig = require("ui.common.card.CardConfig")
local CardDialogType = require("ui.controllers.cardDetail.CardDialogType")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardDetailMainView = class(unity.base, "CardDetailMainView")

function CardDetailMainView:ctor()
    self.btnClose = self.___ex.btnClose
    self.btnLeft = self.___ex.btnLeft
    self.btnRight = self.___ex.btnRight
    self.menuScript = self.___ex.menuScript  -- 卡牌标签菜单
    self.transferMoney = self.___ex.transferMoney
    self.pageArea = self.___ex.pageArea -- 卡牌页面父节点
    self.cardParent = self.___ex.cardParent
    self.cardName = self.___ex.cardName
    self.showArea = self.___ex.showArea
    self.showAreaCanvasGroup = self.___ex.showAreaCanvasGroup
    self.animator = self.___ex.animator
    self.position = self.___ex.position -- table
    self.position_label= self.___ex.position_label -- table
    self.powerPlus = self.___ex.powerPlus
    self.playerInstruction = self.___ex.playerInstruction
    self.powerParent = self.___ex.powerParent
    self.btnPaster = self.___ex.btnPaster
    self.pasterSign = self.___ex.pasterSign
    self.pasterSignObject = self.___ex.pasterSignObject
    self.infobar = self.___ex.infobar
    self.priceBorder = self.___ex.priceBorder
    self.courtBorder = self.___ex.courtBorder
    self.bg = self.___ex.bg
    self.tagBase = self.___ex.tagBase
    self.tagChemical = self.___ex.tagChemical
    self.tagTrain = self.___ex.tagTrain
    self.tagAscend = self.___ex.tagAscend
    self.tagMedal = self.___ex.tagMedal
    self.tagFeature = self.___ex.tagFeature
    self.tagMemory = self.___ex.tagMemory -- 传奇记忆页签
    self.powerText = self.___ex.powerText
    self.posText = self.___ex.posText
    self.shadowName = self.___ex.shadowName
    self.shadowPowerText = self.___ex.shadowPowerText
    self.shadowPosText = self.___ex.shadowPosText
    self.menuGrid = self.___ex.menuGrid
    self.menuScrollRect = self.___ex.menuScrollRect
    -- 位置调整
    self.priceRectTransf = self.___ex.priceRectTransf
    self.powerRectTransf = self.___ex.powerRectTransf
    self.posRectTransf = self.___ex.posRectTransf
    self.btnFeatureInfo = self.___ex.btnFeatureInfo
    self.myScene = self.___ex.myScene
    self.cardDialogType = CardDialogType.NONE
end

function CardDetailMainView:start()
    self.btnClose:regOnButtonClick(function()
        self:PlayLeaveAnimation()
    end)

    self.btnLeft:regOnButtonClick(function()
        self:OnBtnLeft()
    end)

    self.btnRight:regOnButtonClick(function()
        self:OnBtnRight()
    end)

    self.playerInstruction:regOnButtonClick(function()
        self:OnBtnInstruction()
    end)

    self.btnPaster:regOnButtonClick(function()
        self:OnBtnPaster()
    end)

    self.btnFeatureInfo:regOnButtonClick(function()
        self:OnBtnFeatureInfo()
    end)
    
    local menu = self.menuScript.___ex.menu
    for key, page in pairs(menu) do
        page:regOnButtonClick(function()
            self:OnBtnMenu(key)
        end)
    end
end

-- 还原默认状态
function CardDetailMainView:SetDefaultState(cardDetailModel)
    for i = 1, self.pageArea.childCount do
        local child = self.pageArea:GetChild(i - 1)
        GameObjectHelper.FastSetActive(child.gameObject, false)
    end
    self.menuScript:selectMenuItem(cardDetailModel:GetCurrentPage())
    self.menuScript.gameObject.transform.anchoredPosition = Vector2(13, 0)
end

function CardDetailMainView:SetRollAreaState(cardList)
    local isShow = false
    if type(cardList) == 'table' and table.nums(cardList) > 1 then 
        isShow = true
    end
    GameObjectHelper.FastSetActive(self.btnLeft.gameObject, isShow)
    GameObjectHelper.FastSetActive(self.btnRight.gameObject, isShow)
end

function CardDetailMainView:OnBtnMenu(key)
    if key == self.currentPageTag then return end
    self.currentPageTag = key
    self:OnBtnPage(key)
end

function CardDetailMainView:OnBtnPage(key)
    if self.clickPage then
        self.clickPage(key)
    end
end

function CardDetailMainView:OnDragEvent(isRight)
    if isRight then
        self:OnBtnRight()
    else
        self:OnBtnLeft()
    end
end

function CardDetailMainView:OnBtnFeatureInfo()
    if self.clickFeatureInfo then
        self.clickFeatureInfo()
    end
end

function CardDetailMainView:OnBtnLeft()
    if self.clickLeft then
        self.clickLeft()
    end
end

function CardDetailMainView:OnBtnRight()
    if self.clickRight then
        self.clickRight()
    end
end

function CardDetailMainView:OnBtnInstruction()
    if self.clickInstruction then
        self.clickInstruction()
    end
end

function CardDetailMainView:OnBtnPaster()
    if self.clickPaster then
        self.clickPaster()
    end
end

function CardDetailMainView:InitView(cardDetailModel, isOperable, currentPage, bShowScene)
    local cardModel = cardDetailModel:GetCardModel()
    local pasterManagerModel = cardDetailModel:GetPasterManagerModel()
    self:SetMenuState(cardDetailModel, cardModel)
    self:SetGeneralData(cardModel, cardDetailModel)
    self:SetFeatureLayout(cardModel, bShowScene)

    local hasPasterAvailable, hasPasterUsedByAll = false, false
    local hasPaster = cardModel:HasPaster()
    local pasterSignPos = Vector2(40, 55)
    --图鉴展示优先
    if cardModel:GetIsPasterPokedex() then
        self.pasterSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Pokedex.png")
        self.pasterSign:SetNativeSize()
        pasterSignPos = Vector2(45, 60)
    elseif hasPaster then 
        local pasterType = cardModel:GetPasterMainType()
        self.pasterSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Identity" .. pasterType .. ".png")
        self.pasterSign:SetNativeSize()
        local isMonthPaster = tobool(tonumber(pasterType) == 2)
        pasterSignPos = isMonthPaster and Vector2(50, 60) or pasterSignPos
    else
        hasPasterAvailable, hasPasterUsedByAll = cardModel:HasPasterAvailable()
        hasPasterAvailable = hasPasterAvailable or hasPasterUsedByAll
        if hasPasterAvailable then 
            self.pasterSign.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Common/Card/Paster/Image/Paster_Identity.png")
            self.pasterSign:SetNativeSize()
            pasterSignPos = Vector2(45, 60)
        end
    end
    self.pasterSignObject.transform.anchoredPosition = pasterSignPos
    GameObjectHelper.FastSetActive(self.pasterSignObject.gameObject, hasPaster or hasPasterAvailable or cardModel:GetIsPasterPokedex())
end

function CardDetailMainView:SetFeatureLayout(cardModel, bShowScene)
    local isFeatureOpen = cardModel:IsCoachFeatureOpen()
    local priceHeight = isFeatureOpen and 32.6 or 20
    local powerHeight = isFeatureOpen and -37 or -60.4
    local posHeight = isFeatureOpen and 62 or 23
    self.priceRectTransf.anchoredPosition = Vector2(self.priceRectTransf.anchoredPosition.x, priceHeight)
    self.powerRectTransf.anchoredPosition = Vector2(self.powerRectTransf.anchoredPosition.x, powerHeight)
    self.posRectTransf.anchoredPosition = Vector2(self.posRectTransf.anchoredPosition.x, posHeight)
    GameObjectHelper.FastSetActive(self.btnFeatureInfo.gameObject, not bShowScene and isFeatureOpen)
    GameObjectHelper.FastSetActive(self.myScene.gameObject, bShowScene and isFeatureOpen)
    if bShowScene and isFeatureOpen then
        if not self.mySceneSpt then
            local Obj, Spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/MyScene/MySceneEnterView.prefab")
            Obj.transform:SetParent(self.myScene, false)
            self.mySceneSpt = Spt
        end
        self.mySceneSpt:InitView(4)
        self.mySceneSpt.lookClick = function() self:OnBtnFeatureInfo() end 
    end
end

function CardDetailMainView:SetPosition(position)
    assert(type(position) == "table")
    for k, v in pairs(self.position) do
        GameObjectHelper.FastSetActive(v, false)
    end
    for i, v in ipairs(position) do
        local pos = self.position["p" .. tostring(CardConfig.POSITION_LETTER_MAP[v])]
        GameObjectHelper.FastSetActive(pos, true)
    end
end

-- 基本上玩家只到6位数，除非超R
local MaxSize = 8
local PowerOverSize = 7
function CardDetailMainView:SetPowerAreaState(power, size)
    if size >= MaxSize then
        self.powerParent.anchoredPosition = Vector2(74, 3)
        self.powerParent.localScale = Vector3(0.46, 0.46, 1)
    elseif size == PowerOverSize then
        self.powerParent.anchoredPosition = Vector2(82, 3)
        self.powerParent.localScale = Vector3(0.5, 0.5, 1)
    else
        self.powerParent.anchoredPosition = Vector2(88.5, 3)
        self.powerParent.localScale = Vector3(0.55, 0.55, 1)
    end
    self.powerPlus:InitPower(power)
end

local function MenuOpenState(isMenuOpen)
    local openCount = isMenuOpen and 1 or 0
    return openCount
end

-- MenuMaxCount 最大固定显示menu
local MenuMaxCount = 5
-- 设置标签也开放状态(在球员没有开放化学，培养，转生功能时跳转至指定功能)
function CardDetailMainView:SetMenuState(cardDetailModel, cardModel)
    self.currentPageTag = cardDetailModel:GetCurrentPage()
    local currentPageTag = cardDetailModel:GetCurrentPage()
    local isBaseOpen = true
    local isChemicalOpen = next(cardModel:GetChemicalData())
    local isTrainOpen = cardModel:IsTrainOpen()
    local isAscendOpen = cardModel:IsRebornOpen()
    local isMedalOpen = cardModel:IsMedalOpen()
    local isFeatureOpen = cardModel:IsCoachFeatureOpen()
    local isMemoryOpen = cardModel:IsMemoryOpen() -- 是否开启传奇记忆功能

    -- 如果触发事件且逻辑判断未开启，切换到BasePage
    if currentPageTag == CardDetailPageType.ChemicalPage and not isChemicalOpen then
        self.currentPageTag = CardDetailPageType.BasePage
    elseif currentPageTag == CardDetailPageType.TrainPage and not isTrainOpen then
        self.currentPageTag = CardDetailPageType.BasePage
    elseif currentPageTag == CardDetailPageType.AscendPage and not isAscendOpen then
        self.currentPageTag = CardDetailPageType.BasePage
    elseif currentPageTag == CardDetailPageType.MedalPage and not isMedalOpen then
        self.currentPageTag = CardDetailPageType.BasePage
    elseif currentPageTag == CardDetailPageType.FeaturePage and not isFeatureOpen then
        self.currentPageTag = CardDetailPageType.BasePage
    elseif currentPageTag == CardDetailPageType.MemoryPage and not isMemoryOpen then
        self.currentPageTag = CardDetailPageType.BasePage
    end
    self:OnBtnPage(self.currentPageTag)

    local menuOpenCount = MenuOpenState(isBaseOpen) + MenuOpenState(isChemicalOpen) + MenuOpenState(isTrainOpen)+ MenuOpenState(isAscendOpen)
                        + MenuOpenState(isMedalOpen) + MenuOpenState(isFeatureOpen) + MenuOpenState(isMemoryOpen)
    local scrollEnabled = false
    local defaultWidth, defaultHeight = 58, 151
    local defaultSpaceX, defaultSpaceY = 0, 2
    local cellSize = Vector2(defaultWidth, defaultHeight)
    local spacing = Vector2(defaultSpaceX, defaultSpaceY)
    self.menuGrid.enabled = false
    self.menuGrid.transform.anchoredPosition = Vector2(13, 0)
    if menuOpenCount == MenuMaxCount then
        cellSize = Vector2(58, 126)
        spacing = Vector2(0, -5)
    elseif menuOpenCount > MenuMaxCount then -- 滑动的按钮需要跳转至选定功能菜单
        scrollEnabled = true
        cellSize = Vector2(58, 126)
        spacing = Vector2(0, -5)
        local parentHegiht = self.menuScrollRect.transform.rect.height
        local currentMenuHeight = defaultHeight * menuOpenCount + (menuOpenCount - 1) * 2
        local menuIndex = CardDetailPageType.PageAscOrder[self.currentPageTag]
        local offset = menuIndex / menuOpenCount * currentMenuHeight - parentHegiht
        offset = offset < 0 and 0 or offset
        self.menuGrid.transform.anchoredPosition = Vector2(13, offset)
    end
    self.menuGrid.cellSize = cellSize
    self.menuGrid.spacing = spacing
    self.menuScrollRect.enabled = scrollEnabled
    self.menuScript:selectMenuItem(self.currentPageTag)
    GameObjectHelper.FastSetActive(self.menuScript.menu[CardDetailPageType.ChemicalPage].gameObject, isChemicalOpen)
    GameObjectHelper.FastSetActive(self.menuScript.menu[CardDetailPageType.TrainPage].gameObject, isTrainOpen)
    GameObjectHelper.FastSetActive(self.menuScript.menu[CardDetailPageType.AscendPage].gameObject, isAscendOpen)
    GameObjectHelper.FastSetActive(self.menuScript.menu[CardDetailPageType.MedalPage].gameObject, isMedalOpen)
    GameObjectHelper.FastSetActive(self.menuScript.menu[CardDetailPageType.FeaturePage].gameObject, isFeatureOpen)
    GameObjectHelper.FastSetActive(self.menuScript.menu[CardDetailPageType.MemoryPage].gameObject, isMemoryOpen)
    self.menuGrid.enabled = true
end

-- 设置通用界面数据
function CardDetailMainView:SetGeneralData(cardModel, cardDetailModel)
    local valueFormat = string.formatNumWithUnit(cardModel:GetValue())
    self.transferMoney.text = valueFormat

    if not self.cardView then
        local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        cardObject.transform:SetParent(self.cardParent, false)
        self.cardView = cardSpt
        self.cardView:IsShowName(false)
    end
    self.cardName.text = tostring(cardModel:GetName())
    self.cardView:InitView(cardModel)

    -- 场上位置
    self:SetPosition(cardModel:GetPosition())

    self.infobar.overrideSprite = cardDetailModel:GetImageRes("infobar")
    self.priceBorder.overrideSprite = cardDetailModel:GetImageRes("priceBorder")
    self.courtBorder.overrideSprite = cardDetailModel:GetImageRes("courtBorder")
    self.bg.overrideSprite = cardDetailModel:GetImageRes("bg")
    self.tagBase.overrideSprite = cardDetailModel:GetImageRes("tagBase")
    self.tagChemical.overrideSprite = cardDetailModel:GetImageRes("tagChemical")
    self.tagTrain.overrideSprite = cardDetailModel:GetImageRes("tagTrain")
    self.tagAscend.overrideSprite = cardDetailModel:GetImageRes("tagAscend")
    self.tagMedal.overrideSprite = cardDetailModel:GetImageRes("tagMedal")
    self.tagFeature.overrideSprite = cardDetailModel:GetImageRes("tagFeature")
    self.tagMemory.overrideSprite = cardDetailModel:GetImageRes("tagMemory")
    self.cardName.color = cardDetailModel:GetTextColor("text_name")
    self.powerText.color = cardDetailModel:GetTextColor("text_powerText")
    self.posText.color = cardDetailModel:GetTextColor("text_posText")
    self.shadowName.effectColor = cardDetailModel:GetTextColor("text_shadow_name")
    self.shadowPowerText.effectColor = cardDetailModel:GetTextColor("text_shadow_powerText")
    self.shadowPosText.effectColor = cardDetailModel:GetTextColor("text_shadow_posText")
end

function CardDetailMainView:CreateLevelUpPage()
    if self.clickLevelUp then 
        self.clickLevelUp()
    end
end

function CardDetailMainView:EventResetCardDetail()
    if self.resetCardDetailCallBack then
        self.resetCardDetailCallBack()
    end
end

function CardDetailMainView:EnterScene()
    EventSystem.AddEvent("PlayerCardsMapModel_ResetCardModel", self, self.EventResetCardDetail)
    EventSystem.AddEvent("CreateLevelUpPage", self, self.CreateLevelUpPage)
    EventSystem.AddEvent("PlayerCardModel_UpdateSkillLevelUp", self, self.EventResetCardDetail)
    EventSystem.AddEvent("CardDetailModel_AddExp", self, self.EventResetCardDetail)
    EventSystem.AddEvent("CardDetailDrag", self, self.OnDragEvent)
    EventSystem.AddEvent("PlayerCardModel_WearEquip", self, self.EventResetCardDetail)
    EventSystem.AddEvent("CardDetail_ClickDialog", self, self.EventClickDialog)
    EventSystem.AddEvent("CardDetail_ShowDetail", self, self.EventShowDetail)
end

function CardDetailMainView:ExitScene()
    EventSystem.RemoveEvent("PlayerCardsMapModel_ResetCardModel", self, self.EventResetCardDetail)
    EventSystem.RemoveEvent("CreateLevelUpPage", self, self.CreateLevelUpPage)
    EventSystem.RemoveEvent("PlayerCardModel_UpdateSkillLevelUp", self, self.EventResetCardDetail)
    EventSystem.RemoveEvent("CardDetailModel_AddExp", self, self.EventResetCardDetail)
    EventSystem.RemoveEvent("CardDetailDrag", self, self.OnDragEvent)
    EventSystem.RemoveEvent("PlayerCardModel_WearEquip", self, self.EventResetCardDetail)
    EventSystem.RemoveEvent("CardDetail_ClickDialog", self, self.EventClickDialog)
    EventSystem.RemoveEvent("CardDetail_ShowDetail", self, self.EventShowDetail)
end

function CardDetailMainView:EventShowDetail()
    self.animator:Play("EffectCardDetailRotateBackCN")
end

function CardDetailMainView:EventClickDialog(cardDialogType)
    self.cardDialogType = cardDialogType
    self.animator:Play("EffectCardDetailRotateCN")
end

function CardDetailMainView:PlayLeaveAnimation()
    self.animator:Play("EffectCardDetailLeaveCN")
end

function CardDetailMainView:OnShowDialog()
    if self.showDialog then
        self.showDialog(self.cardDialogType)
    end
end

function CardDetailMainView:OnAnimationLeave()
    if self.clickClose then
        self.clickClose()
    end
end

function CardDetailMainView:onDestroy()
    if self.onDestroy then
        self.onDestroy()
    end
end

return CardDetailMainView

