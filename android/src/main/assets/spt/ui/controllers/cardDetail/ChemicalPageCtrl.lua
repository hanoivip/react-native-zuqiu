local DialogManager = require("ui.control.manager.DialogManager")
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local CardOwnershipType = require("ui.controllers.cardDetail.CardOwnershipType")
local CardBuilder = require("ui.common.card.CardBuilder")
local ChemicalPageCtrl = class(nil, "ChemicalPageCtrl")

function ChemicalPageCtrl:ctor(view, content)
    self:Init(content)
    self.pageView.chooseChemical = function(chooseTab) self:OnChooseChemical(chooseTab) end
    self.pageView.clickChemicalTab = function(index) self:OnClickChemicalTab(index) end
end

function ChemicalPageCtrl:Init(content)
    local pageObject, pageSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChemicalPage.prefab")
    pageObject.transform:SetParent(content, false)
    self.pageView = pageSpt

    self:RegScrollComp()
end

function ChemicalPageCtrl:OnChooseChemical(chooseTab)
    clr.coroutine(function()
        local respone = req.cardChemicalTabChange(self.cardModel:GetPcid(), chooseTab)
        if api.success(respone) then
            local data = respone.val
            self.cardModel:SetChemicalTab(data.chemicalTab)
            self.cardDetailModel:ResetCardData(self.cardModel.cacheData)
        end
    end)
end

function ChemicalPageCtrl:OnClickChemicalTab(index)
    self.pageView:RefreshChemical(self.cardModel, index)
end

function ChemicalPageCtrl:EnterScene()
    self.pageView:EnterScene()
end

function ChemicalPageCtrl:ExitScene()
    self.pageView:ExitScene()
end

function ChemicalPageCtrl:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    self.cardModel = cardDetailModel:GetCardModel()
    self.pageView.onQuestion = function() self:OnQuestion() end
    self.pageView:InitView(cardDetailModel)
    self:RefreshScrollView(self.cardModel)
end

function ChemicalPageCtrl:GetCardRes()
    if not self.cardRes then 
        self.cardRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChimicalCard.prefab")
    end
    return self.cardRes
end

function ChemicalPageCtrl:RegScrollComp()
    self.pageView.chemicalView.onScrollCreateItem = function(index)
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChemicalBar.prefab")
        spt.cardClick = function(cardId, isActive, index) self:OnCardClick(cardId, isActive, index) end
        return obj, spt
    end
    self.pageView.chemicalView.onScrollResetItem = function(spt, index)
        local itemData = self.pageView.chemicalView.itemDatas[index] 
        local cardRes = self:GetCardRes()
        spt:InitView(index, itemData, self.cardModel, cardRes)
    end
end

function ChemicalPageCtrl:OnCardClick(cardId, isActive, index)
    local ownershipType = self.cardModel:GetOwnershipType()
    if ownershipType ~= CardOwnershipType.SELF then 
        DialogManager.ShowToast(lang.trans("card_swap_content4"))
        return 
    end
    local cardModel = StaticCardModel.new(cardId)
    local swapCardname = cardModel:GetName()
    local maxPlus, maxPcid  = self.cardModel:GetChemicalPlayersAddValue(cardId) 
    local selectCardname = self.cardModel:GetName()
    local callback = function()
        local currentModel = CardBuilder.GetOwnCardModel(maxPcid)
        local CardDetailMainCtrl = res.PushScene("ui.controllers.cardDetail.CardDetailMainCtrl", { maxPcid }, 1, currentModel)
    end
    local titleText = lang.trans("card_swap_title1")
    if isActive then
        local contentText = lang.trans("card_swap_content1", selectCardname, swapCardname)
        DialogManager.ShowMessageBox(titleText, contentText, callback) 
    else
        if maxPcid then 
            local contentText = lang.trans("card_swap_content3", selectCardname, selectCardname, swapCardname)
            DialogManager.ShowMessageBox(titleText, contentText, callback) 
        else
            local chooseTab = self.cardModel:GetChooseChemicalTab()
            local chemicalData = self.cardModel:GetChemicalData(chooseTab)
            local chemicalBonus = chemicalData[index].chemicalBonus
            local contentText = lang.trans("card_swap_content2", selectCardname, chemicalBonus, selectCardname, swapCardname)
            DialogManager.ShowAlertPop(titleText, contentText, nil)
        end
    end
end

function ChemicalPageCtrl:RefreshScrollView(cardModel)
    self.pageView:RefreshScrollView(cardModel)
end

function ChemicalPageCtrl:ShowPageVisible(isVisible)
    self.pageView:ShowPageVisible(isVisible)
end

function ChemicalPageCtrl:OnQuestion()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/CardDetail/ChemicalQuestionBoard.prefab", "camera", true, true)
end

return ChemicalPageCtrl
