local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardQuality = require("data.CardQuality")
local UISoundManager = require("ui.control.manager.UISoundManager")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local AscendPageView = class(unity.base)

function AscendPageView:ctor()
    self.ascendSignMap = self.___ex.ascendSignMap
    self.price = self.___ex.price
    self.pricePlus = self.___ex.pricePlus
    self.power = self.___ex.power
    self.powerPlus = self.___ex.powerPlus
    self.skillLimit = self.___ex.skillLimit
    self.skillLimitPlus = self.___ex.skillLimitPlus
    self.pentagonText = self.___ex.pentagonText     -- table
    self.pentagonValue = self.___ex.pentagonValue   -- table
    self.pentagonPlus = self.___ex.pentagonPlus -- table
    self.cardName = self.___ex.cardName
    self.ascendNeedCondition = self.___ex.ascendNeedCondition
    self.btnAscend = self.___ex.btnAscend
    self.btnPlus = self.___ex.btnPlus
    self.plusObj = self.___ex.plusObj
    self.ploygonCustom = self.___ex.ploygonCustom
    self.ascendButton = self.___ex.ascendButton
    self.ascendGradient = self.___ex.ascendGradient
    self.playerCardParent = self.___ex.playerCardParent
    self.ascendPloygonCustom = self.___ex.ascendPloygonCustom
    self.ascendCardQuality = self.___ex.ascendCardQuality
    self.ascendEffectAnimator = self.___ex.ascendEffectAnimator
    self.bottomAscend1 = self.___ex.bottomAscend1
    self.bottomAscend2 = self.___ex.bottomAscend2
    self.bottomAscend3 = self.___ex.bottomAscend3
    self.bottomAscendTitle = self.___ex.bottomAscendTitle
    self.bottomAscendTitle2 = self.___ex.bottomAscendTitle2
    self.bottomAscendTitleBar1 = self.___ex.bottomAscendTitleBar1
    self.bottomAscendTitleBar2 = self.___ex.bottomAscendTitleBar2
    self.bottomAscendTitleBar3 = self.___ex.bottomAscendTitleBar3
    self.bottomAscendTitleBar4 = self.___ex.bottomAscendTitleBar4
    self.ascendTitle = self.___ex.ascendTitle
    -- 未满转时右下角面板
    self.objNormal = self.___ex.objNormal
    -- 满转时右下角面板
    self.objFullAscend = self.___ex.objFullAscend
    -- 传奇之路
    self.btnLegendRoad = self.___ex.btnLegendRoad
end

function AscendPageView:start()
    self.btnPlus:regOnButtonClick(function()
        if type(self.clickAddCard) == "function" then
            self.clickAddCard()
        end
    end)
    self.btnAscend:regOnButtonClick(function()
        UISoundManager.play('Player/encourageSound', 1)
        if type(self.clickAscend) == "function" then
            self.clickAscend()
        end
    end)
    -- 传奇之路
    self.btnLegendRoad:regOnButtonClick(function()
        if type(self.onBtnLegendRoadClick) == "function" then
            self.onBtnLegendRoadClick()
        end
    end)
end

local LegendRoadQualityCondition = 6 -- 传奇之路要求ss以上才开启
function AscendPageView:InitView(cardDetailModel)
    local cardModel = cardDetailModel:GetCardModel()
    for k, v in pairs(self.ascendSignMap) do
        local index = tonumber(string.sub(k, 2))
        v:InitView(index, cardModel)
    end

    local medalCombine = cardModel:GetMedalCombine()
    local value = cardModel:GetValue()
    self.price.text = string.formatNumWithUnit(tostring(value)) 
    self.pricePlus.text = '+?'
    self.power.text = tostring(cardModel:GetPower(medalCombine))
    local skillLimit = cardModel:GetMaxSkillLevel(cardModel:GetAscend())
    local cardQualityTable = CardQuality[tostring(cardModel:GetCardQuality())]
    local addSkillLevel = cardQualityTable.ascendSkillLvl
    self.skillLimit.text = tostring(skillLimit)
    
    local isRebornMax = tobool(cardModel:GetAscend() >= cardModel:GetMaxAscendNum())
    local addAscendAttribute = 0
    if isRebornMax then
        self.pricePlus.text = ''
        self.powerPlus.text = ''
        self.skillLimit.text = ''
        self.ascendNeedCondition.text = ''
        self.cardName.text = ''
        self.skillLimitPlus.text = ''
    else
        local needUpgradeLevel = cardModel:GetNeedUpgradeLevelByAscendTimes(cardModel:GetAscend() + 1)
        self.ascendNeedCondition.text = lang.trans("ascendCondition", needUpgradeLevel)
        self.cardName.text = tostring(cardModel:GetName())
        addAscendAttribute = cardModel:GetAscendAttribute()
        local ascendAddAttribute = addAscendAttribute * 5
        local addPower = cardModel:GetPowerByAttribute(ascendAddAttribute, medalCombine)
        self.powerPlus.text = '+' .. tostring(addPower)
        self.skillLimitPlus.text = '+' .. tostring(addSkillLevel)
    end
    GameObjectHelper.FastSetActive(self.ascendNeedCondition.gameObject, not isRebornMax)
    GameObjectHelper.FastSetActive(self.plusObj.gameObject, cardModel:IsOperable() and not isRebornMax)
    -- 有配置且满转出现传奇之路
    local hasLegendRoad = cardModel:HasLegendRoad()
    local isShowLegendRoad = false
    local ascendTitle = lang.trans("ascend_need_material")
    local quality = cardModel:GetCardQuality()
    if hasLegendRoad and isRebornMax and tonumber(quality) >= LegendRoadQualityCondition then
        isShowLegendRoad = true
        ascendTitle = lang.trans("legend_road")
    end
    self.ascendTitle.text = ascendTitle
    GameObjectHelper.FastSetActive(self.objNormal.gameObject, not isShowLegendRoad)
    GameObjectHelper.FastSetActive(self.objFullAscend.gameObject, isShowLegendRoad)

    local pentagonOrder
    if cardModel:IsGKPlayer() then
        pentagonOrder = CardHelper.GoalKeeperOrder
    else
        pentagonOrder = CardHelper.NormalPlayerOrder
    end

    local fiveAbilityValueList = {}
    local maxAbilityValue = -1
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus, train, total = cardModel:GetAbility(abilityIndex)
        if total > maxAbilityValue then
            maxAbilityValue = total
        end
        table.insert(fiveAbilityValueList, base + plus + train)
        self.pentagonText["p" .. tostring(i)].text = lang.trans(abilityIndex)
        self.pentagonValue["p" .. tostring(i)].text = tostring(base + plus + train)
        local plusText = ''
        if not isRebornMax then 
            plusText = '+' .. tostring(addAscendAttribute)
        end
        self.pentagonPlus["p" .. tostring(i)].text = plusText
    end

    local color, maxValue = CardHelper.GetPolygonColorAndMaxValue(maxAbilityValue + addAscendAttribute)
    local abilityValues = {}
    local ascendValues = {}
    for i, v in ipairs(fiveAbilityValueList) do
        local abilitySigleValue = math.sqrt(v / maxValue)
        table.insert(abilityValues, abilitySigleValue)
        local ascendSigleValue = math.sqrt((v + addAscendAttribute) / maxValue)
        table.insert(ascendValues, ascendSigleValue)
    end

    self.ploygonCustom.maxValue = 1
    self.ploygonCustom.abilityValues = clr.array(abilityValues, clr.System.Single)
    self.ploygonCustom:SetAllDirty()

    self.ascendPloygonCustom.maxValue = 1
    self.ascendPloygonCustom.abilityValues = clr.array(ascendValues, clr.System.Single)
    self.ascendPloygonCustom:SetAllDirty()

    self:SetButtonState(false)
    GameObjectHelper.FastSetActive(self.playerCardParent.gameObject, false)

    local path = "Assets/CapstonesRes/Game/UI/Common/Card/Images/Ascend_Card" .. cardModel:GetRarity() .. ".png"
    self.ascendCardQuality.overrideSprite = res.LoadRes(path)

    GameObjectHelper.FastSetActive(self.ascendEffectAnimator.gameObject, false)

    self.bottomAscend1.overrideSprite = cardDetailModel:GetImageRes("bottomAscend1")
    self.bottomAscend2.overrideSprite = cardDetailModel:GetImageRes("bottomAscend2")
    self.bottomAscend3.overrideSprite = cardDetailModel:GetImageRes("bottomAscend3")
    self.bottomAscendTitle.overrideSprite = cardDetailModel:GetImageRes("bottomAscendTitle")
    self.bottomAscendTitle2.overrideSprite = cardDetailModel:GetImageRes("bottomAscendTitle2")
    self.bottomAscendTitleBar1.overrideSprite = cardDetailModel:GetImageRes("bottomAscendTitleBar1")
    self.bottomAscendTitleBar2.overrideSprite = cardDetailModel:GetImageRes("bottomAscendTitleBar2")
    self.bottomAscendTitleBar3.overrideSprite = cardDetailModel:GetImageRes("bottomAscendTitleBar3")
    self.bottomAscendTitleBar4.overrideSprite = cardDetailModel:GetImageRes("bottomAscendTitleBar4")
end

function AscendPageView:SetUpgradeLimit(upgradeLimit)
    if upgradeLimit > 0 then
        self.ascendNeedCondition.text = lang.transstr("ascend_need_upgrade_desc", upgradeLimit)
    elseif upgradeLimit == 0 then
        self.ascendNeedCondition.text = lang.transstr("upgrade_no_limit")
    else
        self.ascendNeedCondition.text = lang.transstr("ascend_be_max")
    end
end

function AscendPageView:SetChoosePlayer(chooseCardModel)
    assert(chooseCardModel)
    self:SetButtonState(true)
    GameObjectHelper.FastSetActive(self.playerCardParent.gameObject, true)
    if not self.playerCardView then
        local obj, spt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
        spt:IsShowName(false)
        obj.transform:SetParent(self.playerCardParent.transform, false)
        self.playerCardView = spt
    end
    self.playerCardView:InitView(chooseCardModel)

    local value = chooseCardModel:GetValue() 
    self.pricePlus.text = '+' .. string.formatNumWithUnit(tostring(value)) 
end

function AscendPageView:SetButtonState(isAscend)
    self.ascendButton.interactable = isAscend
    if isAscend then 
        ButtonColorConfig.SetNormalGradientColor(self.ascendGradient)
    else
        ButtonColorConfig.SetDisableGradientColor(self.ascendGradient)
    end
end

function AscendPageView:EventConfirmChooseCard(pcid)
    if self.confirmChooseCardCallBack then
        self.confirmChooseCardCallBack(pcid)
    end
end

function AscendPageView:EnterScene()
    EventSystem.AddEvent("RebornPlayerChooseModel_ConfirmChooseCard", self, self.EventConfirmChooseCard)
end

function AscendPageView:ExitScene()
    EventSystem.RemoveEvent("RebornPlayerChooseModel_ConfirmChooseCard", self, self.EventConfirmChooseCard)
end

function AscendPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

function AscendPageView:ShowAscendEffect(newCardModel)
    GameObjectHelper.FastSetActive(self.ascendEffectAnimator.gameObject, true)
    self.ascendEffectAnimator:Play("AscendLevelUpAnimation", 0, 0)
    local ascend = newCardModel:GetAscend()
    local key = "s" .. ascend
    if self.ascendSignMap[key] then 
        self.ascendSignMap[key]:ShowAscendEffect()
    end
end

return AscendPageView
