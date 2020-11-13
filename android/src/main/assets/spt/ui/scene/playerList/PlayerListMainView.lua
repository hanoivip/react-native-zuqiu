local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MenuType = require("ui.controllers.playerList.MenuType")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
local EventSystems = UnityEngine.EventSystems
local PlayerListMainView = class(unity.base)

local MENU_MAP = {
    [MenuType.LIST] = "list",
    [MenuType.LOCK] = "lock",
    [MenuType.SELL] = "sell",
    [MenuType.PIECE] = "piece",
}

function PlayerListMainView:ctor()
    self.menuButtonGroup = self.___ex.menuButtonGroup
    self.sortMenuView = self.___ex.sortMenuView
    self.sellConfirm = self.___ex.sellConfirm -- GameObject
    self.selectCount = self.___ex.selectCount
    self.totalValue = self.___ex.totalValue
    self.btnSell = self.___ex.btnSell
    self.btnCancel = self.___ex.btnCancel
    self.scrollBar = self.___ex.scrollBar
    self.playerNumber = self.___ex.playerNumber
    self.viewBg = self.___ex.viewBg

    self.scrollView = self.___ex.scrollView
    self.scrollRect = self.___ex.scrollRect
    self.btnSearch = self.___ex.btnSearch 
    self.searchText = self.___ex.searchText
    self.btnPlayerLimit = self.___ex.btnPlayerLimit
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.cancelButton = self.___ex.cancelButton
    self.cancelGradient = self.___ex.cancelGradient
    self.posText = self.___ex.posText
    self.animator = self.___ex.animator

    self.boardArea = self.___ex.boardArea
    self.pieceBoardArea = self.___ex.pieceBoardArea
    self.pieceView = self.___ex.pieceView

    self.animatorStateIsLeave = false
    self.sortMenuView.clickSort = function(index) self:OnSortClick(index) end
    self.pieceView.clickUse = function(cardPieceModel) self:OnClickPieceCompose(cardPieceModel) end
end

function PlayerListMainView:start()
    local menuTransform = self.menuButtonGroup.transform
    for i = 1, menuTransform.childCount do
        local btnObject = menuTransform:GetChild(i - 1).gameObject
        btnObject:GetComponent(clr.CapsUnityLuaBehav):regOnButtonClick(function()
            self:OnMenuClick(i)
        end)
    end

    self.btnSell:regOnButtonClick(function()
        self:OnBtnSell()
    end)
    self.btnCancel:regOnButtonClick(function()
        self:OnBtnCancel()
    end)
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
    self.btnPlayerLimit:regOnButtonClick(function()
        self:OnBtnPlayerLimit()
    end)
end

function PlayerListMainView:EnterScene()
    EventSystem.AddEvent("PlayerListModel_ToggleSelectCard", self, self.EventSelectedCard)
    EventSystem.AddEvent("PlayerListModel_ResetCardData", self, self.EventResetOneCard)
    EventSystem.AddEvent("PlayerListModel_ClearSelectedCardList", self, self.EventClearSelectCards)
    EventSystem.AddEvent("PlayerListModel_RemoveCards", self, self.EventRemoveCards)
    EventSystem.AddEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
    EventSystem.AddEvent("PlayerCapacity_Change", self, self.EventPlayerCapacity)
    EventSystem.AddEvent("PlayerCardsMapModel_AddCardData", self, self.EventAddCard)
    self.pieceView:EnterScene()
end

function PlayerListMainView:ExitScene()
    EventSystem.RemoveEvent("PlayerListModel_ToggleSelectCard", self, self.EventSelectedCard)
    EventSystem.RemoveEvent("PlayerListModel_ResetCardData", self, self.EventResetOneCard)
    EventSystem.RemoveEvent("PlayerListModel_ClearSelectedCardList", self, self.EventClearSelectCards)
    EventSystem.RemoveEvent("PlayerListModel_RemoveCards", self, self.EventRemoveCards) 
    EventSystem.RemoveEvent("PlayerListModel_SortCardList", self, self.EventSortCardList)
    EventSystem.RemoveEvent("PlayerCapacity_Change", self, self.EventPlayerCapacity)
    EventSystem.RemoveEvent("PlayerCardsMapModel_AddCardData", self, self.EventAddCard)
    self.pieceView:ExitScene()
end

function PlayerListMainView:EventPlayerCapacity(playerCapacity)
    if self.playerCapacityCallBack then
        self.playerCapacityCallBack(playerCapacity)
    end
end

function PlayerListMainView:EventSortCardList()
    self:SetSelectDetail(self.playerListModel)
    if self.sortCardListCallBack then
        self.sortCardListCallBack()
    end
end

function PlayerListMainView:EventRemoveCards(pcids)
    if self.soldCardsCallBack then
        self.soldCardsCallBack(pcids)
    end
end

function PlayerListMainView:EventClearSelectCards()
    if self.clearSelectedCardsCallBack then
        self.clearSelectedCardsCallBack()
    end
end

function PlayerListMainView:EventResetOneCard(pcid)
    if self.resetOneCardCallBack then
        self.resetOneCardCallBack(pcid)
    end
end

function PlayerListMainView:EventSelectedCard(pcid, isSelected)
    if self.selectCardCallBack then
        self.selectCardCallBack(pcid, isSelected)
    end
end

function PlayerListMainView:InitView(playerListModel, menuType)
    self.playerListModel = playerListModel
    self:SetCurrentCardsCount(table.nums(playerListModel:GetCardList()), playerListModel:GetCardNumberLimit())
    self.menuButtonGroup:selectMenuItem(MENU_MAP[menuType])
    self:OnMenuClick(menuType)
end

function PlayerListMainView:SetSelectDetail(playerListModel)
    local isSelected = false
    if playerListModel then
        local selectPos = playerListModel:GetSelectPos()
        local selectQuality = playerListModel:GetSelectQuality()
        local selectName = playerListModel:GetSeletName()
        local selectNationality = playerListModel:GetSeletNationality()
        local selectSkill = playerListModel:GetSeletSkill()

        if selectPos and next(selectPos) then
            isSelected = true
        end
        if selectQuality and next(selectQuality) then
            isSelected = true
        end
        if selectSkill and next(selectSkill) then
            isSelected = true
        end
        if selectName ~= "" or selectNationality ~= "" then
            isSelected = true
        end
        self.posText.text = isSelected and lang.trans("pos_be_selected_title") or lang.trans("cardIndex_select")
    end
end

function PlayerListMainView:SetCurrentCardsCount(count, countLimit)
    assert(type(count) == "number")
    local desc = tostring(count) .. "/" .. tostring(countLimit)
    self.playerNumber.text = desc
end    

function PlayerListMainView:SetSellInfo(playerListModel)
    local selectedCardList = playerListModel:GetSelectedCardList()
    local selectPlayers = table.nums(selectedCardList)
    self.selectCount.text = lang.trans("select_player_num", selectPlayers)

    local selectCardsValue = playerListModel:GetSelectedCardValue()
    local value = string.formatNumWithUnit(selectCardsValue)
    self.totalValue.text = "€" .. tostring(value)
    local isSelect = tobool(selectPlayers > 0)
    self.cancelButton.interactable = isSelect
    self.cancelGradient.enabled = isSelect
end

function PlayerListMainView:OnMenuClick(index)
    if index == MenuType.SELL then
        self.sellConfirm:SetActive(true)
        self.scrollView:ResetWithCellSpace(15, 25)
        self.scrollView:ResetWithViewSize(820, 420)
        self.scrollBar.anchoredPosition = Vector2(-240, 1)
        self.viewBg.sizeDelta = Vector2(860, 445)
    elseif index == MenuType.LIST or index == MenuType.LOCK then
        self.sellConfirm:SetActive(false)
        self.scrollView:ResetWithCellSpace(22, 25)
        self.scrollView:ResetWithViewSize(1018, 420)
        self.scrollBar.anchoredPosition = Vector2(-32, 1)
        self.viewBg.sizeDelta = Vector2(1080, 445)
    end
    GameObjectHelper.FastSetActive(self.boardArea, index ~= MenuType.PIECE)
    GameObjectHelper.FastSetActive(self.pieceBoardArea, index == MenuType.PIECE)

    if self.clickMenu then
        self.clickMenu(index)
    end
end

function PlayerListMainView:InitialData()
    local selectTypeIndex = self.playerListModel:GetSelectTypeIndex()
    self.sortMenuView:InitialData(selectTypeIndex)
    self.animator:Play("EffectPlayerList")
    self.animatorStateIsLeave = false
end

-- 在从大卡回来时去掉界面动画，而从其它界面回来则重新播放动画
function PlayerListMainView:AdjustAnimation()
    if self.animatorStateIsLeave then
        self.animator:Play("EffectPlayerList")
        self.animatorStateIsLeave = false
    end
end

function PlayerListMainView:OnSelectSort(index)
    self.sortMenuView:OnSelectSortItem(index)
end

function PlayerListMainView:OnSortClick(index)
    if self.clickSort then
        self.clickSort(index)
    end
end

function PlayerListMainView:OnClickPieceCompose(cardPieceModel)
    if self.clickPieceCompose then
        self.clickPieceCompose(cardPieceModel)
    end
end

function PlayerListMainView:OnBtnBack()
    if self.clickBack then
        self.clickBack()
    end
end

function PlayerListMainView:OnBtnSell()
    if self.clickSell then
        self.clickSell()
    end
end

function PlayerListMainView:OnBtnCancel()
    if self.clickCancel then
        self.clickCancel()
    end
end

function PlayerListMainView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function PlayerListMainView:OnBtnPlayerLimit()
    if self.clickPlayerLimit then
        self.clickPlayerLimit()
    end
end

function PlayerListMainView:onDestroy()
end

function PlayerListMainView:RegOnInfoBarDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function PlayerListMainView:OnLeave()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem.enabled = true
    end
    if self.onAnimationLevelComplete then
        self.onAnimationLevelComplete()
    end
end

function PlayerListMainView:PlayLeaveAnimation()
    if GuideManager.GuideIsOnGoing("main") then
        self.currentEventSystem = EventSystems.EventSystem.current
        self.currentEventSystem.enabled = false
    end
    self.animator:Play("EffectPlayerListLeave")
    self.animatorStateIsLeave = true
end

function PlayerListMainView:ControlScrollRect()
    if GuideManager.GuideIsOnGoing("main") then
        self.scrollRect.enabled = false
    else
        self.scrollRect.enabled = true
    end
end

function PlayerListMainView:EventAddCard(pcid)
    if self.addCardCallBack then
        self.addCardCallBack(pcid)
    end
end

return PlayerListMainView
