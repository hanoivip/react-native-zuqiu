local DialogManager = require("ui.control.manager.DialogManager")
local LevelLimit = require("data.LevelLimit")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")

local TimeLimitBrainTraingView = class(unity.base)

function TimeLimitBrainTraingView:ctor()
    -- 活动说明
    self.activityDesc = self.___ex.activityDesc
    -- 活动时间
    self.activityTime = self.___ex.activityTime
    -- 前往联赛按钮
    self.goToBtn = self.___ex.goToBtn
    -- 数据模型
    self.brainTraingModel = nil
end

function TimeLimitBrainTraingView:InitView(brainTraingModel)
    self.brainTraingModel = brainTraingModel
    self:BuildView()
end

function TimeLimitBrainTraingView:start()
    self:BindAll()
end

function TimeLimitBrainTraingView:BindAll()
    self.goToBtn:regOnButtonClick(function ()
        local needLvl = LevelLimit['littleGame'] and LevelLimit['littleGame'].playerLevel
        local playerInfoModel = PlayerInfoModel:new()
        local playerLevel = playerInfoModel:GetLevel()
        if tonumber(playerLevel) >= tonumber(needLvl) then 
            res.PushScene("ui.controllers.training.TrainCtrl")
        else
            DialogManager.ShowToast(lang.trans("train_level_not_enough", needLvl))
        end
    end)
end

function TimeLimitBrainTraingView:BuildView()
    self.activityDesc.text = self.brainTraingModel:GetDesc()
    local startTime = self.brainTraingModel:GetStartTime()
    local endTime = self.brainTraingModel:GetEndTime()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))
end

return TimeLimitBrainTraingView