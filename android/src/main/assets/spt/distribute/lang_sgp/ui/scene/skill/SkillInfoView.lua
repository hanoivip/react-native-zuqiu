local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local SkillShowType = require("ui.scene.skill.SkillShowType")
local SkillInfoView = class(unity.base)

function SkillInfoView:ctor()
    self.skillLevel = self.___ex.skillLevel
    self.skillTip = self.___ex.skillTip
    self.skillBarArea = self.___ex.skillBarArea
    self.isCurrentInfo = self.___ex.isCurrentInfo
    self.skillAttributeMap = { }
end

function SkillInfoView:InitView(skillItemModel)
    self.skillItemModel = skillItemModel
end

local DescCharacter = { "{x}", "{y}", "{a}", "{b}", "{c}" }
local function GetSkillExtraDesc(descArray, attributePlusTable)
    local skillDesc = ""
    local k = 1
    for i, desc in ipairs(descArray) do
        local realDesc, count = string.gsub(desc, DescCharacter[k], tostring(attributePlusTable[k]), 1)
        skillDesc = skillDesc .. realDesc
        if count > 0 then k = k + 1 end

        if i < #descArray then
            skillDesc = skillDesc .. "\n"
        end
    end
    return skillDesc
end

function SkillInfoView:GetSkillAtributeRes()
    if not self.skillAttributeRes then
        self.skillAttributeRes = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/SkillDetail/SkillBar.prefab")
    end
    return self.skillAttributeRes
end

function SkillInfoView:GetSkillAtributeView(index)
    if not self.skillAttributeMap[index] then
        local attributeItem = Object.Instantiate(self:GetSkillAtributeRes())
        attributeItem.transform:SetParent(self.skillBarArea, false)
        local attributeView = res.GetLuaScript(attributeItem)
        self.skillAttributeMap[index] = attributeView
    end
    return self.skillAttributeMap[index]
end

local DefaultSkillAttributeMaxCount = 5
function SkillInfoView:SetSkillAttribute(level)
    local skillItemModel = self.skillItemModel
    local levelEx = 0
    if skillItemModel:IsOpen() then 
        levelEx = skillItemModel:GetLevelEx()
    end
    local attributePlusTable = skillItemModel:GetEffectPlus(level + levelEx)
    local level = "Lv" .. level
    local levelStr
    if self.isCurrentInfo then
        levelStr = lang.transstr("current_level_num", level)
    else
        levelStr = lang.transstr("next_level_num", level)
    end
    local levelExStr = levelEx > 0 and "  <color=#2E8B57>+" .. levelEx .."</color>" or ""
    self.skillLevel.text = levelStr .. levelExStr
    if skillItemModel:IsEventSkill() then
        local desc2 = skillItemModel:GetDesc2()
        local skillDesc = GetSkillExtraDesc(desc2, attributePlusTable)
        self.skillTip.text = skillDesc
        GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, false)
    else
        local isExEventSkill = skillItemModel:IsExEventSkill()
        if isExEventSkill then
            local desc2 = skillItemModel:GetDesc2()
            local skillDesc = GetSkillExtraDesc(desc2, attributePlusTable)
            self.skillTip.text = skillDesc
            return
        end

        GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, true)
        local index = 1
        local isAllAttribute = false
        local newAttribute = { }
        for abilityIndex, plusValue in pairs(attributePlusTable) do
            table.insert(newAttribute, { desc = abilityIndex, plus = plusValue })
        end

        local attributeNum = table.nums(newAttribute)
        if attributeNum >= DefaultSkillAttributeMaxCount then
            -- 需要判断是否为全属性
            local matchValue = newAttribute[1].plus
            isAllAttribute = true
            for i, v in pairs(newAttribute) do
                if v.plus ~= matchValue then
                    isAllAttribute = false
                    break
                end
            end
        end

        if isAllAttribute then
            -- 全属性
            local attributeView = self:GetSkillAtributeView(index)
            local plusValue = newAttribute[1].plus
            attributeView:InitView("allAttribute", plusValue, self.isCurrentInfo)
            GameObjectHelper.FastSetActive(attributeView.gameObject, true)
            index = index + 1
        else
            for i, v in ipairs(newAttribute) do
                local attributeView = self:GetSkillAtributeView(i)
                attributeView:InitView(v.desc, v.plus, self.isCurrentInfo)
                GameObjectHelper.FastSetActive(attributeView.gameObject, true)
            end
            index = table.nums(newAttribute) + 1
        end

        -- 处理上一次记录的数据
        for i = index, table.nums(self.skillAttributeMap) do
            GameObjectHelper.FastSetActive(self.skillAttributeMap[i].gameObject, false)
        end
    end
end

-- 未开启技能
function SkillInfoView:NotOpen(skillItemModel, skillShowType)
    GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, false)
    self.skillLevel.text = lang.trans("unlock_condition") 
    if skillShowType == SkillShowType.IsPaster then 
        self.skillTip.text = ""
    else
        local needUpgrade = " +" .. skillItemModel:GetSkillOpenToNeedUpgrade()
        self.skillTip.text = lang.trans("upgrade_need", needUpgrade) 
    end
end

-- 无技能效果
function SkillInfoView:NoSkillEffect()
    GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, false)
    self.skillLevel.text = lang.trans("skillNoEffectPlus")
    self.skillTip.text = lang.trans("skillNoEffectPlus")
end

-- 技能到达上限
function SkillInfoView:ToMax()
    GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, false)
    self.skillLevel.text = lang.trans("skillDetail_tip3")
    self.skillTip.text = lang.trans("skillDetail_tip3")
end

-- 技能到达上限，但是可以转生增加上限
function SkillInfoView:UpToMaxAscend()
    GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, false)
    self.skillLevel.text = lang.trans("unlock_condition") 
    self.skillTip.text = lang.trans("skillDetail_tip2")
end

-- 技能到达上限，但是可以进阶增加上限
function SkillInfoView:UpToMaxUpgrade()
    GameObjectHelper.FastSetActive(self.skillBarArea.gameObject, false)
    self.skillLevel.text = lang.trans("unlock_condition") 
    self.skillTip.text = lang.trans("skillDetail_tip1")
end

return SkillInfoView
