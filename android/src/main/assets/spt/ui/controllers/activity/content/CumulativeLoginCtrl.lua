local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local CumulativeLoginCtrl = class(ActivityContentBaseCtrl)

function CumulativeLoginCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)

    self.view.clickGetReward = function() self:ClickGetReward() end
end

function CumulativeLoginCtrl:ClickGetReward()
    clr.coroutine(function ()
        local response = req.activityCumulativeLogin(self.activityModel:GetActivityType(), 
                            self.activityModel:GetActivitySubId(), nil, nil, true)
        if api.success(response) then
            local data = response.val
            CongratulationsPageCtrl.new(data.contents)
        end

        self.view:DisabledRewardButton()
    end)
end

return CumulativeLoginCtrl
