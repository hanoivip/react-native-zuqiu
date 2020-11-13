local MatchLoader = require("coregame.MatchLoader")
local Timer = require('ui.common.Timer')
local GameObjectHelper = require("ui.common.GameObjectHelper")
local ActivityTimeLimitedBaseView = require("ui.scene.activity.ActivityTimeLimitedBaseView")

local PowerTargetView = class(ActivityTimeLimitedBaseView)

function PowerTargetView:ctor()
    PowerTargetView.super.ctor(self)
    self.residualTime = self.___ex.residualTime
    self.alertText = self.___ex.alertText
end

function PowerTargetView:start()
    local count = self.powerTargetModel:GetDiffCount()
    for _,v in pairs(self.diffBtns) do
        GameObjectHelper.FastSetActive(v.gameObject, false)
    end
    for i = 1, count do
        GameObjectHelper.FastSetActive(self.diffBtns["diff" .. i].gameObject, true)
        self.diffBtns["diff" .. i].___ex.btnTxt.text = lang.transstr("powerTarget_diff") .. " " .. lang.transstr("number_" .. i)
        self.diffBtns["diff" .. i]:regOnButtonClick(function()
            self:OnClick(i)
        end)
    end
end

function PowerTargetView:OnEnterScene()
    PowerTargetView.super.OnEnterScene(self)
end

function PowerTargetView:OnExitScene()
    PowerTargetView.super.OnExitScene(self)
end

function PowerTargetView:onDestroy()
    self.residualTimer:Destroy()
end

function PowerTargetView:OnClick(index, isFirst)
    if index ~= self.powerTargetModel:GetCurrDiff() or isFirst then
        self:CancelSelectButton()
        self.powerTargetModel:SetCurrDiff(index)
    end
end

function PowerTargetView:InitView(powerTargetModel)
    self.powerTargetModel = powerTargetModel

    self.residualTimer = Timer.new(powerTargetModel:GetRemainTime(), function(time)
        self.residualTime.text = lang.transstr("residual_time") .. string.convertSecondToTime(time)
    end)
end

function PowerTargetView:CancelSelectButton()
    for k, v in pairs(self.diffBtns["diff" .. self.powerTargetModel:GetCurrDiff()].___ex.selectImage) do
        v:SetActive(false)
    end
end

function PowerTargetView:OnDiffChange()
    PowerTargetView.super.OnDiffChange(self)
    self:RefreshAlertText()
end

function PowerTargetView:RefreshAlertText()
    --temporary
    self.alertText.text = lang.trans("activity_powerTargetTips") -- "通关难度五可获得球员博努奇"
end

function PowerTargetView:RequestMatch()
    clr.coroutine(function()
        local response = req.activityTimeLimitChallengeFight(self.powerTargetModel:GetSubId())
        if api.success(response) then
            local data = response.val
            MatchLoader.startMatch(response.val)
        end
    end)
end

return PowerTargetView
