local MatchLoader = require("coregame.MatchLoader")
local Timer = require('ui.common.Timer')
local ActivityTimeLimitedBaseView = require("ui.scene.activity.ActivityTimeLimitedBaseView")

local ConfederationsCupView = class(ActivityTimeLimitedBaseView)

function ConfederationsCupView:ctor()
    ConfederationsCupView.super.ctor(self)
    self.timeLimitTime = self.___ex.timeLimitTime
end

function ConfederationsCupView:start()
    for i = 1, 8 do
        local nationalname = "confederations_cup_" .. i
        self.diffBtns["diff" .. i].___ex.btnTxt.text = lang.transstr(nationalname)
        self.diffBtns["diff" .. i]:regOnButtonClick(function()
            self:OnClick(i)
        end)
    end
end

function ConfederationsCupView:InitView(powerTargetModel)
    self.powerTargetModel = powerTargetModel
    self.timeLimitTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.powerTargetModel:GetBeginTime()), string.convertSecondToMonth(self.powerTargetModel:GetEndTime()))
end

function ConfederationsCupView:OnEnterScene()
    ConfederationsCupView.super.OnEnterScene(self)
end

function ConfederationsCupView:OnExitScene()
    ConfederationsCupView.super.OnExitScene(self)
end

function ConfederationsCupView:OnClick(index, isFirst)
    if index ~= self.powerTargetModel:GetCurrDiff() or isFirst then
        self:CancelSelectButton()
        self.powerTargetModel:SetCurrDiff(index)
    end
end

function ConfederationsCupView:CancelSelectButton()
    for k, v in pairs(self.diffBtns["diff" .. self.powerTargetModel:GetCurrDiff()].___ex.selectImage) do
        v:SetActive(false)
    end
end

function ConfederationsCupView:RequestMatch()
    clr.coroutine(function()
        local response = req.activityConfederationsCupFight(self.powerTargetModel:GetSubId())
        if api.success(response) then
            local data = response.val       
            MatchLoader.startMatch(response.val)
        end
    end)
end

return ConfederationsCupView
