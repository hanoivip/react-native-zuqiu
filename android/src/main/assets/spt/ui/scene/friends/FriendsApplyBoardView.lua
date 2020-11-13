local EventSystem = require("EventSystem")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local FriendsApplyBoardView = class(unity.base)

function FriendsApplyBoardView:ctor()
    self.btnClose = self.___ex.btnClose
    self.scrollView = self.___ex.scrollView
end

function FriendsApplyBoardView:start()
    self.btnClose:regOnButtonClick(function()
        self:Close()
    end)
    EventSystem.AddEvent("FriendsApplyModel_UpdateApplicantsList", self, self.EventUpdateApplicantsList)
    self:PlayInAnimator()
end

function FriendsApplyBoardView:EventUpdateApplicantsList()
    if self.updateApplicantsListCallBack then
        self.updateApplicantsListCallBack()
    end
end

function FriendsApplyBoardView:onDestroy()
    EventSystem.RemoveEvent("FriendsApplyModel_UpdateApplicantsList", self, self.EventUpdateApplicantsList)
end

function FriendsApplyBoardView:PlayInAnimator()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
end

function FriendsApplyBoardView:PlayOutAnimator()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function() self:CloseView() end)
end

function FriendsApplyBoardView:CloseView()
    if type(self.closeDialog) == 'function' then
        self.closeDialog()
    end
end

function FriendsApplyBoardView:Close()
    self:PlayOutAnimator()
end

return FriendsApplyBoardView