local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")

local AssistantCoachSystemBookGrowthItemView = class(unity.base, "AssistantCoachSystemBookGrowthItemView")

function AssistantCoachSystemBookGrowthItemView:ctor()
    -- 属性名
    self.nameTxt = self.___ex.name
    -- 成长值
    self.growth = self.___ex.growth
end

function AssistantCoachSystemBookGrowthItemView:InitView(attrData)
    self.nameTxt.text = AssistantCoachConstants.GetAttrName(attrData.type, true)
    self.growth.text = tostring(attrData.growth)
end

return AssistantCoachSystemBookGrowthItemView
