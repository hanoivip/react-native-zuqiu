local GameObjectHelper = require("ui.common.GameObjectHelper")

local StageConditionView = class(unity.base)

function StageConditionView:ctor()
    -- 普通条件文本
    self.normalConditionText = self.___ex.normalConditionText
    -- 完成图标
    self.doneIcon = self.___ex.doneIcon
end

function StageConditionView:InitView(conditionText, isDone)
    self.normalConditionText.text = conditionText
    self.doneIcon:SetActive(isDone)
end

return StageConditionView
