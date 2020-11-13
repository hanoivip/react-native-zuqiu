local CardDetailUIEffectHandler = class(unity.base)

local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local WaitForEndOfFrame = UnityEngine.WaitForEndOfFrame

function CardDetailUIEffectHandler:ctor()
    self.animator = self.___ex.animator
    self.btnUpgradeEffectCircle = self.___ex.btnUpgradeEffectCircle
    self.btnUpgradeEffectClick = self.___ex.btnUpgradeEffectClick
    self.highLight = self.___ex.highLight -- table
    self.equipSelfEffect = self.___ex.equipSelfEffect
    self.skillOpenEffect = self.___ex.skillOpenEffect
    self.cardShining = self.___ex.cardShining
    self.cardBling = self.___ex.cardBling
end

function CardDetailUIEffectHandler:start()
end

function CardDetailUIEffectHandler:SetUpgradeButtonState(isActive)
    if isActive then
        self.btnUpgradeEffectCircle:SetActive(true)
        self.animator:Play("EffectCardDetailButtonRay")
        self.cardShining:SetActive(false)

    else
        self.btnUpgradeEffectCircle:SetActive(false)        
    end
end

function CardDetailUIEffectHandler:SetUpgradeButtonClick()
    self.btnUpgradeEffectClick:SetActive(false)
    self.btnUpgradeEffectClick:SetActive(true)    
end

function CardDetailUIEffectHandler:SetEquipSelf(position)
    self.equipSelfEffect.transform.position = position
    self.equipSelfEffect:SetActive(false)
    self.equipSelfEffect:SetActive(true)
end

function CardDetailUIEffectHandler:SetSkillOpen(position)
    self.skillOpenEffect.transform.position = position
    self.skillOpenEffect:SetActive(false)
    self.skillOpenEffect:SetActive(true)
end

function CardDetailUIEffectHandler:SetEquipGroupAnimation(equipsNum)
    self.btnUpgradeEffectCircle:SetActive(false)
    self.btnUpgradeEffectClick:SetActive(false)
    for k, v in pairs(self.highLight) do
        v:SetActive(false)
    end
    self.cardShining:SetActive(false)

    self:coroutine(function()
        for i = 1, equipsNum do
            self.highLight["h" .. tostring(i)]:SetActive(true)
        end
        self.animator:Play("EquipContentHighLight")
        for i = 1, equipsNum do
            self.cardBling:SetActive(false)
            coroutine.yield(WaitForEndOfFrame())
            self.cardBling:SetActive(true)
            coroutine.yield(WaitForSeconds(0.3))
        end
        self.cardShining:SetActive(true)
        self.animator:Play("EffectCardDetailButtonRay")
        for k, v in pairs(self.highLight) do
            v:SetActive(false)
        end
    end)
end

return CardDetailUIEffectHandler
