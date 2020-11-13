local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local PasterListView = class(unity.base)
local GameObjectHelper = require("ui.common.GameObjectHelper")

function PasterListView:ctor()
    self.close = self.___ex.close
    self.scrollView = self.___ex.scrollView
    self.filterBtn = self.___ex.filterBtn
end

function PasterListView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
    self:OnLeaveCurrentScene()
end

function PasterListView:OnLeaveCurrentScene()
    if self.leaveCurrentScene then
        self.leaveCurrentScene()
    end
end

function PasterListView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

    self.filterBtn:regOnButtonClick(function()
          self:OnFilterBtnClick()
    end)
end

function PasterListView:OnFilterBtnClick()
    if self.clickFilterBtn then
        self.clickFilterBtn()
    end
end

return PasterListView
