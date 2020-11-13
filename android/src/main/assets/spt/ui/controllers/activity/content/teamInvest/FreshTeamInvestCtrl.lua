local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local TeamInvestCtrl = require("ui.controllers.activity.content.teamInvest.TeamInvestCtrl")

local FreshTeamInvestCtrl = class(TeamInvestCtrl)

function FreshTeamInvestCtrl:OnRedeem()
    local costDiamond = self.activityModel:GetConsumeDiamond()
    self.view:coroutine(function()
        local period = self.activityModel:GetPeriod()
        local response = req.redeemFreshTeamInvest(period)
        if api.success(response) then
            self.view:StartRolling()
            self.currentEventSystem.enabled = false
            local data = response.val
            coroutine.yield(WaitForSeconds(self.view.ROLL_TIME))
            self.activityModel:RefreshRedeemData(data)
            data.contents.d = data.contents.d + costDiamond
            local dStr = self.activityModel:ChangeInt2Str(data.contents.d)
            self.playerInfoModel.data.d = self.playerInfoModel.data.d - costDiamond
            self.view:StopRolling(dStr, data.contents)
        end
        self.view.rolling = false
    end)
end

return FreshTeamInvestCtrl