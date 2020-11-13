local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color
local UISoundManager = require("ui.control.manager.UISoundManager")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require("EventSystem")
local RebornView = class(unity.base)
function RebornView:ctor()
    self.btnAddCard = self.___ex.btnAddCard
    self.btnReborn = self.___ex.btnReborn
    self.rebornButton = self.___ex.rebornButton
    self.playerName = self.___ex.playerName
    self.playerUpgrade = self.___ex.playerUpgrade
    self.playerCardParent = self.___ex.playerCardParent
    self.potentialityPlus = self.___ex.potentialityPlus    
    self.skillLevelOrigin = self.___ex.skillLevelOrigin
    self.skillLevelReborn = self.___ex.skillLevelReborn
    self.raritySign = self.___ex.raritySign -- table
    self.plusSign = self.___ex.plusSign
    self.ascendCondition = self.___ex.ascendCondition

    -- for max reborn
    self.choiceArea = self.___ex.choiceArea --gameObject
    self.rebornSign = self.___ex.rebornSign -- transform
    self.detailBoard = self.___ex.detailBoard -- transform 
    self.maxRebornText = self.___ex.maxRebornText
    self.rebornTitleText = self.___ex.rebornTitleText

    self.originRebornSignPos = self.rebornSign.anchoredPosition
    self.originDetailPos = self.detailBoard.anchoredPosition
    self.maxRebornSignPos = self.___ex.maxRebornSignPos.anchoredPosition
    self.maxDetailPos = self.___ex.maxDetailPos.anchoredPosition

    self.originRebornScale = self.rebornSign.localScale.x
    self.maxRebornScale = self.___ex.maxRebornSignPos.localScale.x
    self.rebornText = self.___ex.rebornText
end

function RebornView:start()
    self.btnAddCard:regOnButtonClick(function()
        if type(self.clickAddCard) == "function" then
            self.clickAddCard()
        end
    end)
    self.btnReborn:regOnButtonClick(function()
        UISoundManager.play('Player/encourageSound', 1)
        if type(self.clickReborn) == "function" then
            self.clickReborn()
        end
    end)
end

function RebornView:SetButtonState(isReborn)
    self.rebornButton.interactable = isReborn
    local color = isReborn and Color(0.478, 0.306, 0.118) or Color(0.196, 0.196, 0.196)
    self.rebornText.color = color
end

function RebornView:InitView(cardModel, isRebornMax)
    if isRebornMax then
        self.rebornSign.localScale = Vector3(self.maxRebornScale, self.maxRebornScale, self.maxRebornScale)
        self.rebornSign.anchoredPosition = self.maxRebornSignPos
        self.detailBoard.anchoredPosition = self.maxDetailPos
        self.choiceArea:SetActive(false)
        self.btnReborn.gameObject:SetActive(false)
        self.maxRebornText.text = clr.unwrap(lang.trans("reborn")) .. "MAX"
        self.rebornTitleText.text = lang.trans("reborn_title3")
        self.potentialityPlus.text = "+" .. tostring(cardModel:GetAscendAttribute() * cardModel:GetAscend())
        self.skillLevelReborn.text = "Lv." .. tostring(cardModel:GetMaxSkillLevel(cardModel:GetAscend()))
    else
        self.rebornSign.localScale = Vector3(self.originRebornScale, self.originRebornScale, self.originRebornScale)
        self.rebornSign.anchoredPosition = self.originRebornSignPos
        self.detailBoard.anchoredPosition = self.originDetailPos
        self.choiceArea:SetActive(true)
        self.btnReborn.gameObject:SetActive(true)
        self.maxRebornText.text = ""
        self.rebornTitleText.text = lang.trans("reborn_title2")
        self.potentialityPlus.text = "+" .. cardModel:GetAscendAttribute()
        self.skillLevelReborn.text = "Lv." .. tostring(cardModel:GetMaxSkillLevel(cardModel:GetAscend() + 1))
    end
    self.playerCardParent.gameObject:SetActive(false)
    self.playerName.text = tostring(cardModel:GetName())

    self:SetButtonState(false)
    self.skillLevelOrigin.text = "Lv." .. tostring(cardModel:GetMaxSkillLevel(cardModel:GetAscend()))

    self:SetRarityAndAscend(cardModel:GetCardQuality(), cardModel:GetAscend())
    self:SetAscendCondition(cardModel, isRebornMax)
end

function RebornView:SetAscendCondition(cardModel, isRebornMax)
    if not isRebornMax then 
        local needUpgradeLevel = cardModel:GetNeedUpgradeLevelByAscendTimes(cardModel:GetAscend() + 1)
        local canAscend = tobool(cardModel:GetUpgrade() >= needUpgradeLevel)
        if not canAscend then 
            self.ascendCondition.text = lang.trans("ascendCondition", needUpgradeLevel)
        end
        self.btnAddCard:onPointEventHandle(canAscend)
        GameObjectHelper.FastSetActive(self.btnReborn.gameObject, canAscend)
        GameObjectHelper.FastSetActive(self.plusSign.gameObject, canAscend)
        GameObjectHelper.FastSetActive(self.ascendCondition.gameObject, not canAscend)
    else
        GameObjectHelper.FastSetActive(self.ascendCondition.gameObject, false)
    end
end

-- 可转生的卡牌稀有度和转生标示
function RebornView:SetRarityAndAscend(quality, ascend)
    for k, v in pairs(self.raritySign) do
        if k == ("o" .. tostring(quality)) then
            -- v is a table
            for kk, vv in pairs(v) do
                vv:SetActive(false)
            end
            v["obj"]:SetActive(true)
            for i = 1, ascend do
                v["r" .. tostring(i)]:SetActive(true)
            end
        else
            v["obj"]:SetActive(false)
        end
    end
end

function RebornView:SetUpgradeLimit(upgradeLimit)
    if upgradeLimit > 0 then
        self.playerUpgrade.gameObject:SetActive(true)
        self.playerUpgrade.text = lang.transstr("upgrade_prefix") .. tostring(upgradeLimit)
    else
        self.playerUpgrade.gameObject:SetActive(true)
        self.playerUpgrade.text = lang.transstr("upgrade_no_limit")
    end
end

function RebornView:SetChoosePlayer(chooseCardModel)
    assert(chooseCardModel)
    self:SetButtonState(true)
    self.playerCardParent.gameObject:SetActive(true)
    if not self.playerCardView then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        obj.transform:SetParent(self.playerCardParent.transform, false)
        self.playerCardView = spt
    end
    self.playerCardView:InitView(chooseCardModel)
end

function RebornView:EventConfirmChooseCard(pcid)
    if self.confirmChooseCardCallBack then
        self.confirmChooseCardCallBack(pcid)
    end
end

function RebornView:LoadModule()
    EventSystem.AddEvent("RebornPlayerChooseModel_ConfirmChooseCard", self, self.EventConfirmChooseCard)
end

function RebornView:UnloadModule()
    EventSystem.RemoveEvent("RebornPlayerChooseModel_ConfirmChooseCard", self, self.EventConfirmChooseCard)
end

return RebornView
