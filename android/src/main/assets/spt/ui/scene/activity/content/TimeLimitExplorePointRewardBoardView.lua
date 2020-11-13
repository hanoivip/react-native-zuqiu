local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local TimeLimitExplorePointRewardBoardView = class(unity.base)

function TimeLimitExplorePointRewardBoardView:ctor()
    self.scrollView = self.___ex.scrollView
    self.btnClose = self.___ex.btnClose
    DialogAnimation.Appear(self.transform, nil)
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
end

function TimeLimitExplorePointRewardBoardView:InitView(model, func)
    self.model = model
    self.scrollView.onItemButtonClick = func
    self.scrollView:InitView(self.model)
end

function TimeLimitExplorePointRewardBoardView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return TimeLimitExplorePointRewardBoardView