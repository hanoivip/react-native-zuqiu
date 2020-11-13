local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local Shadow = clr.UnityEngine.UI.Shadow
local Color = clr.UnityEngine.Color
local UserStrengthCtrl = require("ui.controllers.user.UserStrengthCtrl")

local RewardDoubleView = class(ActivityParentView)

function RewardDoubleView:ctor()
    self.activityDes = self.___ex.activityDes
    self.timeTxt = self.___ex.timeTxt
    self.buyStrengthBtn = self.___ex.buyStrengthBtn
    self.buyTimeTxt = self.___ex.buyTimeTxt
    self.finish = self.___ex.finish
    self.time = self.___ex.time
    self.normal = self.___ex.normal
    self.selected = self.___ex.selected
    self.banner = self.___ex.banner
end

function RewardDoubleView:start()
    EventSystem.AddEvent("Refresh_Strength", self, self.RefreshStrength)
end

function RewardDoubleView:InitView(rewardDoubleModel)
    self.rewardDoubleModel = rewardDoubleModel
    self.strengthTime = rewardDoubleModel:GetBuyTime()
    self.activityDes.text = rewardDoubleModel:GetActivityDesc()
    self.buyTimeTxt.text = lang.trans("reward_double_tip", rewardDoubleModel:GetBuyTime())
    self.timeTxt.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.rewardDoubleModel:GetStartTime()), 
                            string.convertSecondToMonth(self.rewardDoubleModel:GetEndTime()))

    self.buyStrengthBtn:regOnButtonClick(function ()
        UserStrengthCtrl.new(true)
    end)

    self:InitItem(rewardDoubleModel:GetCondition())
end

function RewardDoubleView:InitItem()
    local condition = self.rewardDoubleModel:GetCondition()
    GameObjectHelper.FastSetActive(self.finish.f1, tonumber(self.strengthTime) >= tonumber(condition[1]))
    if tonumber(self.strengthTime) >= tonumber(condition[1]) then
        self.time.t1.text = "<color=#775008>" .. "x" .. condition[1] .. "</color>"
        self.time.t1:GetComponent(Shadow).effectColor = Color(1,1,1,1)
    else
        self.time.t1.text = "x" .. condition[1]
        self.time.t1:GetComponent(Shadow).effectColor = Color(0,0,0,1)
    end
    
    self.normal.n1.enabled = tonumber(self.strengthTime) < tonumber(condition[1])
    self.selected.s1.enabled = tonumber(self.strengthTime) >= tonumber(condition[1])
    self.banner.b1.enabled = tonumber(self.strengthTime) >= tonumber(condition[1])

    GameObjectHelper.FastSetActive(self.finish.f2, tonumber(self.strengthTime) >= tonumber(condition[2]))
    if tonumber(self.strengthTime) >= tonumber(condition[2]) then
        self.time.t2.text = "<color=#775008>" .. "x" .. condition[2] .. "</color>"
        self.time.t2:GetComponent(Shadow).effectColor = Color(1,1,1,1)
    else
        self.time.t2.text = "x" .. condition[2]
        self.time.t2:GetComponent(Shadow).effectColor = Color(0,0,0,1)
    end
    self.normal.n2.enabled = tonumber(self.strengthTime) < tonumber(condition[2])
    self.selected.s2.enabled = tonumber(self.strengthTime) >= tonumber(condition[2])
    self.banner.b2.enabled = tonumber(self.strengthTime) >= tonumber(condition[2])

    GameObjectHelper.FastSetActive(self.finish.f3, tonumber(self.strengthTime) >= tonumber(condition[3]))
    if tonumber(self.strengthTime) >= tonumber(condition[3]) then
        self.time.t3.text = "<color=#775008>" .. "x" .. condition[3] .. "</color>"
        self.time.t3:GetComponent(Shadow).effectColor = Color(1,1,1,1)
    else
        self.time.t3.text = "x" .. condition[3]
        self.time.t3:GetComponent(Shadow).effectColor = Color(0,0,0,1)
    end
    self.normal.n3.enabled = tonumber(self.strengthTime) < tonumber(condition[3])
    self.selected.s3.enabled = tonumber(self.strengthTime) >= tonumber(condition[3])
    self.banner.b3.enabled = tonumber(self.strengthTime) >= tonumber(condition[3])
end

function RewardDoubleView:RefreshStrength()
    self.strengthTime = tonumber(self.strengthTime) + 1
    self.buyTimeTxt.text = lang.trans("reward_double_tip", tostring(self.strengthTime))

    self:InitItem()
end

function RewardDoubleView:onDestroy()
    EventSystem.RemoveEvent("Refresh_Strength", self, self.RefreshStrength)
end

return RewardDoubleView
