local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local CommonConstants = require("ui.common.CommonConstants")
local DemoMatchConfig = require("coregame.DemoMatchConfig")
local DialogType = DemoMatchConfig.DialogType

local DemoMatchDialog = class(unity.base)

function DemoMatchDialog:ctor()
    self.dismissButton = self.___ex.dismissButton
    self.text = self.___ex.text
    self.animator = self.___ex.animator
    self.hasClickedDismiss = false
    self.dialogId = 0
    self.items = nil
    self.itemIdx = nil
    self.dialogType = nil
end

function DemoMatchDialog:start()
    self.dismissButton:regOnButtonClick(function ()
        self:OnButtonClickEvent()
    end)
end

function DemoMatchDialog:ShowDialog(dialog)
    self.dialogId = dialog.dialogId
    self.items = dialog.items
    self.dialogType = dialog.type
    self.audioOnShow = dialog.audioOnShow
    self.audioOnDismiss = dialog.audioOnDismiss
    self.hasClickedDismiss = false
    self.gameObject:SetActive(true)
    self.itemIdx = 1
    self:MoveIn()
end

function DemoMatchDialog:DismissDialog()
    if not self.hasClickedDismiss then
        ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
        self.gameObject:SetActive(false)
        self.items = nil
        self.itemIdx = nil
        self.audioOnShow = nil
    end
end

function DemoMatchDialog:OnButtonClickEvent()

    if not self:SetText() then
        self:DismissDialog()
        self.hasClickedDismiss = true
    end
end

function DemoMatchDialog:SetText()
    if self.items and self.itemIdx then
        self.itemIdx = self.itemIdx + 1
        if #self.audioOnShow > 0 and CommentaryManager.GetInstance():IsAudioPlayingInDemoMatch() then
            CommentaryManager.GetInstance():StopDemoMatchCommentary()
        end
        if self.itemIdx <= #self.audioOnShow then
            CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnShow[self.itemIdx])
        end
        if self.itemIdx <= #self.items then
            if self.dialogType == DialogType.FadeDialog then
                self.animator:Play("Base Layer.MoveOut", 0)
            else
                self.text.text = lang.trans(self.items[self.itemIdx])
            end
            return true
        else
            if self.audioOnDismiss then
                 CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnDismiss)
            end
        end
    end
    return false
end

function DemoMatchDialog:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        if self.items and self.itemIdx and self.itemIdx <= #self.items then
            self.animator:Play("Base Layer.MoveIn", 0)
            self.text.text = lang.trans(self.items[self.itemIdx])
        end
    end
end

function DemoMatchDialog:MoveIn()
    if self.dialogType == DialogType.FadeDialog then
        self.animator:Play("Base Layer.MoveIn", 0)
    end
    self.text.text = lang.trans(self.items[self.itemIdx])
    if self.itemIdx <= #self.audioOnShow then
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.audioOnShow[self.itemIdx])
    end
end

return DemoMatchDialog
