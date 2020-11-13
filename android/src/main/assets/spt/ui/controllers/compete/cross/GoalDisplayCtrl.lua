local BaseCtrl = require("ui.controllers.BaseCtrl")
local GoalDisplayCtrl = class(BaseCtrl)

GoalDisplayCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/GoalDisPlay.prefab"

GoalDisplayCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function GoalDisplayCtrl:Refresh(teamData, teamList)
    self.teamData = teamData
    self.teamList = teamList
    self.view:InitView(teamData, teamList)
end

function GoalDisplayCtrl:OnExitScene()

end

function GoalDisplayCtrl:GetStatusData()
    return self.teamData, self.teamList
end

return GoalDisplayCtrl
