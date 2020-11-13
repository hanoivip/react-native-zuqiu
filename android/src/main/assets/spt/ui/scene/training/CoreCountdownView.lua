local CoreCountdownView = class(unity.base)

function CoreCountdownView:ctor()
    self.countdownGO = self.___ex.countdownGO
    self.countdownAnimator = self.___ex.countdownAnimator
    self.countdownText = self.___ex.countdownText
    self.effectText1 = self.___ex.effectText1
    self.effectText2 = self.___ex.effectText2
end

function CoreCountdownView:start()
end

function CoreCountdownView:ShowCountdown()
    self.countdownGO:SetActive(true)
end

function CoreCountdownView:HideCountdown()
    self.countdownGO:SetActive(false)
end

function CoreCountdownView:SetCountdownTime(time)
    time = tostring(time)
    self.countdownText.text = time
    self.effectText1.text = time
    self.effectText2.text = time
    self.countdownAnimator:Play("Base Layer.MoveIn", 0, 0)
end

return CoreCountdownView
