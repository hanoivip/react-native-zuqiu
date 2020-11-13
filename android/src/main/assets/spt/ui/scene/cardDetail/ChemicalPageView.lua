local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local Vector2 = clr.UnityEngine.Vector2
local ChemicalPageView = class(unity.base)

function ChemicalPageView:ctor()
    self.scroll = self.___ex.scroll
    self.baseScrollRect = self.___ex.baseScrollRect
    self.chemicalView = self.___ex.chemicalView
    self.describe = self.___ex.describe
    self.btnQuestion = self.___ex.btnQuestion
    self.bottomChemical = self.___ex.bottomChemical
    self.chemicalTabTransf = self.___ex.chemicalTabTransf
    self.chemicalChooseButton = self.___ex.chemicalChooseButton
    self.tabObj = self.___ex.tabObj
    self.chemicalTabMap = {}
end

function ChemicalPageView:InitView(cardDetailModel)
    self:BindButtonHandler()
    self.bottomChemical.overrideSprite = cardDetailModel:GetImageRes("bottomChemical")
    GameObjectHelper.FastSetActive(self.chemicalChooseButton.gameObject, false)
end

function ChemicalPageView:BindButtonHandler()
    self.btnQuestion:regOnButtonClick(function()
        if self.onQuestion then
            self.onQuestion()
        end
    end)

    self.chemicalChooseButton:regOnButtonClick(function()
        if self.chooseChemical then 
            self.chooseChemical(self.chooseTab)
        end
    end)
end

function ChemicalPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function ChemicalPageView:IsShieldScroll(isShield)
    self.scroll.enabled = not isShield
    self.baseScrollRect.enabled = not isShield
end

function ChemicalPageView:ChangeChemical(changeButtonState)
    
    GameObjectHelper.FastSetActive(self.chemicalChooseButton.gameObject, self.isShow and changeButtonState)

    if self.chemicalTabMap and type(self.chemicalTabMap) == "table" and (not self.isShow)  then
        for k,v in pairs(self.chemicalTabMap) do
            v:OnSignSelect(false)
        end
    end
end

local ShieldMaxNum = 3
function ChemicalPageView:RefreshScrollView(cardModel)
    self.cardModel = cardModel
    local chemicalTabNum = cardModel:GetChemicalTabNum()
    self:SetScrollSize(chemicalTabNum)
    local ownershipType = self.cardModel:GetOwnershipType()
    self.isShow = (ownershipType == CardOwnershipType.SELF)
    local chooseChemicalTab = self.cardModel:GetChooseChemicalTab()
    self:RefreshChemical(cardModel, chooseChemicalTab)
    if chemicalTabNum > 1 then 
        local currentChemicalTab = cardModel:GetChemicalTab()
        for i = 1, chemicalTabNum do
            if not self.chemicalTabMap[i] then 
                local viewObj, viewSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/ChemicalTab.prefab")
                viewObj.transform:SetParent(self.chemicalTabTransf, false)
                self.chemicalTabMap[i] = viewSpt
                self.chemicalTabMap[i].clickChemicalTab = function(index) self:OnBtnChemicalTab(index) end
            end
            self.chemicalTabMap[i]:InitView(i, currentChemicalTab, chooseChemicalTab, self.isShow)
            GameObjectHelper.FastSetActive(self.chemicalTabMap[i].gameObject, true)
        end
        for i = chemicalTabNum + 1, table.nums(self.chemicalTabMap) do
            GameObjectHelper.FastSetActive(self.chemicalTabMap[chemicalTabNum].gameObject, false)
        end
    end
end

function ChemicalPageView:RefreshChemical(cardModel, chemicalIndex)
    local chemicalData = cardModel:GetChemicalData(chemicalIndex)
    self.chemicalView:refresh(chemicalData)
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        self:IsShieldScroll(#chemicalData <= ShieldMaxNum)
    end)
end

function ChemicalPageView:OnBtnChemicalTab(index)
    if self.clickChemicalTab then 
        self.clickChemicalTab(index)
    end
    local currentTab = self.cardModel:GetChemicalTab()
    local isSelectTab = tobool(tonumber(currentTab) == tonumber(index))
    self.chooseTab = index
    self.cardModel:SetChooseChemicalTab(self.chooseTab)
    self:ChangeChemical(not isSelectTab)
    for i=1,#self.chemicalTabMap do
        if index == i then
            self.chemicalTabMap[i]:OnTabSelect(true)
        else
            self.chemicalTabMap[i]:OnTabSelect(false)
        end
    end
end

function ChemicalPageView:GetChooseTab()
    return self.chooseTab
end

function ChemicalPageView:EnterScene()
    EventSystem.AddEvent("PlayerCardModel_ChangeChemical", self, self.ChangeChemical)
end

function ChemicalPageView:ExitScene()
    EventSystem.RemoveEvent("PlayerCardModel_ChangeChemical", self, self.ChangeChemical)
end

function ChemicalPageView:SetScrollSize(TabNum)
    if TabNum > 1 then
        GameObjectHelper.FastSetActive(self.tabObj, true)
        self.scroll.transform.anchoredPosition = Vector2(5, 21)
        self.scroll.transform.sizeDelta = Vector2(834, 600)
    else
        self.scroll.transform.anchoredPosition = Vector2(5, -4)
        self.scroll.transform.sizeDelta = Vector2(834, 630)
        GameObjectHelper.FastSetActive(self.tabObj, false)
    end
end

return ChemicalPageView
