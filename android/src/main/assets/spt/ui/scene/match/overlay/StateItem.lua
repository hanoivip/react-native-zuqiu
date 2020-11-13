local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local Color = UnityEngine.Color

local Num2LetterPos = require("data.Num2LetterPos")
local Letter2NumPos = require("data.Letter2NumPos")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local BlockDebuffSkills = require("ui.scene.match.overlay.BlockDebuffSkills")

local Green = Color(144.0 / 255, 243.0 / 255, 38.0 / 255)
local Red = Color(1, 42.0 / 255, 78.0 / 255)

local StateItem = class(unity.base)

function StateItem:ctor()
    self.positionImage = self.___ex.positionImage
    self.playerName = self.___ex.playerName
    self.up = self.___ex.up
    self.down = self.___ex.down
    self.valueText = self.___ex.valueText
    self.positionText = self.___ex.positionText
    self.buffListPanel = self.___ex.buffListPanel
    self.buffListPanelTransform = self.buffListPanel.transform

    self.buffList = nil
    self.value = 0
end

-- public struct AthleteBuff --BuffInstance
-- {
--     public int BuffId; // Buff的唯一ID
--     public float Time; // Buff出现或者消失的时间
--     public int AthleteId; // Buff作用的球员ID
--     public int OnfieldId; // Buff作用的球员OnfieldID
--     public float Value; // Buff的增益效果, Value = 1 => +100%; Value = -0.5 => -50%
--     public int State; // 0 == Buff出现, 1 == Buff消失
--     public string SkillId; // Buff对应的技能ID
-- }
function StateItem:init(athleteData)
    self.athleteId = athleteData.id
    self.onfieldId = athleteData.onfieldId

    local athlete = ___matchUI:getAthlete(athleteData.id)
    self.playerName.text = athlete.name
    local favPos = Num2LetterPos[tostring(athlete.role)]
    self.positionText.text = Letter2NumPos[favPos].displayPos
    GameObjectHelper.FastSetActive(self.up, true)
    GameObjectHelper.FastSetActive(self.down, false)
    self.valueText.text = "0%"

    self.buffList = {}
    self.value = 0

    local count = self.buffListPanelTransform.childCount

    for i = 0, count - 1 do
        GameObjectHelper.FastSetActive(self.buffListPanel.transform:GetChild(i).gameObject, false)
    end

    local posNum = tonumber(athlete.role)
    local posColorFlagIndex = 1
    if posNum >= 1 and posNum <= 5 then
        posColorFlagIndex = 1
    elseif posNum >= 6 and posNum <= 20 then
        posColorFlagIndex = 2
    elseif posNum >= 21 and posNum <= 25 then
        posColorFlagIndex = 3
    elseif posNum == 26 then
        posColorFlagIndex = 4
    end
    self.positionImage.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/Images/Common/PosColorFlag" .. posColorFlagIndex .. ".png")
end

local function IsBlockDebuff(buffInstance)
    for _, skillId in ipairs(BlockDebuffSkills) do
        if buffInstance.SkillId == skillId and buffInstance.Value == 0 then
            return true
        end
    end
    return false
end

function StateItem:showValue()
    self:updateValueWithDebuffBlock()
    self.valueText.text = math.round(math.abs(self.value) * 100) .. "%"
    if self.value < 0 then
        self.valueText.color = Red
        GameObjectHelper.FastSetActive(self.up, false)
        GameObjectHelper.FastSetActive(self.down, true)
    else
        self.valueText.color = Green
        GameObjectHelper.FastSetActive(self.up, true)
        GameObjectHelper.FastSetActive(self.down, false)
    end
end

function StateItem:updateValueWithDebuffBlock()
    local hasDebuffBlockBuff = nil
    for i, buff in ipairs(self.buffList) do
        if buff.debuffBlock then
            hasDebuffBlockBuff = true
        end
    end
    
    -- 禁用debuff时，处理一下总数值
    if hasDebuffBlockBuff then
        self.value = 0
        for i, buff in ipairs(self.buffList) do
            if buff.value > 0 then
                self.value = self.value + buff.value
            end
        end
    else
        self.value = 0
        for i, buff in ipairs(self.buffList) do
            self.value = self.value + buff.value
        end
    end
end

function StateItem:addBuff(buffInstance)
    local foundBuff = nil
    local foundBuffIndex = nil
    local debuffBlock = IsBlockDebuff(buffInstance)

    for i, buff in ipairs(self.buffList) do
        if buff.skillId == buffInstance.SkillId and not buff.debuffBlock and not debuffBlock then
            foundBuff = buff
            foundBuffIndex = i
            break
        end
    end

    -- TODO:临时处理一个技能(两个buff)需要显示两个图标的情况
    if buffInstance.SkillId == "A04_1" and buffInstance.Value >= 0 then
        foundBuff = nil
    end

    if foundBuff then
        foundBuff.value = foundBuff.value + buffInstance.Value
        foundBuff.count = foundBuff.count + 1
        -- self.value = self.value + buffInstance.Value
        local buffItem = self.buffListPanel.transform:GetChild(foundBuffIndex - 1).gameObject
        local buffSpt = res.GetLuaScript(buffItem)
        buffSpt:updateValue(foundBuff.value, foundBuff.count)
    else
        local buff = {
            skillId = buffInstance.SkillId,
            value = buffInstance.Value,
            count = 1,
            debuffBlock = debuffBlock,
        }
        table.insert(self.buffList, buff)
        -- self.value = self.value + buffInstance.Value

        local count = self.buffListPanelTransform.childCount
        if count >= #self.buffList then
            local buffItem = self.buffListPanel.transform:GetChild(#self.buffList - 1).gameObject
            GameObjectHelper.FastSetActive(buffItem, true)
            res.GetLuaScript(buffItem):init(buff)
        else
            local buffItem = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/BuffItem.prefab")
            local buffItemTransform = buffItem.transform
            buffItemTransform:SetParent(self.buffListPanelTransform)
            buffItemTransform.localScale = Vector3(1, 1, 1)
            buffItemTransform.localPosition = Vector3(0, 0, 0)
            res.GetLuaScript(buffItem):init(buff)
        end
    end
    self:showValue()
end

function StateItem:removeBuff(buffInstance)
    local foundBuff = nil
    local foundBuffIndex = nil
    local debuffBlock = IsBlockDebuff(buffInstance)

    for i, buff in ipairs(self.buffList) do
        if buff.skillId == buffInstance.SkillId and (not buff.debuffBlock and not debuffBlock or buff.debuffBlock and debuffBlock) then
            foundBuff = buff
            foundBuffIndex = i
            break
        end
    end

    if foundBuff then
        foundBuff.value = foundBuff.value - buffInstance.Value
        foundBuff.count = foundBuff.count - 1
        -- self.value = self.value - buffInstance.Value

        if foundBuff.count == 0 then
            local buffItem = self.buffListPanel.transform:GetChild(foundBuffIndex - 1)
            GameObjectHelper.FastSetActive(buffItem.gameObject, false)
            buffItem:SetAsLastSibling()
            table.remove(self.buffList, foundBuffIndex)
        else
            local buffItem = self.buffListPanel.transform:GetChild(foundBuffIndex - 1).gameObject
            local buffSpt = res.GetLuaScript(buffItem)
            buffSpt:updateValue(foundBuff.value, foundBuff.count)
            if buffInstance.Value == 0 then
                buffSpt:updateBlockDebuffSignState(false)
            end
        end
    else
        dump("cannot find buff to be removed. BuffId=" .. buffInstance.BuffId)
    end
    self:showValue()
end

return StateItem
