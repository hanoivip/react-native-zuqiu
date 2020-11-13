local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local PeakEveryTaskView = class(unity.base)

function PeakEveryTaskView:ctor()
    self.scrollView = self.___ex.scrollView
    self.menuGroup = self.___ex.menuGroup

    DialogAnimation.Appear(self.transform, nil)
end

function PeakEveryTaskView:start()
end

function PeakEveryTaskView:InitView(model)
    self.model = model
end

function PeakEveryTaskView:Close()
    DialogAnimation.Disappear(self.transform, nil, function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)
end

function PeakEveryTaskView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function PeakEveryTaskView:InitAllTaskView()
    self.menuGroup:selectMenuItem("all")
    self.model:SetTag("all")
    local taskData = self.model:GetAllTaskData()
    self.scrollView:InitView(taskData, self.model)
end

function PeakEveryTaskView:InitChallengeTaskView()
    self.menuGroup:selectMenuItem("challenge")
    self.model:SetTag("challenge")
    local taskData = self.model:GetChallengeTaskData()
    self.scrollView:InitView(taskData, self.model)
end

function PeakEveryTaskView:InitWinTaskView()
    self.menuGroup:selectMenuItem("win")
    self.model:SetTag("win")
    local taskData = self.model:GetWinTaskData()
    self.scrollView:InitView(taskData, self.model)
end

return PeakEveryTaskView