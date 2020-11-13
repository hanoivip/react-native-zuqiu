local DynamicLoaded = class(unity.base)

function DynamicLoaded:OnDynamicLoad(parent)
    table.merge(parent.___ex, self.___ex)
    if type(parent.OnDynamicLoadChild) == 'function' then
        parent:OnDynamicLoadChild(self)
    end
end

return DynamicLoaded
