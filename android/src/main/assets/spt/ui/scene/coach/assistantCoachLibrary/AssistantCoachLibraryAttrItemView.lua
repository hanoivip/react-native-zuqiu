local AssistantCoachConstants = require("ui.models.coach.assistantSystem.AssistantCoachConstants")

local AssistantCoachLibraryAttrItemView = class(unity.base, "AssistantCoachLibraryAttrItemView")

function AssistantCoachLibraryAttrItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtAttr = self.___ex.txtAttr
end

function AssistantCoachLibraryAttrItemView:start()
end

function AssistantCoachLibraryAttrItemView:InitView(acAttrData)
    self.data = acAttrData
    self.txtName.text = AssistantCoachConstants.GetAttrName(self.data.type, true)
    if self.data.curr - self.data.initial > 0 then
        self.txtAttr.text = lang.trans("assistant_coach_library_attr", self.data.initial, self.data.curr - self.data.initial)
    else
        self.txtAttr.text = "<color=#fffb73ff>" .. tostring(self.data.initial) .. "</color>"
    end
end

return AssistantCoachLibraryAttrItemView
