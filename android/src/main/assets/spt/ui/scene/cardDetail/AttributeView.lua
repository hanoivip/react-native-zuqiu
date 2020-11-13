local AttributeView = class(unity.base)

function AttributeView:ctor()
    self.nameTxt = self.___ex.name
    self.value = self.___ex.value
end

function AttributeView:InitView(abilityIndex, value) 
    self.nameTxt.text = lang.trans(abilityIndex)
    self.value.text = tostring(value)
end

return AttributeView