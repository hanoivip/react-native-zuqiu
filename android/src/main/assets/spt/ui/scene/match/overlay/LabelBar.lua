local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local LabelBar = class(unity.base)

local whiteColor = Color(1, 1, 1)

function LabelBar:ctor()
    self.textComponent = self.___ex.text
    self.skillBar = self.___ex.skillBar
    self.skillIcon = self.___ex.skillIcon
    self.animator = self.___ex.animator
    self.skillValueText = self.___ex.skillValue

    self.skillBarEffect = self.___ex.skillBarEffect
    self.skillBarEffectGreen = self.___ex.skillBarEffectGreen
    self.skillBarEffectRed = self.___ex.skillBarEffectRed
    self.skillBarEffectBlue = self.___ex.skillBarEffectBlue

    self.textBarEffect = self.___ex.textBarEffect
    self.textBarEffectGreen = self.___ex.textBarEffectGreen
    self.textBarEffectRed = self.___ex.textBarEffectRed
    self.textBarEffectBlue = self.___ex.textBarEffectBlue
end

function LabelBar:init(transform)
    self.transform:SetParent(transform, false)
    self.animator:Play("Base Layer.Empty")
    self.skillBar:SetActive(false)
end

function LabelBar:setText(text, color)
    self.textComponent.text = text
    self.textComponent.color = color or whiteColor
end

function LabelBar:setSkillValue(text)
    if text and text ~= clr.null then
        self.skillValueText.transform.gameObject:SetActive(true)
        self.skillValueText.text = text
    else
        self.skillValueText.transform.gameObject:SetActive(false)
    end
end

function LabelBar:setIcon(icon)
    if icon and icon ~= clr.null then
        self.skillBar:SetActive(true)
        self.skillIcon.overrideSprite = icon
    else
        self.skillBar:SetActive(false)
    end
end

function LabelBar:playMoveIn()
    self.animator:Play("Base Layer.LabelBar")
end

function LabelBar:playFlash()
    if self.skillBar.activeSelf then
        self.skillBarEffect:SetActive(true)
        self.skillBarEffectGreen:SetActive(true)
    end

    -- self.textBarEffect:SetActive(true)
    -- self.textBarEffectGreen:SetActive(true)
end

function LabelBar:stopFlash()
    self.skillBarEffect:SetActive(false)
    self.skillBarEffectGreen:SetActive(false)
    self.skillBarEffectRed:SetActive(false)
    self.skillBarEffectBlue:SetActive(false)

    self.textBarEffect:SetActive(false)
    self.textBarEffectGreen:SetActive(false)
    self.textBarEffectRed:SetActive(false)
    self.textBarEffectBlue:SetActive(false)
end

function LabelBar:onExit()
end

return LabelBar
