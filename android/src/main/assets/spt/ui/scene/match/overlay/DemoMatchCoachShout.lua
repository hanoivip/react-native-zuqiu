local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local CommonConstants = require("ui.common.CommonConstants")
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local AudioManager = require("unity.audio")

local DemoMatchCoachShout = class(unity.base)

function DemoMatchCoachShout:ctor()
    self.dismissButton = self.___ex.dismissButton
    self.text = self.___ex.text
    self.hasClickedDismiss = false
    self.dialogId = 0
    self.items = nil
    self.itemIdx = nil
end

function DemoMatchCoachShout:start()
    self.dismissButton:regOnButtonClick(function ()
        self:OnButtonClickEvent()
    end)

    AudioManager.RegListener("commentary", function()
        if self.audioOnShow then
            self:OnButtonClickEvent()
        end
    end, "DemoMatchCoachShoutCommentary")
end

function DemoMatchCoachShout:ShowDialog(dialog)
    self.dialogId = dialog.dialogId
    self.items = dialog.items
    self.itemIdx = 0
    self.audioOnShow = dialog.audioOnShow
    self.audioOnDismiss = dialog.audioOnDismiss
    self.hasClickedDismiss = false
    self:SetText()

    self.gameObject:SetActive(true)
end

function DemoMatchCoachShout:DismissDialog()
    if not self.hasClickedDismiss then
        if self.audioOnDismiss then
            CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnDismiss)
        end
        ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
        self.gameObject:SetActive(false)
        self.items = nil
        self.itemIdx = nil
        self.audioOnShow = nil
        self.audioOnDismiss = nil
        self.hasClickedDismiss = true
    end
end

function DemoMatchCoachShout:OnButtonClickEvent()
    if #self.audioOnShow > 0 and CommentaryManager.GetInstance():IsAudioPlayingInDemoMatch() then
        if self.itemIdx < #self.audioOnShow then --stop current commentary audio
            CommentaryManager.GetInstance():StopDemoMatchCommentary()
        elseif self.itemIdx == #self.audioOnShow then --fade current commentary audio
            CommentaryManager.GetInstance():FadeOutDemoMatchCommentary(1)
        end
    end
    if not self:SetText() then
        self:DismissDialog()
    end
end

function DemoMatchCoachShout:SetText()
    if self.items and self.itemIdx then
        self.itemIdx = self.itemIdx + 1
        if self.itemIdx <= #self.audioOnShow then
            CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnShow[self.itemIdx])
        end
        if self.itemIdx <= #self.items then
            self.text.text = lang.trans(self.items[self.itemIdx])
            return true
        end
    end
    return false
end

return DemoMatchCoachShout
