local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystems = UnityEngine.EventSystems
local CoachPlayerListMainView = class(unity.base)

function CoachPlayerListMainView:ctor()
    self.btnSearch = self.___ex.btnSearch
    self.posText = self.___ex.posText
    self.sortMenuView = self.___ex.sortMenuView
    self.scrollView = self.___ex.scrollView
    self.confirmBtn = self.___ex.confirmBtn
    self.closeBtn = self.___ex.closeBtn

    self.sortMenuView.clickSort = function(index) self:OnSortClick(index) end
end

function CoachPlayerListMainView:start()
    self.btnSearch:regOnButtonClick(function()
        self:OnBtnSearch()
    end)
    self.confirmBtn:regOnButtonClick(function()
        self:OnBtnConfirm()
    end)
    self.closeBtn:regOnButtonClick(function()
        self:OnBtnClose()
    end)
end

function CoachPlayerListMainView:EnterScene()
    EventSystem.AddEvent("CoachPlayerListMainView_ToggleSelectCard", self, self.EventSelectedCard)
    EventSystem.AddEvent("CoachPlayerListMainView_ResetCardData", self, self.EventResetOneCard)
    EventSystem.AddEvent("CoachPlayerListMainView_ClearSelectedCardList", self, self.EventClearSelectCards)
    EventSystem.AddEvent("CoachPlayerListMainView_RemoveCards", self, self.EventRemoveCards)
    EventSystem.AddEvent("CoachPlayerListMainView_SortCardList", self, self.EventSortCardList)
    EventSystem.AddEvent("PlayerCapacity_Change", self, self.EventPlayerCapacity)
    EventSystem.AddEvent("PlayerCardsMapModel_AddCardData", self, self.EventAddCard)
end

function CoachPlayerListMainView:ExitScene()
    EventSystem.RemoveEvent("CoachPlayerListMainView_ToggleSelectCard", self, self.EventSelectedCard)
    EventSystem.RemoveEvent("CoachPlayerListMainView_ResetCardData", self, self.EventResetOneCard)
    EventSystem.RemoveEvent("CoachPlayerListMainView_ClearSelectedCardList", self, self.EventClearSelectCards)
    EventSystem.RemoveEvent("CoachPlayerListMainView_RemoveCards", self, self.EventRemoveCards) 
    EventSystem.RemoveEvent("CoachPlayerListMainView_SortCardList", self, self.EventSortCardList)
    EventSystem.RemoveEvent("PlayerCapacity_Change", self, self.EventPlayerCapacity)
    EventSystem.RemoveEvent("PlayerCardsMapModel_AddCardData", self, self.EventAddCard)
end

function CoachPlayerListMainView:EventPlayerCapacity(playerCapacity)
    if self.playerCapacityCallBack then
        self.playerCapacityCallBack(playerCapacity)
    end
end

function CoachPlayerListMainView:EventSortCardList()
    self:SetSelectDetail(self.playerListModel)
    if self.sortCardListCallBack then
        self.sortCardListCallBack()
    end
end

function CoachPlayerListMainView:EventRemoveCards(pcids)
    if self.soldCardsCallBack then
        self.soldCardsCallBack(pcids)
    end
end

function CoachPlayerListMainView:EventClearSelectCards()
    if self.clearSelectedCardsCallBack then
        self.clearSelectedCardsCallBack()
    end
end

function CoachPlayerListMainView:EventResetOneCard(pcid)
    if self.resetOneCardCallBack then
        self.resetOneCardCallBack(pcid)
    end
end

function CoachPlayerListMainView:EventSelectedCard(pcid, isSelected)
    if self.selectCardCallBack then
        self.selectCardCallBack(pcid, isSelected)
    end
end

function CoachPlayerListMainView:OnBtnClose()
    self.closeDialog()
end

function CoachPlayerListMainView:InitView(playerListModel)
    self.playerListModel = playerListModel
end

function CoachPlayerListMainView:SetSelectDetail(playerListModel)
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

function CoachPlayerListMainView:InitialData()
    local selectTypeIndex = self.playerListModel:GetSelectTypeIndex()
    self.sortMenuView:InitialData(selectTypeIndex)
end

function CoachPlayerListMainView:OnSelectSort(index)
    self.sortMenuView:OnSelectSortItem(index)
end

function CoachPlayerListMainView:OnSortClick(index)
    if self.clickSort then
        self.clickSort(index)
    end
end

function CoachPlayerListMainView:OnClickPieceCompose(cardPieceModel)
    if self.clickPieceCompose then
        self.clickPieceCompose(cardPieceModel)
    end
end

function CoachPlayerListMainView:OnBtnBack()
    if self.clickBack then
        self.clickBack()
    end
end

function CoachPlayerListMainView:OnBtnCancel()
    if self.clickCancel then
        self.clickCancel()
    end
end

function CoachPlayerListMainView:OnBtnSearch()
    if self.clickSearch then
        self.clickSearch()
    end
end

function CoachPlayerListMainView:OnBtnConfirm()
    if self.clickConfirm then
        self.clickConfirm()
    end
end

function CoachPlayerListMainView:OnBtnPlayerLimit()
    if self.clickPlayerLimit then
        self.clickPlayerLimit()
    end
end

function CoachPlayerListMainView:onDestroy()
    self:OnBtnBack()
end

function CoachPlayerListMainView:EventAddCard(pcid)
    if self.addCardCallBack then
        self.addCardCallBack(pcid)
    end
end

function CoachPlayerListMainView:Close()
    self.closeDialog()
end

return CoachPlayerListMainView
