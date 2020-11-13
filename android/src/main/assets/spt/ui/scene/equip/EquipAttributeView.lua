local EquipAttributeView = class(unity.base)

function EquipAttributeView:ctor()
    self.value = self.___ex.value
    self.attribute = self.___ex.attribute
end

function EquipAttributeView:InitView(abilityIndex, value)
    self.attribute.text = lang.trans(abilityIndex)
    self.value.text = "+" .. value
end

return EquipAttributeView
