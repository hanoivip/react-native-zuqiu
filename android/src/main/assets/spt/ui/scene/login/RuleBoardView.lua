local UnityEngine = clr.UnityEngine
local RuleBoardView = class(unity.base)

function RuleBoardView:ctor()
    self.startBtn = self.___ex.startBtn
    self.viewBtn = self.___ex.viewBtn
    self.notAllowed = self.___ex.notAllowed
    self.agreeBtn = self.___ex.agreeBtn
    self.checkMark = self.___ex.checkMark
    self.closeBtn = self.___ex.closeBtn
    self.agree = false
end

function RuleBoardView:start()
    self.notAllowed:SetActive(true)
    self.startBtn.gameObject:SetActive(false)

    self.viewBtn:regOnButtonClick(function()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").Rules, res.GetMobcastUserAgentAppendStr())
    end)

    self.closeBtn:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)

    self.agreeBtn:regOnButtonClick(function()
        self.agree = not self.agree
        self.checkMark:SetActive(self.agree)
        self.notAllowed:SetActive(not self.agree)
        self.startBtn.gameObject:SetActive(self.agree)
    end)
end

function RuleBoardView:RegOnStartBtnClick(func)
    assert(type(func) == "function")
    self.startBtn:regOnButtonClick(func)
end

return RuleBoardView
