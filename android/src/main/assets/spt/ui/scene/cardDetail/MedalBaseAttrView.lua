local MedalBaseAttrView = class(unity.base)

function MedalBaseAttrView:ctor()
    self.attrName = self.___ex.attrName
    self.attrPlus = self.___ex.attrPlus
end

function MedalBaseAttrView:InitView(attrName, attrPlus)
    self.attrName.text = lang.trans(attrName)
    if tonumber(attrPlus) > 0 then 
        attrPlus = "+ " .. math.floor(attrPlus)
    else
        attrPlus = "0"
    end
    self.attrPlus.text = attrPlus
end

return MedalBaseAttrView
