local BreakThroughView = class(unity.base)

local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local greenColor = Color(145/255, 250/255, 90/255, 255/255)
local redColor = Color(250/255, 65/255, 65/255, 255/255)

local normalPlayerAttr = {
    "shoot",
    "intercept",
    "steal",
    "dribble",
    "pass"
}
local goalKeeperAttr = {
    "goalkeeping",  -- 门线技术
    "anticipation", -- 球路判断
    "commanding",   -- 防线指挥
    "composure",    -- 心理素质
    "launching"     -- 发起进攻
}

function BreakThroughView:ctor()
    self.btnBreak = self.___ex.btnBreak
    self.breakButton = self.___ex.breakButton
    self.btnSave = self.___ex.btnSave
    self.btnCancel = self.___ex.btnCancel
    self.groupSave = self.___ex.groupSave
    self.groupBreak = self.___ex.groupBreak

    self.breakTimes = self.___ex.breakTimes
    self.breakTimesBottom = self.___ex.breakTimesBottom
    self.breakItemNum = self.___ex.breakItemNum
    self.breakItemNumBottom = self.___ex.breakItemNumBottom
    self.potentiality = self.___ex.potentiality
    self.potentialityPlus = self.___ex.potentialityPlus

    self.fiveAttrText = self.___ex.fiveAttrText --table
    self.fiveAttrPotent = self.___ex.fiveAttrPotent --table
    self.fiveAttrPotentTmp = self.___ex.fiveAttrPotentTmp --table

    self.breakText = self.___ex.breakText
    self.breakTimeEffect = self.___ex.breakTimeEffect
    self.breakItemEffect = self.___ex.breakItemEffect
end

function BreakThroughView:start()
    self.btnBreak:regOnButtonClick(function()
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
end

function BreakThroughView:SetButtonState(isBreak)
    self.breakButton.interactable = isBreak
    local color = isBreak and Color(0.478, 0.306, 0.118) or Color(0.196, 0.196, 0.196)
    self.breakText.color = color
end

function BreakThroughView:InitView(cardModel, itemsMapModel)
    local breakCount = cardModel:GetFreeAdvance()
    local breakItemNum = itemsMapModel:GetItemNum(1)
    self.breakTimes.text = tostring(breakCount)
    self.breakItemNum.text = tostring(breakItemNum)
    self:ShowBreakEffect(breakCount, breakItemNum)
    if cardModel:GetFreeAdvance() > 0 then
        self.breakTimesBottom:SetActive(false)
        self.breakItemNumBottom:SetActive(true)
    elseif itemsMapModel:GetItemNum(1) > 0 then
        self.breakTimesBottom:SetActive(true)
        self.breakItemNumBottom:SetActive(false)
    else
        self.breakTimesBottom:SetActive(true)
        self.breakItemNumBottom:SetActive(true)
    end
    
    self.potentiality.text = tostring(cardModel:GetStaticPotential() - cardModel:GetConsumePotent() + cardModel:GetLegendPotentImprove())
    self.potentialityPlus.text = ""
    self.groupBreak:SetActive(true)
    self.groupSave:SetActive(false)

    local fiveAttr
    if cardModel:IsGKPlayer() then
        fiveAttr = goalKeeperAttr
    else
        fiveAttr = normalPlayerAttr
    end

    for i, abilityIndex in ipairs(fiveAttr) do
        self.fiveAttrText["t" .. tostring(i)].text = lang.trans(abilityIndex)
        self.fiveAttrPotent["t" .. tostring(i)].text = tostring(cardModel:GetAdvancePotential(abilityIndex))
        self.fiveAttrPotentTmp["t" .. tostring(i)].text = ""
    end

    local isBreak = tobool(cardModel:GetFreeAdvance() > 0 or itemsMapModel:GetItemNum(1) > 0)
    self:SetButtonState(isBreak)
end

function BreakThroughView:ShowBreakEffect(breakCount, breakItemNum)
    local isShowTimeEffect = breakCount > 0 and true or false
    local isShowItemEffect = breakItemNum > 0 and true or false
    GameObjectHelper.FastSetActive(self.breakTimeEffect, isShowTimeEffect)
    GameObjectHelper.FastSetActive(self.breakItemEffect, not isShowTimeEffect and isShowItemEffect)
end

function BreakThroughView:HideParticle()
    self:ShowBreakEffect(0, 0)
end

function BreakThroughView:UpdateUnsavedAdvanceResult(unsavedCardModel, itemsMapModel)
    self.groupBreak:SetActive(false)
    self.groupSave:SetActive(true)
    local breakCount = unsavedCardModel:GetFreeAdvance()
    local breakItemNum = itemsMapModel:GetItemNum(1)
    self.breakTimes.text = tostring(breakCount)
    self.breakItemNum.text = tostring(breakItemNum)
    self:ShowBreakEffect(breakCount, breakItemNum)

    local consumePotentTmp = unsavedCardModel:GetTmpConsumePotent()
    if consumePotentTmp == 0 then
        self.potentialityPlus.text = ""
    elseif consumePotentTmp < 0 then
        self.potentialityPlus.text = "+" .. tostring(math.abs(consumePotentTmp))
        self.potentialityPlus.color = greenColor
    else
        self.potentialityPlus.text = "-" .. tostring(math.abs(consumePotentTmp))
        self.potentialityPlus.color = redColor
    end

    local fiveAttr
    if unsavedCardModel:IsGKPlayer() then
        fiveAttr = goalKeeperAttr
    else
        fiveAttr = normalPlayerAttr
    end

    for i, abilityIndex in ipairs(fiveAttr) do
        local tmpChangeValue = unsavedCardModel:GetAbilityChange(abilityIndex)
        local tmpTextComp = self.fiveAttrPotentTmp["t" .. tostring(i)]
        if tmpChangeValue == 0 then
            tmpTextComp.text = ""
        elseif tmpChangeValue > 0 then
            tmpTextComp.text = "+" .. tostring(math.abs(tmpChangeValue))
            tmpTextComp.color = greenColor
        else
            tmpTextComp.text = "-" .. tostring(math.abs(tmpChangeValue))
            tmpTextComp.color = redColor
        end
    end
end

return BreakThroughView
