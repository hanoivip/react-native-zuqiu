local LoseMatchView = class(unity.base)

function LoseMatchView:ctor()

end

function LoseMatchView:Close()
    if type(self.closeDialog) == 'function' then
        dump('closeDialog')
        self.closeDialog()
    end
end

return LoseMatchView