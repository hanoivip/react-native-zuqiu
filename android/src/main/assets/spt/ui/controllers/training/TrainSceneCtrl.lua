local BaseCtrl = require("ui.controllers.BaseCtrl")

local TrainSceneCtrl = class(BaseCtrl, "TrainSceneCtrl")

TrainSceneCtrl.viewPath = "Assets/CapstonesRes/Game/MatchScenes/Training/Training.unity"

function TrainSceneCtrl:Init()
end

function TrainSceneCtrl:Refresh()
    TrainSceneCtrl.super.Refresh(self)
    -- self.view:InitView()
end

function TrainSceneCtrl:GetStatusData()
    return nil
end

return TrainSceneCtrl
