local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local PlayerMedalsMapModel = require("ui.models.medal.PlayerMedalsMapModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MedalStrengthinPageView = class(unity.base)

function MedalStrengthinPageView:ctor()
    self.btnUpgrade = self.___ex.btnUpgrade
    self.btnBenedictionUpgrade = self.___ex.btnBenedictionUpgrade
    self.btnBenedictionReplace = self.___ex.btnBenedictionReplace
    self.btnAttributeBreak = self.___ex.btnAttributeBreak
    self.upgradeIcon = self.___ex.upgradeIcon
    self.benedictionUpgradeIcon = self.___ex.benedictionUpgradeIcon
    self.benedictionReplaceIcon = self.___ex.benedictionReplaceIcon
    self.attributeBreakIcon = self.___ex.attributeBreakIcon
    self.buttonUpgrade = self.___ex.buttonUpgrade
    self.buttonBenedictionUpgrade = self.___ex.buttonBenedictionUpgrade
    self.buttonBenedictionReplace = self.___ex.buttonBenedictionReplace
    self.buttonAttributeBreak = self.___ex.buttonAttributeBreak
    self.btnClose = self.___ex.btnClose
end

function MedalStrengthinPageView:start()
    DialogAnimation.Appear(self.transform)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    self.btnUpgrade:regOnButtonClick(function()
        self:OnBtnUpgrade()
    end)
    self.btnBenedictionUpgrade:regOnButtonClick(function()
        self:OnBtnBenedictionUpgrade()
    end)
    self.btnBenedictionReplace:regOnButtonClick(function()
        self:OnBtnBenedictionReplace()
    end)
    self.btnAttributeBreak:regOnButtonClick(function()
        self:OnBtnAttributeBreak()
    end)
    EventSystem.AddEvent("ShowMedalPage", self, self.ShowPage)
end

function MedalStrengthinPageView:onDestroy()
    EventSystem.RemoveEvent("ShowMedalPage", self, self.ShowPage)
end

function MedalStrengthinPageView:InitView(medalSingleModel)
    self.medalSingleModel = medalSingleModel
    local state = medalSingleModel:GetMedalState()
    local hasUpgradeOpen = medalSingleModel:GetState(1)
    local hasBenedictionUpgradeOpen = medalSingleModel:GetState(2)
    local hasBenedictionReplaceOpen = medalSingleModel:GetState(3)
    local hasAttributeBreakOpen = medalSingleModel:GetState(4)

    local upgradeColor = hasUpgradeOpen and 1 or 0
    self.upgradeIcon.color = Color(upgradeColor, 1, 1)
    local benedictionUpgradeColor = hasBenedictionUpgradeOpen and 1 or 0
    self.benedictionUpgradeIcon.color = Color(benedictionUpgradeColor, 1, 1)
    local benedictionReplaceColor = hasBenedictionReplaceOpen and 1 or 0
    self.benedictionReplaceIcon.color = Color(benedictionReplaceColor, 1, 1)
    local attributeBreakColor = hasAttributeBreakOpen and 1 or 0
    self.attributeBreakIcon.color = Color(attributeBreakColor, 1, 1)

    self.buttonUpgrade.interactable = hasUpgradeOpen
    self.buttonBenedictionUpgrade.interactable = hasBenedictionUpgradeOpen
    self.buttonBenedictionReplace.interactable = hasBenedictionReplaceOpen
    self.buttonAttributeBreak.interactable = hasAttributeBreakOpen
end

function MedalStrengthinPageView:GetState(medalSingleModel, key)
    local isOpen = false
    local state = medalSingleModel:GetMedalState()
    for i, v in ipairs(state) do
        if(tonumber(v) == key) then 
            isOpen = true
            break
        end
    end
    return isOpen
end

function MedalStrengthinPageView:OnBtnUpgrade()
    local hasUpgradeOpen = self.medalSingleModel:GetState(1)
    if not hasUpgradeOpen then 
        return 
    end
    if self.clickUpgrade then 
        self.clickUpgrade(self.medalSingleModel)
    end
end

function MedalStrengthinPageView:OnBtnBenedictionUpgrade()
    local hasBenedictionUpgradeOpen = self.medalSingleModel:GetState(2)
    if not hasBenedictionUpgradeOpen then 
        return 
    end
    if self.clickBenedictionUpgrade then 
        self.clickBenedictionUpgrade(self.medalSingleModel)
    end
end

function MedalStrengthinPageView:OnBtnBenedictionReplace()
    local hasBenedictionReplaceOpen = self.medalSingleModel:GetState(3)
    if not hasBenedictionReplaceOpen then 
        return 
    end
    if self.clickBenedictionReplace then 
        self.clickBenedictionReplace(self.medalSingleModel)
    end
end

function MedalStrengthinPageView:OnBtnAttributeBreak()
    local hasAttributeBreakOpen = self.medalSingleModel:GetState(4)
    if not hasAttributeBreakOpen then 
        return 
    end
    if self.clickAttributeBreak then 
        self.clickAttributeBreak(self.medalSingleModel)
    end
end

function MedalStrengthinPageView:ShowPage()
    GameObjectHelper.FastSetActive(self.gameObject, true)
end

function MedalStrengthinPageView:DisablePage()
    GameObjectHelper.FastSetActive(self.gameObject, false)
end

function MedalStrengthinPageView:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function MedalStrengthinPageView:EventResetState(pmid)
    local playerMedalsMapModel = PlayerMedalsMapModel.new()
    local medalSingleModel = playerMedalsMapModel:GetSingleMedalModel(pmid)
    self:InitView(medalSingleModel)
end

function MedalStrengthinPageView:EventResetStateByCard(pcid)
    local pos = self.medalSingleModel:GetPos()
    local playerCardModel = SimpleCardModel.new(pcid)
    playerCardModel:InitMedalModel()
    local cardMedalModel = playerCardModel:GetPosMedalModel(pos)
    self:InitView(cardMedalModel)
end

function MedalStrengthinPageView:EnterScene()
    EventSystem.AddEvent("MedalsMapModel_ResetMedalModel", self, self.EventResetState)
    EventSystem.AddEvent("PlayerCardsMapModel_ResetCardModel", self, self.EventResetStateByCard)
end

function MedalStrengthinPageView:ExitScene()
    EventSystem.RemoveEvent("MedalsMapModel_ResetMedalModel", self, self.EventResetState)
    EventSystem.RemoveEvent("PlayerCardsMapModel_ResetCardModel", self, self.EventResetStateByCard)
end

return MedalStrengthinPageView
