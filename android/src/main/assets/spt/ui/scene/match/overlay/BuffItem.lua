local UnityEngine = clr.UnityEngine
local Sprite = UnityEngine.Sprite
local Color = UnityEngine.Color

local GameObjectHelper = require("ui.common.GameObjectHelper")
local AssetFinder = require("ui.common.AssetFinder")
local BuffNeedShowZeroSkillID = require("ui.scene.match.overlay.BuffNeedShowZeroSkillID")

local Green = Color(144.0 / 255, 243.0 / 255, 38.0 / 255)
local Red = Color(1, 42.0 / 255, 78.0 / 255)

local BuffItem = class(unity.base)

function BuffItem:ctor()
    self.image = self.___ex.image
    self.valueText = self.___ex.valueText
    self.count = self.___ex.count
    self.countText = self.___ex.countText
    self.isShowZero = false
    self.blockDebuffSign = self.___ex.blockDebuffSign
end

-- {
--     skillId = "B01",
--     value = 1.2,
--     count = 1
-- }

function BuffItem:init(data)
    self.isShowZero = false
    for i, skillId in ipairs(BuffNeedShowZeroSkillID) do
        if data.skillId == skillId then
            self.isShowZero = true
            break
        end
    end

    local skillIcon = AssetFinder.GetMatchSkillIcon(data.skillId)
    self.image.overrideSprite = skillIcon
    self:showValue(data.value)
    self:showCount(1)
    GameObjectHelper.FastSetActive(self.blockDebuffSign, data.debuffBlock)
end

function BuffItem:showValue(value)
    local absValue = math.round(math.abs(value) * 100)
    if value ~= 0 then
        if value < 0 then
            self.valueText.text = "-" .. absValue .. "%"
            self.valueText.color = Red
        else
            self.valueText.text = "+" .. absValue .. "%"
            self.valueText.color = Green
        end
    else
        if self.isShowZero then
            self.valueText.text = "+0%"
            self.valueText.color = Green
        else
            self.valueText.text = ""
        end
    end
end

function BuffItem:showCount(count)
    if count == 1 then
        GameObjectHelper.FastSetActive(self.count, false)
    else
        GameObjectHelper.FastSetActive(self.count, true)
        self.countText.text = tostring(count)
    end
end

function BuffItem:updateValue(value, count)
    self:showValue(value)
    self:showCount(count)
end

function BuffItem:updateBlockDebuffSignState(isShow)
    GameObjectHelper.FastSetActive(self.blockDebuffSign, isShow)
end

return BuffItem
