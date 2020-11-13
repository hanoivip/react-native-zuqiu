local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local CareerRaceView = class(unity.base)

function CareerRaceView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.rewardScroll = self.___ex.rewardScroll
    self.countDownText = self.___ex.countDownText

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
        EventSystem.SendEvent("GuideManager.MainGuideEnd")
    end)
end

function CareerRaceView:InitView(activityModel)
    self.activityModel = activityModel
    local rewardList = self.activityModel:GetRewardList()
    local rewardDataList = self:DataListPretreatment(rewardList)

    self.rewardScroll:InitView(rewardDataList, self.activityModel)
end

function CareerRaceView:DataListPretreatment(rewardList)
    for k, v in pairs(rewardList) do
        local count = 0
        for key, value in pairs(v.contents) do
            if type(value) == "table" then
                for kk, vv in pairs(value) do
                    count = count + 1
                end
            else
                count = count + 1
            end
        end
        v.contentsCount = count
    end

    return rewardList
end

function CareerRaceView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return CareerRaceView