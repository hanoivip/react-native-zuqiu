local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")

local AssistantCoachSystemBookAttrItemView = class(unity.base, "AssistantCoachSystemBookAttrItemView")

function AssistantCoachSystemBookAttrItemView:ctor()
    -- 属性名
    self.nameTxt = self.___ex.name
    -- 初始值
    self.init = self.___ex.init
    -- 总成长值
    self.plus = self.___ex.plus
end

function AssistantCoachSystemBookAttrItemView:InitView(attrData)
    self.nameTxt.text = AssistantCoachConstants.GetAttrName(attrData.type, true)
    self.init.text = tostring(attrData.initial)
    local plus = attrData.curr - attrData.initial
    self.plus.text = "+" .. tostring(plus)
end

return AssistantCoachSystemBookAttrItemView
