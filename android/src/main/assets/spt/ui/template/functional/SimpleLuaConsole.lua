local SimpleLuaConsole = class(unity.base)

function SimpleLuaConsole:ctor()
    self.___ex.btn.run:regOnButtonClick(function()
        local command = self.___ex.input.text
        if self.command then
            command = self.command
        end
        local msg
        local func, emsg = loadstring(command)
        msg = emsg
        if type(func) == 'function' then
            local status, rv = xpcall(func, function(err) return dump(err) end)
            msg = rv
        end
        if type(msg) ~= 'string' then
            msg = dump(msg)
        end
        
        self.command = command
        self.___ex.input.text = msg
    end)
    self.___ex.btn.close:regOnButtonClick(function()
        if self.command then
            self.___ex.input.text = self.command
            self.command = nil
        else
            self:destroyRoot()
        end
    end)
end

return SimpleLuaConsole