local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local OBTDailyLoginCtrl = class(ActivityContentBaseCtrl)

function OBTDailyLoginCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:InitView(self.activityModel)
    self.view.clickGetReward = function() self:ClickGetReward() end
end

function OBTDailyLoginCtrl:ClickGetReward()
    clr.coroutine(function ()
        local response = req.activityCumulativeLogin(self.activityModel:GetActivityType(), 
                            self.activityModel:GetActivitySubId(), nil, nil)
        if api.success(response) then
            local data = response.val
            if data.contents ~= nil then  
                CongratulationsPageCtrl.new(data.contents)
                self.view:DisabledRewardButton()
            end
        end
    end)
end

return OBTDailyLoginCtrl
