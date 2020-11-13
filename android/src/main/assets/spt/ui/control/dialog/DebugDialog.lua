local DebugDialog = class(unity.base)

function DebugDialog:ctor()
    self.text = self.___ex.text
    self.close = self.___ex.close
end

function DebugDialog:setText(text)
    self.text.text = text
end

function DebugDialog:start()
    self.close:regOnButtonClick(function ()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return DebugDialog
