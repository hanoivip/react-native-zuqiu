local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local CommonConstants = require("ui.common.CommonConstants")

local DemoMatchNote = class(unity.base)

function DemoMatchNote:ctor()
    self.text = self.___ex.text
    self.animator = self.___ex.animator
    self.dialogId = 0
    self.items = nil
    self.itemIdx = nil
end

function DemoMatchNote:ShowDialog(dialogId, items)
    self.dialogId = dialogId
    self.items = items
    self.itemIdx = 0
    self:SetText()
    self.gameObject:SetActive(true)
    self.animator:Play("Base Layer.MoveIn", 0)
end

function DemoMatchNote:DismissDialog()
    ___demoManager:OnDemoMatchDialogDismiss(self.dialogId)
    self.gameObject:SetActive(false)
    self.items = nil
    self.itemIdx = nil
end

function DemoMatchNote:SetText()
    if self.items and self.itemIdx then
        self.itemIdx = self.itemIdx + 1
        if self.itemIdx <= #self.items then
            self.text.text = lang.trans(self.items[self.itemIdx])
            return true
        end
    end
    return false
end

function DemoMatchNote:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        self:DismissDialog()
    end
end

return DemoMatchNote
