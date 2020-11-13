local DynamicLoadedParent = class(unity.base)

function DynamicLoadedParent:RegOnDynamicLoad(func)
    if type(func) == "function" then
        self.onDynamicLoadCallback = func
    end
    if self.child then
        func(self.child)
    end
end

function DynamicLoadedParent:OnDynamicLoadChild(child)
    self.child = child
    if type(self.onDynamicLoadCallback) == "function" then
        self.onDynamicLoadCallback(child)
    end
end

function DynamicLoadedParent:GetChild()
    return self.child
end

return DynamicLoadedParent
