local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local RectTransformUtility = UnityEngine.RectTransformUtility
local Color = UnityEngine.Color
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CardConfig = require("ui.common.card.CardConfig")
local CardDetailBaseInfoView = class(unity.base)
local tostring = tostring
local tonumber = tonumber

-- 以中上第一个顺时针表示顺序
local normalPlayerOrder = {
    "shoot",
    "intercept",
    "steal",
    "dribble",
    "pass"
}
local goalKeeperOrder = {
    "goalkeeping",  -- 门线技术
    "anticipation", -- 球路判断
    "commanding",   -- 防线指挥
    "composure",    -- 心理素质
    "launching"     -- 发起进攻
}

local function GetPolygonColorAndMaxValue(value)
    local color
    local maxValue
    local function getColor(r, g, b)
        return Color(r / 255, g / 255, b / 255, 120 / 255)
    end
    if value <= 100 then
        maxValue = 100
        color = getColor(148, 219, 64)
        --color = Color(0, 1, 0, 0.8)
    elseif value <= 300 then
        maxValue = 300
        color = getColor(100, 220, 245)
        --color = Color(0, 0, 1, 0.8)
    elseif value <= 900 then
        maxValue = 900
        color = getColor(205, 130, 250)
        --color = Color(1, 0, 1, 0.8)
    elseif value <= 2700 then
        maxValue = 2700
        color = getColor(245, 170, 35)
        --color = Color(1, 0.5, 0, 0.8)
    elseif value <= 8100 then
        maxValue = 8100
        color = getColor(250, 50, 30)
        --color = Color(1, 0, 0, 0.8)
    elseif value <= 24300 then
        maxValue = 24300
        color = getColor(250, 220, 80)
        --color = Color(1, 0.8, 0.1, 0.8)
    else
        maxValue = value
        color = getColor(250, 220, 80)
        --color = Color(0, 1, 0, 0.8)
    end

    --color = Color(0.58, 0.86, 0.25, 0.8)

    return color, maxValue
end

function CardDetailBaseInfoView:ctor()
    self.nameTxt = self.___ex.name
    self.level = self.___ex.level
    self.power = self.___ex.power
    self.value = self.___ex.value
    self.nationText = self.___ex.nationText
    self.heightText = self.___ex.heightText
    self.birthText = self.___ex.birthText

    self.position = self.___ex.position -- table
    self.positionDescMap = self.___ex.positionDescMap

    self.cardParent = self.___ex.cardParent

    self.ploygonCustom = self.___ex.ploygonCustom
    self.ploygonCustom1 = self.___ex.ploygonCustom1

    self.levelProgress = self.___ex.levelProgress
    self.levelProgressTop = self.___ex.levelProgressTop
    self.upgradeProgress = self.___ex.upgradeProgress
    self.upgradeProgressTop = self.___ex.upgradeProgressTop
    self.upgradeSplitLinesParent = self.___ex.upgradeSplitLinesParent
    self.skillProgress = self.___ex.skillProgress
    self.skillProgressTop = self.___ex.skillProgressTop
    self.skillSplitLinesParent = self.___ex.skillSplitLinesParent
    self.rebornProgress = self.___ex.rebornProgress
    self.rebornProgressTop = self.___ex.rebornProgressTop
    self.rebornSplitLinesParent = self.___ex.rebornSplitLinesParent
    self.chemicalProgress = self.___ex.chemicalProgress
    self.chemicalProgressTop = self.___ex.chemicalProgressTop
    self.chemicalSplitLinesParent = self.___ex.chemicalSplitLinesParent
    self.positionView = self.___ex.positionView

    self.abalityBarAnim = self.___ex.abalityBarAnim

    -- 红点
    self.upgradeSign = self.___ex.upgradeSign
    self.skillSign = self.___ex.skillSign

    self.abilitysMap = self.___ex.abilitysMap
    self.preValuesMap = {} -- 上一次五维属性

    -- 进阶特效
    self.upgradeAnimator = self.___ex.upgradeAnimator
    self.upgradeEffect = self.___ex.upgradeEffect

    self.changeAnimTime = 0.3
    self.changeAnimTime1 = 0.15

    self.upgradeSplitLines = {}
    self.rebornSplitLines = {}
    self.skillSplitLines = {}
    self.chemicalSplitLines = {}
    self.effectTab = {}

    local function GetChildTransform(parent, list)
        for i = 1, parent.childCount do
            local child = parent:GetChild(i - 1)
            table.insert(list, child)
        end        
    end

    GetChildTransform(self.upgradeSplitLinesParent, self.upgradeSplitLines)
    GetChildTransform(self.rebornSplitLinesParent, self.rebornSplitLines)
    GetChildTransform(self.skillSplitLinesParent, self.skillSplitLines)
    GetChildTransform(self.chemicalSplitLinesParent, self.chemicalSplitLines)
end

function CardDetailBaseInfoView:start()
    self:RegModelHandler()
end

function CardDetailBaseInfoView:RegModelHandler()
    if self.isOperable then 
        EventSystem.AddEvent("Upgrade_Effect", self, self.UpgradeShow)
        EventSystem.AddEvent("Card_Skill_Open", self, self.OpenSkill)
    end
end

function CardDetailBaseInfoView:onDestroy()
    EventSystem.RemoveEvent("Upgrade_Effect", self, self.UpgradeShow)
    EventSystem.RemoveEvent("Card_Skill_Open", self, self.OpenSkill)
end

function CardDetailBaseInfoView:SetEquipEffectState(isUpgrade)
    self.upgradeAnimator.enabled = isUpgrade
    GameObjectHelper.FastSetActive(self.upgradeEffect, isUpgrade)
    self.cardParent.anchoredPosition = Vector2.zero
    self.cardParent.localScale = Vector3.one
    self.cardParent.localRotation = Quaternion.Euler(Vector3.zero);
end

-- 进阶等特殊逻辑产生的红点在点击技能界面或跳转至下一张牌后会消失
function CardDetailBaseInfoView:OpenSkill()
    if not self.cardDetailModel:GetSkillSpecialRedPoint() then return end
    local hasSkillSign = self.cardDetailModel:HasSkillSign()
    GameObjectHelper.FastSetActive(self.skillSign, hasSkillSign)
    self.cardDetailModel:SetSkillSpecialRedPoint(false)
end

function CardDetailBaseInfoView:UpgradeShow()
    GameObjectHelper.FastSetActive(self.upgradeAnimator.gameObject, false)
    self:SetEquipEffectState(true)
    GameObjectHelper.FastSetActive(self.upgradeAnimator.gameObject, true)

    -- 在进阶后提示技能红点
    self.cardDetailModel:SetSkillSpecialRedPoint(true)
    GameObjectHelper.FastSetActive(self.skillSign, true)
end

function CardDetailBaseInfoView:InitView(cardDetailModel, isChangeValueByFunction)
    -- Card
    local function getRotationZ(vector2_1, vector2_2)
        local x1, y1 = vector2_1.x, vector2_1.y
        local x2, y2 = vector2_2.x, vector2_2.y
        local theta = math.asin((y2 - y1) / math.sqrt(math.pow(x1 - x2 , 2) + math.pow(y1 - y2, 2)))
        if x2 < x1 then
            theta = - theta + math.pi
        end
        return theta * 180 / math.pi
    end

    local function destoryEffect()
        for i, v in ipairs(self.effectTab) do
            UnityEngine.Object.Destroy(v)
        end
    end
    self.abalityBarAnim.enabled = false
    destoryEffect()
    if self.expandCoroutine then
        self.abalityBarAnim.enabled = false
        self:StopCoroutine(self.expandCoroutine)
    end
    self.cardDetailModel = cardDetailModel
    local cardModel = cardDetailModel:GetCardModel()
    self.isOperable = cardDetailModel:IsOperable()
    if not self.cardView then
        self:coroutine(function()
            local cardObject, cardSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
            self:SetCard(cardObject.transform)
            self.cardView = cardSpt
            self.cardView:InitView(cardModel)
        end)
    else
        self.cardView:InitView(cardModel)
    end

    self.nameTxt.text = tostring(cardModel:GetName())
    self.power.text = tostring(cardModel:GetPower())
    local value = string.formatNumWithUnit(cardModel:GetValue())
    self.value.text = "€ " .. value 
    self.positionView:InitView(cardModel)
    self.nationText.text = tostring(cardModel:GetNationName())
    self.heightText.text = tostring(cardModel:GetHeight()) .. "cm"
    self.birthText.text = tostring(cardModel:GetBirthday())

    local pentagonOrder
    if cardModel:IsGKPlayer() then
        pentagonOrder = goalKeeperOrder
    else
        pentagonOrder = normalPlayerOrder
    end

    local fiveAbilityValueList = {}
    local maxAbilityValue = -1
    local hasAbilityChanged = false
    local preValuesMap = clone(self.preValuesMap)
    for i, abilityIndex in ipairs(pentagonOrder) do
        local base, plus = cardModel:GetAbility(abilityIndex)
        local totalValue = base + plus
        if totalValue > maxAbilityValue then
            maxAbilityValue = totalValue
        end
        table.insert(fiveAbilityValueList, totalValue)
        local key = "p" .. tostring(i)
        self.abilitysMap[key]:InitView(abilityIndex, totalValue)
        if isChangeValueByFunction then 
            local preValue = self.preValuesMap[abilityIndex] 
            if preValue and preValue ~= totalValue then 
                hasAbilityChanged = true
                self.abilitysMap[key]:ShowEffect()
            end
        end
        self.preValuesMap[abilityIndex] = totalValue
    end

    local color, maxValue = GetPolygonColorAndMaxValue(maxAbilityValue)
    if not hasAbilityChanged or not preValuesMap then
        local abilityValues = {
            math.sqrt(fiveAbilityValueList[1] / maxValue),
            math.sqrt(fiveAbilityValueList[2] / maxValue),
            math.sqrt(fiveAbilityValueList[3] / maxValue),
            math.sqrt(fiveAbilityValueList[4] / maxValue),
            math.sqrt(fiveAbilityValueList[5] / maxValue),
        }
        self.ploygonCustom.color = color
        self.ploygonCustom.maxValue = 1
        self.ploygonCustom.abilityValues = clr.array(abilityValues, clr.System.Single)
        self.ploygonCustom:SetAllDirty()

        self.ploygonCustom1.color = color
        self.ploygonCustom1.maxValue = 1
        self.ploygonCustom1.abilityValues = clr.array(abilityValues, clr.System.Single)
        self.ploygonCustom1:SetAllDirty()
    else
        local tempTime = 0
        local moveEnd = false
        local moveEnd1 = false
        local lastAbilityValues
        self.expandCoroutine = self:coroutine(function()
            while not moveEnd do
                tempTime = math.min(tempTime + Time.unscaledDeltaTime, self.changeAnimTime)
                local abilityValues = {}
                for i, abilityIndex in ipairs(pentagonOrder) do
                    table.insert(abilityValues, math.sqrt(math.lerp(preValuesMap[abilityIndex], fiveAbilityValueList[i], tempTime / self.changeAnimTime) / maxValue))
                end
                self.ploygonCustom.color = color
                self.ploygonCustom.maxValue = 1
                self.ploygonCustom.abilityValues = clr.array(abilityValues, clr.System.Single)
                self.ploygonCustom:SetAllDirty()
                if tempTime == self.changeAnimTime then
                    moveEnd = true
                    tempTime = 0
                    lastAbilityValues = abilityValues
                end
                coroutine.yield()
            end
            if maxValue == self.preMaxAbilityValue then
                self.abalityBarAnim.enabled = true
                local positionTab = clr.table(self.ploygonCustom.indexPositionArray)
                for i, abilityIndex in ipairs(pentagonOrder) do
                    if preValuesMap[abilityIndex] ~= fiveAbilityValueList[i] then
                        local effect1 = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Effects/EffectAbilityChangeLight.prefab")
                        local effect2 = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/CardDetail/Effects/EffectAbilityChangeLight.prefab")
                        local nextIndex = ((i + 1) > 5) and 1 or (i + 1)
                        local preIndex = ((i - 1) < 1) and 5 or (i - 1)
                        effect1.transform:SetParent(self.ploygonCustom.transform, false)
                        effect1.transform.localPosition = UnityEngine.Vector3(positionTab[nextIndex].x, positionTab[nextIndex].y, 0)
                        effect1.transform.localEulerAngles = UnityEngine.Vector3(0, 0, getRotationZ(positionTab[nextIndex], positionTab[i]))
                        effect2.transform:SetParent(self.ploygonCustom.transform, false)
                        effect2.transform.localPosition = UnityEngine.Vector3(positionTab[preIndex].x, positionTab[preIndex].y, 0)
                        effect2.transform.localEulerAngles = UnityEngine.Vector3(0, 0, getRotationZ(positionTab[preIndex], positionTab[i]))
                        table.insert(self.effectTab, effect1)
                        table.insert(self.effectTab, effect2)
                    end
                end
                coroutine.yield(UnityEngine.WaitForSeconds(1))
                self.abalityBarAnim.enabled = false
                destoryEffect()
            else
            end
            while not moveEnd1 do
                tempTime = math.min(tempTime + Time.unscaledDeltaTime, self.changeAnimTime1)
                local abilityValues = {}
                for i, abilityIndex in ipairs(pentagonOrder) do
                    table.insert(abilityValues, math.sqrt(math.lerp(preValuesMap[abilityIndex], fiveAbilityValueList[i], tempTime / self.changeAnimTime1) / maxValue))
                end
                self.ploygonCustom1.color = color
                self.ploygonCustom1.maxValue = 1
                self.ploygonCustom1.abilityValues = clr.array(abilityValues, clr.System.Single)
                self.ploygonCustom1:SetAllDirty()
                if tempTime == self.changeAnimTime1 then
                    moveEnd1 = true
                    lastAbilityValues = abilityValues
                end
                coroutine.yield()
            end
        end)
    end
    self.preMaxAbilityValue = maxValue

    -- 场上位置
    self:SetPosition(cardModel)

    self:SetProgressInfo(cardModel)

    -- 进阶红点
    local hasUpgradeSign = cardDetailModel:HasUpgradeSign()
    GameObjectHelper.FastSetActive(self.upgradeSign, hasUpgradeSign)
    -- 技能升级红点
    if self.cardDetailModel:GetSkillSpecialRedPoint() then 
        GameObjectHelper.FastSetActive(self.skillSign, true)
    else
        local hasSkillSign = cardDetailModel:HasSkillSign()
        GameObjectHelper.FastSetActive(self.skillSign, hasSkillSign) 
    end

    self:SetEquipEffectState(false)
end

function CardDetailBaseInfoView:SetPosition(cardModel)
    local position = cardModel:GetPosition()
    assert(type(position) == "table")
    for k, v in pairs(self.position) do
        GameObjectHelper.FastSetActive(v, false)
    end
    for i, v in ipairs(position) do
        local key = "p" .. tostring(CardConfig.POSITION_LETTER_MAP[v])
        GameObjectHelper.FastSetActive(self.position[key], true)
        self.positionDescMap[key].text = cardModel:GetSinglePositionDesc(v)
    end
end

function CardDetailBaseInfoView:SetCard(cardTransform)
    cardTransform:SetParent(self.cardParent, false)
end

function CardDetailBaseInfoView:SetProgressInfo(cardModel)
    self.level.text = tostring(cardModel:GetLevel()) .. "/" ..tostring(cardModel:GetLevelLimit())
    self.levelProgress.value = cardModel:GetLevel() / cardModel:GetLevelLimit()
    local maxUpgrade = cardModel:GetMaxUpgradeNum()
    local upgrade = cardModel:GetUpgrade()
    local maxAscend = cardModel:GetMaxAscendNum()
    local ascend = cardModel:GetAscend()
    local skillAmount = cardModel:GetSkillAmount()
    local activatedSkillAmount = cardModel:GetActivatedSkillAmount()

    self.upgradeProgress.maxValue = maxUpgrade
    if upgrade == 0 then
        self.upgradeProgress.interactable = false
        GameObjectHelper.FastSetActive(self.upgradeProgressTop, false)
    elseif upgrade == maxUpgrade then
        self.upgradeProgress.interactable = false
        GameObjectHelper.FastSetActive(self.upgradeProgressTop, true)
    else
        self.upgradeProgress.interactable = true
        self.upgradeProgress.value = upgrade
        GameObjectHelper.FastSetActive(self.upgradeProgressTop, false)
    end

    self.rebornProgress.maxValue = maxAscend
    if ascend == 0 then
        self.rebornProgress.interactable = false
        GameObjectHelper.FastSetActive(self.rebornProgressTop, false)
    elseif ascend == maxAscend then
        self.rebornProgress.interactable = false
        GameObjectHelper.FastSetActive(self.rebornProgressTop, true)
    else
        self.rebornProgress.interactable = true
        self.rebornProgress.value = ascend
        GameObjectHelper.FastSetActive(self.rebornProgressTop, false)
    end

    self.skillProgress.maxValue = skillAmount
    if activatedSkillAmount == 0 then
        self.skillProgress.interactable = false
        GameObjectHelper.FastSetActive(self.skillProgressTop, false)
    elseif activatedSkillAmount == skillAmount then
        self.skillProgress.interactable = false
        GameObjectHelper.FastSetActive(self.skillProgressTop, true)
    else
        self.skillProgress.interactable = true
        self.skillProgress.value = activatedSkillAmount
        GameObjectHelper.FastSetActive(self.skillProgressTop, false)
    end

    local function SetActiveFalse(objectTable)
        for k, v in pairs(objectTable) do
            GameObjectHelper.FastSetActive(v.gameObject, false)
        end        
    end

    SetActiveFalse(self.upgradeSplitLines)
    SetActiveFalse(self.rebornSplitLines)
    SetActiveFalse(self.skillSplitLines)

    local function SetSplitLine(amount, splitLinesTable)
        for i = 1, amount - 1 do
            local rectTrans = splitLinesTable[i]
            GameObjectHelper.FastSetActive(rectTrans.gameObject, true)
            rectTrans.anchorMax = Vector2(i / amount, 0.5)
            rectTrans.anchorMin = Vector2(i / amount, 0.5)
        end
    end

    SetSplitLine(maxUpgrade, self.upgradeSplitLines)
    SetSplitLine(maxAscend, self.rebornSplitLines)
    SetSplitLine(skillAmount, self.skillSplitLines)
end

return CardDetailBaseInfoView
