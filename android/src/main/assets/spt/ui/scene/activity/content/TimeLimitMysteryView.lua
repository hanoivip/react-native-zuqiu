local DialogManager = require("ui.control.manager.DialogManager")
local StoreCtrl = require("ui.controllers.store.StoreCtrl")

local TimeLimitMysteryView = class(unity.base)

function TimeLimitMysteryView:ctor()
    -- 活动说明
    self.activityDesc = self.___ex.activityDesc
    -- 活动时间
    self.activityTime = self.___ex.activityTime
    -- 前往联赛按钮
    self.goToBtn = self.___ex.goToBtn
    -- 数据模型
    self.brainTraingModel = nil
end

function TimeLimitMysteryView:InitView(brainTraingModel)
    self.brainTraingModel = brainTraingModel
    self:BuildView()
end

function TimeLimitMysteryView:start()
    self:BindAll()
end

function TimeLimitMysteryView:BindAll()
    self.goToBtn:regOnButtonClick(function ()
        local StoreModel = require("ui.models.store.StoreModel")
        res.PushScene("ui.controllers.store.StoreCtrl", StoreModel.MenuTags.Agent)
    end)
end

function TimeLimitMysteryView:BuildView()
    self.activityDesc.text = self.brainTraingModel:GetDesc()
    local startTime = self.brainTraingModel:GetStartTime()
    local endTime = self.brainTraingModel:GetEndTime()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.formatTimestampNoYear(startTime), string.formatTimestampNoYear(endTime))
end

return TimeLimitMysteryView