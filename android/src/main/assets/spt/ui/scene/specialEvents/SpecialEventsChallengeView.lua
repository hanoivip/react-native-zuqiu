local SpecialEventsChallengeView = class(unity.base)

function SpecialEventsChallengeView:ctor()
    self.closeBtn = self.___ex.closeBtn
    self.sweepBtn = self.___ex.sweepBtn
    self.challengeBtn = self.___ex.challengeBtn
    self.challengeText = self.___ex.challengeText
    self.contentText = self.___ex.contentText
    self.sweepText = self.___ex.sweepText
    self.title = self.___ex.title
end

function SpecialEventsChallengeView:init(sweepCallback, challengeCallback, isVIP)
    self.sweepCallback = sweepCallback
    self.challengeCallback = challengeCallback
    self.challengeText.text = lang.trans("powerTarget_challenge")
    self.sweepText.text = lang.trans("special_events_open_sweep")
    self.title.text = isVIP and lang.trans("special_events_VIP_Sweep_title") or lang.trans("special_events_Common_Sweep_title")
    self.contentText.text = lang.trans("special_events_VIP_Sweep_Content")
end

function SpecialEventsChallengeView:CloseDialog()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
end

function SpecialEventsChallengeView:start()
    self.closeBtn:regOnButtonClick(function() self:CloseDialog() end)

    self.sweepBtn:regOnButtonClick(function()
        if type(self.sweepCallback) == "function" then
            self.sweepCallback()
        end
        self:CloseDialog()
    end)

    self.challengeBtn:regOnButtonClick(function()
        if type(self.challengeCallback) == "function" then
            self.challengeCallback()
        end
        self:CloseDialog()
    end)

end

return SpecialEventsChallengeView