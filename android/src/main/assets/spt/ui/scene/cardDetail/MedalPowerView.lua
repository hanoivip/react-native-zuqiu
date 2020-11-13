local MedalPowerView = class(unity.base)

function MedalPowerView:ctor()
    self.num = self.___ex.num
end

function MedalPowerView:InitView(num)
    self.num.text = tostring(num)
end

return MedalPowerView
