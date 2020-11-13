local Timer = require('ui.common.Timer')
local ActivityParentView = require("ui.scene.activity.content.ActivityParentView")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local OBTSerialConsumeView = class(ActivityParentView)

function OBTSerialConsumeView:ctor()
    self.activityTime = self.___ex.activityTime
    self.scrollView = self.___ex.scrollView
    self.activityDes = self.___ex.activityDes
    self.historyTxt = self.___ex.historyTxt
    self.historyBtn = self.___ex.historyBtn
end

function OBTSerialConsumeView:start()
end

function OBTSerialConsumeView:InitView(obtSerialConsumeModel)
    self.obtSerialConsumeModel = obtSerialConsumeModel
    self.historyBtn:regOnButtonClick(function ()
        local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/MultiSerialPay/HistoryDataBoard.prefab", "camera", true, true)
        dialogcomp.contentcomp:Init(self.obtSerialConsumeModel:GetHistoryTxt(), lang.transstr("serial_consume_history_title"))
    end)
end

function OBTSerialConsumeView:RefreshContent()
    self.historyTxt.text = lang.trans("serial_consume_history", self.obtSerialConsumeModel:GetCostByIndex(self.obtSerialConsumeModel:GetTodayIndex()))
    self.activityDes.text = self.obtSerialConsumeModel:GetActivityDesc()
    self.activityTime.text = lang.trans("cumulative_pay_time", string.convertSecondToMonth(self.obtSerialConsumeModel:GetStartTime()), 
                            string.convertSecondToMonth(self.obtSerialConsumeModel:GetEndTime()))
    self.scrollView:InitView(self.obtSerialConsumeModel)
end

function OBTSerialConsumeView:onDestroy()
end

return OBTSerialConsumeView