local GameObjectHelper = require("ui.common.GameObjectHelper")

local AssistCoachJoinEffectAttrItemView = class(unity.base, "AssistCoachJoinEffectAttrItemView")

function AssistCoachJoinEffectAttrItemView:ctor()
    self.txtName = self.___ex.txtName
end

function AssistCoachJoinEffectAttrItemView:start()
end

function AssistCoachJoinEffectAttrItemView:InitView(assistCoachInfoModel)
    self.aciModel = assistCoachInfoModel
    if self.aciModel then
        self.txtName.text = string.gsub(self.aciModel:GetName(),":","-")
    else
        self.txtName.text = ""
    end
end

return AssistCoachJoinEffectAttrItemView
