local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachJoinAttrItemView = class(unity.base, "AssistCoachJoinAttrItemView")

function AssistCoachJoinAttrItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtAttr = self.___ex.txtAttr
end

function AssistCoachJoinAttrItemView:start()
end

function AssistCoachJoinAttrItemView:InitView(acAttrData)
    self.data = acAttrData
    self.txtName.text = "<color=#ced1d2ff>" .. lang.transstr(self.data.type) .. "：</color><color=#e6d67eff>" .. tostring(self.data.initial) .. "</color>"
    self.txtAttr.text = lang.trans("assistant_coach_join_attr_growth", self.data.growth)
end

return AssistCoachJoinAttrItemView
