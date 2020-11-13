local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local MatchTipsView = class(unity.base)

function MatchTipsView:ctor()
    self.blackTipText = self.___ex.blackTipText
    self.whiteTipText = self.___ex.whiteTipText
    self.grayTipText = self.___ex.grayTipText
end

function MatchTipsView:SetTips(tipText)
    self.blackTipText.text = tipText
    self.whiteTipText.text = tipText
    self.grayTipText.text = tipText
end

function MatchTipsView:Destroy()
    Object.Destroy(self.gameObject)
end

return MatchTipsView