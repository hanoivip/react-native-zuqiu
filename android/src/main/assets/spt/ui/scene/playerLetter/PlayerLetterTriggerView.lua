local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local EventSystem = require("EventSystem")

local PlayerLetterTriggerView = class(unity.base)

function PlayerLetterTriggerView:ctor()
    self.letterTrans = self.___ex.letterTrans
    self.targetPos = nil
end

function PlayerLetterTriggerView:InitView(targetPos)
    self.targetPos = targetPos
end

function PlayerLetterTriggerView:OnAnimEnd()
    self:MoveLetterToTarget()
end

function PlayerLetterTriggerView:MoveLetterToTarget()
    local moveTweener = ShortcutExtensions.DOMove(self.letterTrans, self.targetPos, 0.3, false)
    TweenSettingsExtensions.OnComplete(moveTweener, function ()  --Lua assist checked flag
        self:Destroy()
        EventSystem.SendEvent("LetterMoveEnd")
    end)
end

function PlayerLetterTriggerView:Destroy()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
    clr.coroutine(function ()
        coroutine.yield(WaitForSeconds(0.1))
        EventSystem.SendEvent("PlayerLetterTrigger_Destroy")
    end)
end

return PlayerLetterTriggerView
