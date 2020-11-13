local UnityEngine = clr.UnityEngine
local Application = UnityEngine.Application
local contactMOB = class(unity.base)

function contactMOB:ctor()
    self.sendBtn = self.___ex.sendBtn
    self.closeBtn = self.___ex.closeBtn
    self.faqBtn = self.___ex.faqBtn
end

function contactMOB:start()
    self.closeBtn:regOnButtonClick(function()
        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)

    self.sendBtn:regOnButtonClick(function()
        if type(self.sendFunc) == "function" then
            self.sendFunc()
        end

        if type(self.closeDialog) == "function" then
            self.closeDialog()
        end
    end)

    self.faqBtn:regOnButtonClick(function()
        luaevt.trig("SDK_OpenWebView", require("ui.common.UrlConfig").FAQ, res.GetMobcastUserAgentAppendStr())
    end)
end

return contactMOB