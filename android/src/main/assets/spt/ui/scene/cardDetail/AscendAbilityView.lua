local AscendAbilityView = class(unity.base)

function AscendAbilityView:ctor()
    self.ablity = self.___ex.ablity
    self.oldValue = self.___ex.oldValue
    self.newValue = self.___ex.newValue
end

function AscendAbilityView:InitView(oldfiveAbilityValue, newfiveAbilityValue)
    self.ablity.text = lang.trans(oldfiveAbilityValue.key)
    self.oldValue.text = tostring(oldfiveAbilityValue.value)
    self.newValue.text = tostring(newfiveAbilityValue.value)
end

return AscendAbilityView