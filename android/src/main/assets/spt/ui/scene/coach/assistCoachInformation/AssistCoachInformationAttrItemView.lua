local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachInformationAttrItemView = class(unity.base, "AssistCoachInformationAttrItemView")

function AssistCoachInformationAttrItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtAttr = self.___ex.txtAttr
end

function AssistCoachInformationAttrItemView:start()
end

function AssistCoachInformationAttrItemView:InitView(acAttrData)
    self.data = acAttrData
    self.txtName.text = lang.transstr(self.data.type) .. "："
    self.txtAttr.text = lang.trans("assistant_coach_info_attr", self.data.initial, self.data.growth)
end

return AssistCoachInformationAttrItemView
