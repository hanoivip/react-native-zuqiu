local BaseCtrl = require("ui.controllers.BaseCtrl")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")

local SimpleIntroduceCtrl = class(BaseCtrl, "SimpleIntroduceCtrl")

SimpleIntroduceCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Common/SimpleIntroduce/SimpleIntroduce.prefab"

SimpleIntroduceCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

-- id必须与descID的配置匹配
-- local simpleIntroduceModel = SimpleIntroduceModel.new(id, descID)
-- res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)

function SimpleIntroduceCtrl:ctor()
    SimpleIntroduceCtrl.super.ctor(self)
end

function SimpleIntroduceCtrl:Init(simpleIntroduceModel)
end

function SimpleIntroduceCtrl:Refresh(simpleIntroduceModel)
    SimpleIntroduceCtrl.super.Refresh(self)
    if simpleIntroduceModel == nil then
        self.model = SimpleIntroduceModel.new()
    else
        self.model = simpleIntroduceModel
    end
    self.view:InitView(self.model)
end

return SimpleIntroduceCtrl
