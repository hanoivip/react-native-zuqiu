local MainManager = class(unity.composed)

function MainManager:ctor(...)
    self.super.ctor(self, ...)

    if type(self.___ex) == 'table' then
        if type(self.___ex.managers) == 'table' then
            for k, v in pairs(self.___ex.managers) do
                if type(v) == 'string' then
                    require(v).new(self)
                end
            end
        end
    end
end

return MainManager

