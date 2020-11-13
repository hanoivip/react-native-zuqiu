local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local CumulativePayView = class(ActivityParentView)

function CumulativePayView:ctor()
    self.residualTime = self.___ex.residualTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.goPayBtn = self.___ex.goPayBtn
    self.rewardLeftBtn = self.___ex.rewardLeftBtn
    self.rewardRightBtn = self.___ex.rewardRightBtn
    self.rewardScroll = self.___ex.rewardScroll
    self.leftArrowGo = self.___ex.leftArrowGo
    self.rightArrowGo = self.___ex.rightArrowGo
    self.residualTimer = nil
end

function CumulativePayView:start()
     self.rewardLeftBtn:regOnButtonClick(function()
        self:OnRewardLeftBtnClick()
    end)

    self.rewardRightBtn:regOnButtonClick(function()
        self:OnRewardRightBtnClick()
    end)
end

function CumulativePayView:OnRewardLeftBtnClick()
    self.rewardScroll:scrollToPreviousGroup()
end

function CumulativePayView:OnRewardRightBtnClick()
    self.rewardScroll:scrollToNextGroup()
end

function CumulativePayView:InitView(cumulativePayModel)
    self.cumulativePayModel = cumulativePayModel
    self.goPayBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl")
    end)
    self:RefreshContent()
end

function CumulativePayView:RefreshContent()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
    self.activityDes.text = self.cumulativePayModel:GetActivityDesc()
    self.timeTxt.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.cumulativePayModel:GetStartTime()),
                            string.convertSecondToMonth(self.cumulativePayModel:GetEndTime()))
    self.scrollView:InitView(self.cumulativePayModel)
    self:ShowDisplayReward()
end

function CumulativePayView:ShowDisplayReward()
    local displayReward = self.cumulativePayModel:GetDisplayReward()
    self.rewardCount = #displayReward
    self.rewardScroll:InitView(displayReward)
    self.rewardScroll:regOnItemIndexChanged(function(index) self:OnRewardScrollChanged(index) end)
end

function CumulativePayView:OnRewardScrollChanged(index)
    local leftArrowState, rightArrowState = true, true
    if self.rewardCount <= 4 then
        leftArrowState = false
        rightArrowState = false
    else
        if index == 1 then
            leftArrowState = false
        end
        if index >= self.rewardCount - 3 then
            rightArrowState = false
        end
    end
    GameObjectHelper.FastSetActive(self.leftArrowGo, leftArrowState)
    GameObjectHelper.FastSetActive(self.rightArrowGo, rightArrowState)
end

function CumulativePayView:OnEnterScene()
    self.super.OnEnterScene(self)
end

function CumulativePayView:OnExitScene()
    self.super.OnExitScene(self)
end

function CumulativePayView:OnRefresh()
end

function CumulativePayView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return CumulativePayView