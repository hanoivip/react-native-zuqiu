local DialogAnimation = require("ui.control.dialog.DialogAnimation")

local MailListView = class(unity.base)
local GameObjectHelper = require("ui.common.GameObjectHelper")
local EventSystem = require("EventSystem")

function MailListView:ctor()
    self.content = self.___ex.content
    self.recieveAllButtonScript = self.___ex.recieveAllButtonScript
    self.recieveAllButton = self.___ex.recieveAllButton
    self.close = self.___ex.close
    self.emptyMail = self.___ex.emptyMail
    self.scrollView = self.___ex.scrollView
    self.hasMail = false
end

function MailListView:Close()
    DialogAnimation.Disappear(self.transform, self.canvasGroup, function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

function MailListView:start()
    DialogAnimation.Appear(self.transform, self.canvasGroup)
    self.close:regOnButtonClick(function()
        self:Close()
    end)

    self.recieveAllButtonScript:regOnButtonClick(function()
        self:RecieveAllMails()
    end)

    EventSystem.AddEvent("MailDetailModel_CheckAllRecieveButtonState", self, self.EventCheckAllRecieveButtonState)
end

function MailListView:EventCheckAllRecieveButtonState(mailDetailModel)
    if self.checkAllRecieveButtonState then
       self.checkAllRecieveButtonState(mailDetailModel)
    end
end

function MailListView:RecieveAllMails()
end

function MailListView:ShowRecieveButton(isVisible)
    --self.recieveAllButton.gameObject:SetActive(isVisible)
end

function MailListView:ShowEmptyText(isVisible)
    self.emptyMail.gameObject:SetActive(isVisible)
end

function MailListView:SetRecieveButtonState(mailDetailModelMap)
    self.hasMail = false
    for mailID, mailModel in pairs(mailDetailModelMap) do
        local read = mailModel:IsRead()
        if not read then
            self.hasMail = true
            break
        end
    end
    -- 未领取的邮件是否都为手动领取
    self.manualReceive = true
    for mailID, mailModel in pairs(mailDetailModelMap) do
        local read = mailModel:IsRead()
        if not read then
            local isTextMail = mailModel:IsTextMail()
            local isRewardsContainPlayer = mailModel:IsRewardsContainPlayer()
            if not isTextMail and not isRewardsContainPlayer then
                self.manualReceive = false
                break
            end
        end
    end
end

function MailListView:onDestroy()
    EventSystem.RemoveEvent("MailDetailModel_CheckAllRecieveButtonState", self, self.EventCheckAllRecieveButtonState)
end

return MailListView
