local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")

local AssistantCoachLibraryGrowthItemView = class(unity.base, "AssistantCoachLibraryGrowthItemView")

function AssistantCoachLibraryGrowthItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtGrowth = self.___ex.txtGrowth
end

function AssistantCoachLibraryGrowthItemView:start()
end

function AssistantCoachLibraryGrowthItemView:InitView(acAttrData)
    self.data = acAttrData
    self.txtName.text = AssistantCoachConstants.GetAttrName(self.data.type, true)
    self.txtGrowth.text = tostring(self.data.growth)
end

return AssistantCoachLibraryGrowthItemView
