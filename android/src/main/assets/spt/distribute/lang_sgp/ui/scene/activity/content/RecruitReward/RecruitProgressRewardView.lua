local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local RecruitProgressRewardView = class(unity.base)

function RecruitProgressRewardView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.title = self.___ex.title
    self.rewardScroll = self.___ex.rewardScroll

    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function RecruitProgressRewardView:InitView(progressDataList, recruitRewardModel)
    self.rewardScroll:InitView(progressDataList, recruitRewardModel)
end

function RecruitProgressRewardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return RecruitProgressRewardView