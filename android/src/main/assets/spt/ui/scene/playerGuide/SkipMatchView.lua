local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local SkipMatchView = class(unity.base)

function SkipMatchView:ctor()
    self.btnContinue = self.___ex.btnContinue
    self.txtDialog = self.___ex.txtDialog
end

function SkipMatchView:start()
    if self.btnContinue then
        self.btnContinue:regOnButtonClick(function()
            self:OnContinue()
        end)
    end
end

function SkipMatchView:InitView()
    self.txtDialog.text = lang.trans("skip_match_guide")
end

function SkipMatchView:OnContinue()
    Object.Destroy(self.gameObject)
    EventSystem.SendEvent("Match_TipToSkip")
end

return SkipMatchView
