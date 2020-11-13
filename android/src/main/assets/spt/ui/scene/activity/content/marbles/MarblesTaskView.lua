local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local MarblesTaskItemModel = require("ui.models.activity.marbles.MarblesTaskItemModel")
local EventSystem = require("EventSystem")
local MarblesTaskView = class(unity.base)

function MarblesTaskView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.contentTrans = self.___ex.contentTrans
    self.scroll = self.___ex.scroll

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function MarblesTaskView:InitView(marblesTaskViewModel)
    self.model = marblesTaskViewModel
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.contentTrans)
    local taskList = self.model:GetTaskList()
    local taskRedPointState = self.model:GetTaskRedPointState()
    EventSystem.SendEvent("PlayerRefreshRedPointState", taskRedPointState)
    local taskPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesTaskItem.prefab"
    for i,v in pairs(taskList) do
        local taskObj, taskSpt = res.Instantiate(taskPath)
        taskObj.transform:SetParent(self.contentTrans, false)
        local itemModel = MarblesTaskItemModel.new(v)
        taskSpt:InitView(itemModel, self.taskClickCallBack)
    end
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        unity.waitForNextEndOfFrame()
        self.scroll.verticalNormalizedPosition = self.scrollPos or 1
    end)
end

function MarblesTaskView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return MarblesTaskView
