local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TeamInvestType = require("ui.models.activity.teamInvest.TeamInvestType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")

local TeamInvestView = class(ActivityParentView)

function TeamInvestView:ctor()
    self.allSlot = {self.___ex.slot.s1, self.___ex.slot.s2, self.___ex.slot.s3, self.___ex.slot.s4, self.___ex.slot.s5}
    self.rollBtn = self.___ex.rollBtn
    self.timeTxt = self.___ex.timeTxt
    self.endTipsGo = self.___ex.endTipsGo
    self.tipsGo = self.___ex.tipsGo
    self.maxDiamondTxt = self.___ex.maxDiamondTxt
    self.consumeDiamondTxt = self.___ex.consumeDiamondTxt
    self.vipTxt = self.___ex.vipTxt
    self.descTxt = self.___ex.descTxt
    self.title = self.___ex.title
    self.roolAnimator = self.___ex.roolAnimator

    self.rolling = false
    self.ROLL_TIME = 2 -- 转动时间
    self.STOP_TIME = 1 -- 停止时间
    self.STOP_WAITING_TIME = 1 -- 每个数字之间的等待时间
    self.ROLL_MAX_COLUMN = 5 -- 转盘的数字个数
    self.currentEventSystem = EventSystems.EventSystem.current
end

function TeamInvestView:start()
    self.rollBtn:regOnButtonClick(function()
        if type(self.onRollClick) == "function" and (not self.rolling) then
            self.onRollClick()
        end
    end)
end

function TeamInvestView:InitView(activityModel)
    self.activityModel = activityModel
    self:RefreshContent()
end

function TeamInvestView:RefreshContent()
    local dNeed = self.activityModel:GetDiamondNeed()
    local maxDiamond = self.activityModel:GetMaxDiamond()
    local consumeDiamond = self.activityModel:GetConsumeDiamond()
    local vipLvl = self.activityModel:GetNeedVIPLevel()
    local maxVipLvl = self.activityModel:GetMaxVIPLevel()
    local desc = self.activityModel:GetDesc()
    self:ScrollToNumberImmediately(dNeed)
    self:RefreshTimeAndTitle()
    if maxDiamond and consumeDiamond then
        GameObjectHelper.FastSetActive(self.endTipsGo, false)
        GameObjectHelper.FastSetActive(self.tipsGo, true)
        self.maxDiamondTxt.text = tostring(maxDiamond)
        self.consumeDiamondTxt.text = tostring(consumeDiamond)
        self.vipTxt.text = "VIP" .. vipLvl
    else
        GameObjectHelper.FastSetActive(self.endTipsGo, true)
        GameObjectHelper.FastSetActive(self.tipsGo, false)
        self.vipTxt.text = "VIP" .. maxVipLvl
    end
    self.descTxt.text = desc
end

function TeamInvestView:ScrollToNumberImmediately(intNumber)
    local dStr = self.activityModel:ChangeInt2Str(intNumber)
    for k,v in pairs(self.allSlot) do
        s = dStr:sub(k, k)
        v:Init(tonumber(s))
    end
end

function TeamInvestView:StartRolling()
    for i,v in ipairs(self.allSlot) do
        if not self.rolling then
            v.acceleration = i * 0.5
            v:StartRolling()
        end
    end
    self.rolling = true
end

function TeamInvestView:StopRolling(dStr, contents)
    local s = dStr:sub(self.ROLL_MAX_COLUMN, self.ROLL_MAX_COLUMN)
    coroutine.yield(WaitForSeconds(self.STOP_WAITING_TIME))
    self.allSlot[self.ROLL_MAX_COLUMN]:Stop(tonumber(s), function() self:OnStop(self.ROLL_MAX_COLUMN, dStr, contents) end)
end

function TeamInvestView:OnStop(index, dStr, contents)
    if index > 1 then
        index = index - 1
        local s = dStr:sub(index, index)
        self.allSlot[index]:Stop(tonumber(s), function() self:OnStop(index, dStr, contents) end)
    else
        self:coroutine(function()
            coroutine.yield(WaitForSeconds(self.STOP_TIME))
            CongratulationsPageCtrl.new(contents)
            self.currentEventSystem.enabled = true
            self:RefreshContent()
        end)
    end
end

function TeamInvestView:RefreshTimeAndTitle()
    local startTime = self.activityModel:GetStartTime()
    local endTime = self.activityModel:GetEndTime()
    local teamInvestType = self.activityModel:GetTeamInvestType()
    if teamInvestType == TeamInvestType.TIME_LIMIT then
        local timeStr = lang.trans("cumulative_pay_time", startTime, endTime)
        self.timeTxt.text = timeStr
        self.title.text = lang.trans("time_limit_team_invest")
    else
        if self.residualTimer ~= nil then
            self.residualTimer:Destroy()
        end
        local remainTime = self.activityModel:GetRemainTime()
        self.timeTxt.text = lang.trans("recruitReward_activity_desc11")
        self.residualTimer = Timer.new(remainTime, function(time)
            if time > 1.5 then
                self.timeTxt.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
            else
                self.timeTxt.text = lang.trans("time_limit_growthPlan_desc5")
            end
        end)
        self.title.text = lang.trans("fresh_team_invest")
    end
end

function TeamInvestView:onDestroy()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

function TeamInvestView:PlayAnimRoll()
    self.roolAnimator:Play("PullLevelAnimation")  --Lua assist checked flag
end

function TeamInvestView:OnExitScene()
    TeamInvestView.super.OnExitScene(self)
    for k,v in pairs(self.allSlot) do
        v:StopAllRollingCoroutine()
    end
end

return TeamInvestView
