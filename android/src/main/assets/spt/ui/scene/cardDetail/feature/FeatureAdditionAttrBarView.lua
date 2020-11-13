local FeatureAdditionAttrBarView = class(unity.base)

function FeatureAdditionAttrBarView:ctor()
    self.attrName = self.___ex.attrName
    self.attrPlus = self.___ex.attrPlus
    self.attrPercent = self.___ex.attrPercent
end

function FeatureAdditionAttrBarView:InitView(name, attr, percent)
	self.attrName.text = lang.trans(name)
	local attrText = attr > 0 and ("+" .. attr) or ""
	self.attrPlus.text = attrText
	local percentText = percent > 0 and ("+" .. percent .. "%") or ""
	self.attrPercent.text = percentText
end

return FeatureAdditionAttrBarView
