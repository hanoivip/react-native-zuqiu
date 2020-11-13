local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TimeLimitStageShopTaskItemModel = require("ui.models.activity.timeLimitStageShop.TimeLimitStageShopTaskItemModel")
local EventSystem = require("EventSystem")
local TimeLimitStageShopTaskView = class(unity.base)

function TimeLimitStageShopTaskView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.contentTrans = self.___ex.contentTrans
    self.scroll = self.___ex.scroll

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function TimeLimitStageShopTaskView:InitView(timeLimitStageShopTaskCtrlModel)
    self.model = timeLimitStageShopTaskCtrlModel
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.contentTrans)
    local taskList = self.model:GetTaskList()
    local taskRedPointState = self.model:GetTaskRedPointState()
    EventSystem.SendEvent("PlayerRefreshRedPointState", taskRedPointState)
    local taskPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitStageShop/TimeLimitStageShopTaskItem.prefab"
    for i,v in pairs(taskList) do
        local taskObj, taskSpt = res.Instantiate(taskPath)
        taskObj.transform:SetParent(self.contentTrans, false)
        local itemModel = TimeLimitStageShopTaskItemModel.new(v)
        taskSpt:InitView(itemModel, self.taskClickCallBack)
    end
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        unity.waitForNextEndOfFrame()
        self.scroll.verticalNormalizedPosition = self.scrollPos or 1
    end)
end

function TimeLimitStageShopTaskView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return TimeLimitStageShopTaskView
