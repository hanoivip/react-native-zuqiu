local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerBindingEquipModel = require("ui.models.cardDetail.PlayerBindingEquipModel")
local PlayerRecycleModel = require("ui.models.playerRecycle.PlayerRecycleModel")
local ColorConversionHelper = require("ui.common.ColorConversionHelper")
local AdvanceView = class(unity.base)

function AdvanceView:ctor()
    self.skillsMap = self.___ex.skillsMap
    self.equipsMap = self.___ex.equipsMap
    self.linesMap = self.___ex.linesMap
    self.btnAdvance = self.___ex.btnAdvance
    self.advanceText = self.___ex.advanceText
    self.advanceShadow = self.___ex.advanceShadow
    self.notAvailable = self.___ex.notAvailable
    self.available = self.___ex.available
    self.btnOnekey = self.___ex.btnOnekey
    self.onekeyDisable = self.___ex.onekeyDisable
    self.onekeyAvailable = self.___ex.onekeyAvailable
    self.onekeyText = self.___ex.onekeyText
    self.recycle = self.___ex.recycle
    self.recycleDisable = self.___ex.recycleDisable
    self.recycleAvailable = self.___ex.recycleAvailable
    self.recycleTxt = self.___ex.recycleTxt
end

function AdvanceView:EnterScene()
    EventSystem.AddEvent("PlayerCardModel_WearEquip", self, self.WearEquipEffect)
end

function AdvanceView:ExitScene()
    EventSystem.RemoveEvent("PlayerCardModel_WearEquip", self, self.WearEquipEffect)
end

function AdvanceView:start()
    self.btnAdvance:regOnButtonClick(function()
        self:OnBtnAdvance()
    end)
    self.btnOnekey:regOnButtonClick(function()
        self:OnBtnOnekey()
    end)
    self.recycle:regOnButtonClick(function()
        self:OnBtnRecycle()
    end)

    for k, v in pairs(self.equipsMap) do
        v.clickEquip = function(slot) self:OnBtnEquip(slot) end
    end

    for k, v in pairs(self.skillsMap) do
        v.clickSkill = function(slot) self:OnBtnSkill(slot) end
    end
end

function AdvanceView:OnBtnSkill(slot)
    if self.clickSkill then 
        self.clickSkill(slot)
    end
end

function AdvanceView:OnBtnEquip(slot)
    if self.clickEquip then 
        self.clickEquip(slot)
    end
end

function AdvanceView:OnBtnAdvance()
    if self.clickAdvance then 
        self.clickAdvance()
    end
end

function AdvanceView:OnBtnOnekey()
    if self.clickOnekey then 
        self.clickOnekey()
    end
end

function AdvanceView:OnBtnRecycle()
    local isSupporterCloseByConfig = self.cardDetailModel:IsSupporterCloseByConfig()
    local cardModel = self.cardDetailModel:GetCardModel()
    local hasRecycle = cardModel:IsOperable() and cardModel:IsCanRecycle()
    if hasRecycle and self.recycleTag and (not isSupporterCloseByConfig) then
        self.playerRecycleModel:SetDefaultTag(self.recycleTag)
        res.PushDialog("ui.controllers.playerRecycle.PlayerRecycleCtrl", self.playerRecycleModel)
    end
end

function AdvanceView:OnUpdateUpgradeData(upgradeData)
    if self.updateUpgradeData then 
        self.updateUpgradeData(upgradeData)
    end
end

local function GetTextColor(isShow)
    local r, g, b 
    if isShow then 
        r, g, b = 101, 85, 60
    else
        r, g, b = 147, 147, 147
    end
    local color = ColorConversionHelper.ConversionColor(r, g, b)
    return color
end
    
function AdvanceView:SetButtonState(cardModel)
    local interactable = cardModel:IsOperable() and cardModel:IsCanUpgrade()
    local color = GetTextColor(interactable)
    self.advanceText.color = color
    GameObjectHelper.FastSetActive(self.notAvailable, not interactable)
    GameObjectHelper.FastSetActive(self.available, interactable)

    local isCanUseSupporter = cardModel:CanUseSupporter()
    local isSupporterCloseByConfig = self.cardDetailModel:IsSupporterCloseByConfig()
    local hasOneKeyEquip = (cardModel:IsOperable() and cardModel:HasOneKeyEquip()) or (isCanUseSupporter and not isSupporterCloseByConfig)
    color = GetTextColor(hasOneKeyEquip)
    self.onekeyText.color = color
    if isCanUseSupporter and (not isSupporterCloseByConfig) then
        self.onekeyText.text = lang.trans("support_title")
    else
        self.onekeyText.text = lang.trans("one_key_equip")
    end
    GameObjectHelper.FastSetActive(self.onekeyAvailable, hasOneKeyEquip)
    GameObjectHelper.FastSetActive(self.onekeyDisable, not hasOneKeyEquip)

    local hasRecycle = cardModel:IsOperable() and cardModel:IsCanRecycle() and (not isSupporterCloseByConfig)
    self.playerRecycleModel = PlayerRecycleModel.new(cardModel)
    self.recycleTag = self.playerRecycleModel:GetRecycleTag()
    hasRecycle = hasRecycle and self.recycleTag

    color = GetTextColor(hasRecycle)
    self.recycleTxt.color = color
    GameObjectHelper.FastSetActive(self.recycleAvailable, hasRecycle)
    GameObjectHelper.FastSetActive(self.recycleDisable, not hasRecycle)
end

function AdvanceView:WearEquipEffect(slot)
    local index = tonumber(slot) + 1
    self.equipsMap["s" .. tostring(index)]:ShowWearEquipEffect()
end

-- 满装备进阶会开启新技能
function AdvanceView:InitView(cardDetailModel)
    self.cardDetailModel = cardDetailModel
    local equipsList = cardDetailModel:GetEquipsList()
    local equipsModelMap = cardDetailModel:GetEquipsMap()
    local skillsList = cardDetailModel:GetSkillsList()
    local skillsModelMap = cardDetailModel:GetSkillsMap()
    local cardModel = cardDetailModel:GetCardModel()
    self:SetButtonState(cardModel)

    local isSkillAllOpen = true
    local nextOpenIndex = 1
    local ownerSkill = 0

    for i, v in ipairs(skillsList) do
        if not v.ptid then 
            ownerSkill = ownerSkill + 1
            if v.isOpen then 
                nextOpenIndex = nextOpenIndex + 1
            else
                isSkillAllOpen = false
            end
        end
    end
    self.nextOpenIndex = nextOpenIndex
    
    local equipNum = #equipsList
    local skillNum = ownerSkill
    self.isSkillAllOpen = isSkillAllOpen

    for i = 1, 6 do
        -- 装备
        local equipView = self.equipsMap["s" .. tostring(i)]
        local equipData = equipsList[i] 
        local equipItemModel
        if equipData then 
            equipItemModel = equipsModelMap[tostring(equipData.slot)]
        end
        equipView:InitView(equipItemModel, cardDetailModel)

        -- 技能
        local skillView = self.skillsMap["s" .. tostring(i)]
        local skillData = skillsList[i]
        local skillItemModel
        if skillData and not skillData.ptid then 
            skillItemModel = skillsModelMap[i]
        end
        skillView:InitView(skillItemModel, cardDetailModel)

        -- 线
        local line = self.linesMap["s" .. tostring(i)]
        local isShow = false
        if isSkillAllOpen then 
            GameObjectHelper.FastSetActive(line.gameObject, not isSkillAllOpen)
        else
            if i <= equipNum then 
                isShow = true
                line:InitView(i, equipNum, nextOpenIndex)
            end
            GameObjectHelper.FastSetActive(line.gameObject, isShow)
        end
    end

    -- ios提审屏蔽卡牌还原
    if luaevt.trig("___EVENT__NOT_OPEN_FORBIDDEN") then
        GameObjectHelper.FastSetActive(self.recycle.gameObject, false)
    end
end

function AdvanceView:ShowAdvanceEffect(upgradeData)
    local nextEquipData = upgradeData.card.equips
    local equipsList = self.cardDetailModel:GetEquipsList()
    local equipNum = #equipsList
    if self.isSkillAllOpen then 
        self:OnUpdateUpgradeData(upgradeData)
        return 
    end 
    local currentEventSystem = EventSystems.EventSystem.current
    currentEventSystem.enabled = false
    for i = 1, 6 do
        local line = self.linesMap["s" .. tostring(i)]
        if i <= equipNum then 
            line:ShowLineEffect()
        end

        if equipsList[i] then 
            local equipView = self.equipsMap["s" .. tostring(i)]
            local currentEquipItemModel = PlayerBindingEquipModel.new(equipsList[i].eid)
            local nextEquipItemModel = PlayerBindingEquipModel.new(nextEquipData[i].eid)
            equipView:ShowAdvanceEffect(currentEquipItemModel, nextEquipItemModel)
        end
    end
    self.skillsMap["s" .. tostring(self.nextOpenIndex)]:ShowAdvanceEffect()

    self:coroutine(function()
        coroutine.yield(WaitForSeconds(1.5))
        for i = 1, 6 do
            local line = self.linesMap["s" .. tostring(i)]
            line:DisableLineEffect()

            local equipView = self.equipsMap["s" .. tostring(i)]
            equipView:DisableAdvanceEffect()
        end
        self.skillsMap["s" .. tostring(self.nextOpenIndex)]:DisableAdvanceEffect()
        self:OnUpdateUpgradeData(upgradeData)
        currentEventSystem.enabled = true
    end)
end

return AdvanceView