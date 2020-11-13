local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachUpdateSuccessAttrItemView = class(unity.base, "AssistantCoachUpdateSuccessAttrItemView")

function AssistantCoachUpdateSuccessAttrItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtAttr = self.___ex.txtAttr
end

function AssistantCoachUpdateSuccessAttrItemView:start()
end

function AssistantCoachUpdateSuccessAttrItemView:InitView(acAttrData)
    self.data = acAttrData
    self.txtName.text = lang.transstr(self.data.type) .. lang.transstr("plus") .. "："
    self.txtAttr.text = lang.trans("assistant_coach_update_success_attr", self.data.initial, self.data.curr - self.data.initial)
end

return AssistantCoachUpdateSuccessAttrItemView
