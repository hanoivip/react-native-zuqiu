local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerTreasureTaskItemModel = require("ui.models.activity.playerTreasure.PlayerTreasureTaskItemModel")
local EventSystem = require("EventSystem")
local PlayerTreasureTaskView = class(unity.base)

function PlayerTreasureTaskView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.contentTrans = self.___ex.contentTrans
    self.scroll = self.___ex.scroll

    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function PlayerTreasureTaskView:InitView(playerTreasureTaskModel)
    DialogAnimation.Appear(self.transform, nil)
    res.ClearChildren(self.contentTrans)
    local taskList = playerTreasureTaskModel:GetTaskList()
    local taskRedPointState = playerTreasureTaskModel:GetTaskRedPointState()
    EventSystem.SendEvent("PlayerRefreshRedPointState", taskRedPointState)
    local taskPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureTaskItem.prefab"
    for i,v in pairs(taskList) do
        local taskObj, taskSpt = res.Instantiate(taskPath)
        taskObj.transform:SetParent(self.contentTrans, false)
        local playerTreasureTaskItemModel = PlayerTreasureTaskItemModel.new(v)
        taskSpt:InitView(playerTreasureTaskItemModel, self.taskClickCallBack)
    end
    self:coroutine(function()
        unity.waitForNextEndOfFrame()
        unity.waitForNextEndOfFrame()
        self.scroll.verticalNormalizedPosition = self.scrollPos or 1
    end)
end

function PlayerTreasureTaskView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return PlayerTreasureTaskView
