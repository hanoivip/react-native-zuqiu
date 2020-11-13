local BaseCtrl = require("ui.controllers.BaseCtrl")

local StagePageCtrl = class(BaseCtrl)
StagePageCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Quest/StagePage.prefab"

function StagePageCtrl:ctor(view, stageInfoModel)
    self.stageInfoModel = stageInfoModel
    self:Init()
end

function StagePageCtrl:Init()
    EventSystem.SendEvent("StagePage_InitView", self.stageInfoModel)
    EventSystem.SendEvent("StagePage.EnterView")
end

function StagePageCtrl:Refresh()
    EventSystem.SendEvent("StagePage.RefreshView")
end

function StagePageCtrl:GetStatusData()

end

return StagePageCtrl