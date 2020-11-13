local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistantCoachUpdateAttrItemView = class(unity.base, "AssistantCoachUpdateAttrItemView")

function AssistantCoachUpdateAttrItemView:ctor()
    self.txtName = self.___ex.txtName
    self.txtAttr = self.___ex.txtAttr
end

function AssistantCoachUpdateAttrItemView:start()
end

function AssistantCoachUpdateAttrItemView:InitView(acAttrData, nextLvl)
    self.data = acAttrData
    nextLvl = nextLvl or false
    self.txtName.text = lang.transstr(self.data.type) .. lang.transstr("plus") .. "："
    self.txtAttr.text = lang.trans("assistant_coach_update_attr", self.data.curr + (nextLvl and self.data.growth or 0))
end

return AssistantCoachUpdateAttrItemView
