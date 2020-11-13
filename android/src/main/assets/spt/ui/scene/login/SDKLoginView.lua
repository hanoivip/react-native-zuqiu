local SDKLogin = class(unity.base)

function SDKLogin:ctor()
    self.confirmBtn = self.___ex.confirmBtn

    self.confirmBtn:regOnButtonClick(function()
        luaevt.trig("SDK_Login")
    end)
end

return SDKLogin
