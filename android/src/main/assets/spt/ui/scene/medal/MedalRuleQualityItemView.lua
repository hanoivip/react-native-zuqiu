local MedalRuleQualityItemView = class(unity.base)

function MedalRuleQualityItemView:ctor()
    self.mName = self.___ex.mName
    self.des1 = self.___ex.des1
    self.des2 = self.___ex.des2
    self.des3 = self.___ex.des3
end

function MedalRuleQualityItemView:InitView(data)
    self.mName.text = data.mName
    self.des1.text = data.des1
    self.des2.text = data.des2
    self.des3.text = data.des3
end

return MedalRuleQualityItemView