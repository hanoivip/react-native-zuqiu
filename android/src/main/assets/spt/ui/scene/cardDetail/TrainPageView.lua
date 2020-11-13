local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ButtonColorConfig = require("ui.common.ButtonColorConfig")
local CardHelper = require("ui.scene.cardDetail.CardHelper")
local TrainPageView = class(unity.base)

function TrainPageView:ctor()
    self.powerParent = self.___ex.powerParent
    self.potentPloygonCustom = self.___ex.potentPloygonCustom
    self.basePloygonCustom = self.___ex.basePloygonCustom 
    self.attributeMap = self.___ex.attributeMap
    self.attributeBarMap = self.___ex.attributeBarMap
    self.trainItemCount = self.___ex.trainItemCount
    self.btnTrain = self.___ex.btnTrain
    self.btnTrainArea = self.___ex.btnTrainArea
    self.btnConfirmArea = self.___ex.btnConfirmArea
    self.btnSave = self.___ex.btnSave
    self.btnCancel = self.___ex.btnCancel
    self.potent = self.___ex.potent
    self.potentChangeValue = self.___ex.potentChangeValue
    self.trainButton = self.___ex.trainButton
    self.trainGradient = self.___ex.trainGradient
    self.bottomTrain = self.___ex.bottomTrain
    self.curveArea = self.___ex.curveArea
    self.tagBar = self.___ex.tagBar
    self.tagBorder = self.___ex.tagBorder
    self.trainInstruction = self.___ex.trainInstruction
    self.trainIntellect = self.___ex.trainIntellect
end

function TrainPageView:start()
    self.btnTrain:regOnButtonClick(function()
        if type(self.clickBreak) == "function" then
            self.clickBreak()
        end
    end)
    self.btnSave:regOnButtonClick(function()
        if type(self.clickSave) == "function" then
            self.clickSave()
        end
    end)
    self.btnCancel:regOnButtonClick(function()
        if type(self.clickCancel) == "function" then
            self.clickCancel()
        end
    end)
    self.trainIntellect:regOnButtonClick(function()
        if type(self.clickIntellect) == "function" then
            self.clickIntellect()
        end
    end)
end

function TrainPageView:InitView(cardDetailModel, itemsMapModel)
    local cardModel = cardDetailModel:GetCardModel()
    GameObjectHelper.FastSetActive(self.btnConfirmArea, false)
    GameObjectHelper.FastSetActive(self.btnTrainArea, true)
    self.trainItemCount.text = "x" .. itemsMapModel:GetItemNum(1)
    local potent = cardModel:GetStaticPotential() - cardModel:GetConsumePotent() + cardModel:GetLegendPotentImprove()
    if potent < 0 then potent = 0 end
    self.potent.text = lang.trans("player_potent", potent)
    self.potentChangeValue.text = ""
    self:UpdateAttribute(cardModel, nil)
    local isOperable = cardModel:IsOperable()
    self.trainButton.interactable = isOperable
    if isOperable then 
        ButtonColorConfig.SetNormalGradientColor(self.trainGradient)
    else
        ButtonColorConfig.SetDisableGradientColor(self.trainGradient)
    end
    self.bottomTrain.overrideSprite = cardDetailModel:GetImageRes("bottomTrain")
    self.curveArea.overrideSprite = cardDetailModel:GetImageRes("curveArea")
    self.tagBar.overrideSprite = cardDetailModel:GetImageRes("tagBar")
    self.tagBorder.overrideSprite = cardDetailModel:GetImageRes("tagBorder")
    self.trainInstruction.overrideSprite = cardDetailModel:GetImageRes("trainInstruction")
end

-- 更新多边形及属性
function TrainPageView:UpdateAttribute(cardModel, unsavedCardModel)
    local pentagonOrder, pentagonShort
    if cardModel:IsGKPlayer() then
        pentagonOrder = CardHelper.GoalKeeperOrder
        pentagonShort = CardHelper.GoalKeeperOrderShort
    else
        pentagonOrder = CardHelper.NormalPlayerOrder
        pentagonShort = CardHelper.NormalPlayerOrderShort
    end

    local baseFiveAbilityValueList = { }
    local potentFiveAbilityValueList = { }
    local baseMaxAbilityValue = -1
    local potentMaxAbilityValue = -1
    local baseValue, potentValue
    local medalCombine = cardModel:GetMedalCombine()
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus, train, total = cardModel:GetAbility(abilityIndex, medalCombine)
        if unsavedCardModel then 
            local tmpChangeValue = unsavedCardModel:GetAbilityChange(abilityIndex)
            train = train + tmpChangeValue
        end
        local baseValue = base + plus
        local potentValue = total
        if baseValue > baseMaxAbilityValue then
            baseMaxAbilityValue = baseValue
        end
        if potentValue > potentMaxAbilityValue then
            potentMaxAbilityValue = potentValue
        end
        table.insert(baseFiveAbilityValueList, baseValue)
        table.insert(potentFiveAbilityValueList, potentValue)
        self:SetAttribute(i, abilityIndex, potentValue)
    end

    local color, maxValue = CardHelper.GetPolygonColorAndMaxValue(potentMaxAbilityValue)
    self:PloygonRender(self.basePloygonCustom, baseFiveAbilityValueList, maxValue)
    self:PloygonRender(self.potentPloygonCustom, potentFiveAbilityValueList, maxValue)
    
    self:SetProgress(potentMaxAbilityValue, pentagonOrder, maxValue, cardModel, unsavedCardModel)
end

function TrainPageView:SetAttribute(index, abilityIndex, value)
    self.attributeMap[tostring("p" .. index)]:InitView(abilityIndex, value)
end

-- 进度条
function TrainPageView:SetProgress(potentMaxAbilityValue, pentagonOrder, maxValue, cardModel, unsavedCardModel)
    local medalCombine = cardModel:GetMedalCombine()
    for k, v in pairs(self.attributeBarMap) do
        local index = string.sub(k, 2)
        local abilityIndex = pentagonOrder[tonumber(index)]
        local base, plus, train = cardModel:GetAbility(abilityIndex, medalCombine)
        local tmpChangeValue, symbol
        if unsavedCardModel then 
            tmpChangeValue, symbol = unsavedCardModel:GetAbilityChange(abilityIndex)
        end
        local baseValue = base + plus
        v:InitView(baseValue, train, abilityIndex, tmpChangeValue, symbol)
    end
end

-- 多边形
function TrainPageView:PloygonRender(ploygonCustom, fiveAbilityValueList, maxValue)
    local abilityValues = {
        math.sqrt(fiveAbilityValueList[1] / maxValue),
        math.sqrt(fiveAbilityValueList[2] / maxValue),
        math.sqrt(fiveAbilityValueList[3] / maxValue),
        math.sqrt(fiveAbilityValueList[4] / maxValue),
        math.sqrt(fiveAbilityValueList[5] / maxValue),
    }

    ploygonCustom.maxValue = 1
    ploygonCustom.abilityValues = clr.array(abilityValues, clr.System.Single)
    ploygonCustom:SetAllDirty()
end

-- 培养属性变化
function TrainPageView:UpdateUnsavedAdvanceResult(unsavedCardModel, itemsMapModel, cardModel)
    GameObjectHelper.FastSetActive(self.btnConfirmArea, true)
    GameObjectHelper.FastSetActive(self.btnTrainArea, false)
    self.trainItemCount.text = "x" .. tostring(itemsMapModel:GetItemNum(1))

    local consumePotentTmp = unsavedCardModel:GetTmpConsumePotent()
    self.potentChangeValue.text = tostring(-consumePotentTmp)
    self:UpdateAttribute(cardModel, unsavedCardModel)
end

function TrainPageView:ShowPageVisible(isVisible)
    GameObjectHelper.FastSetActive(self.gameObject, isVisible)
end

return TrainPageView
