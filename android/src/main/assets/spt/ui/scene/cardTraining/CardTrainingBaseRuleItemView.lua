local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local CardTrainingBaseRuleItemView = class(unity.base)

function CardTrainingBaseRuleItemView:ctor()
    self.title = self.___ex.title
    self.mTitles = self.___ex.mTitles
    self.mValues = self.___ex.mValues
    self.skillObjs = self.___ex.skillObjs
    self.skillImgs = self.___ex.skillImgs
end

function CardTrainingBaseRuleItemView:InitView(value)
    self:InvisibleSkillArea()
    for k, v in pairs(value.task) do
        k = tostring(k)
        self.mTitles[k].text = lang.transstr("card_training_rule_task_title") .. lang.transstr("number_" .. k)
        if v.skills then
            self:InitSkillArea(v.skills, k)
        else
            GameObjectHelper.FastSetActive(self.skillObjs["1"], true)
            GameObjectHelper.FastSetActive(self.skillImgs["1"].gameObject, false)
            self.mValues[k].text = v.value
        end
    end
    self.title.text = value.title
end

function CardTrainingBaseRuleItemView:InvisibleSkillArea()
    for i = 1, 2 do
        GameObjectHelper.FastSetActive(self.skillObjs[tostring(i)], false)
    end
end

function CardTrainingBaseRuleItemView:InitSkillArea(skills, descStartIndex)
    local descIndex = tonumber(descStartIndex)
    for i = 1, #skills do
        GameObjectHelper.FastSetActive(self.skillObjs[tostring(i)], true)
        GameObjectHelper.FastSetActive(self.skillImgs[tostring(i)].gameObject, true)
        -- icon
        self.skillImgs[tostring(i)].overrideSprite = AssetFinder.GetSkillIcon(skills[i].iconData)
        -- 描述
        self.mValues[tostring(descIndex)].text = skills[i].value
        descIndex = descIndex + 1
    end
end

return CardTrainingBaseRuleItemView
