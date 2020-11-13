local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamPlayerHistoryDetailCtrl = class(BaseCtrl)

DreamPlayerHistoryDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamTeamHistory/DreamPlayerHistoryDetail.prefab"

function DreamPlayerHistoryDetailCtrl:Init(data)
    self.data = data
end

function DreamPlayerHistoryDetailCtrl:Refresh(data)
    self.view:InitView(data)
end

function DreamPlayerHistoryDetailCtrl:GetStatusData()
    return self.data
end

return DreamPlayerHistoryDetailCtrl
