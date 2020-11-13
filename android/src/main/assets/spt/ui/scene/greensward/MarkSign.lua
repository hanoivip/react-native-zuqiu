local MarkSign = class(unity.base)

function MarkSign:ctor()
	self.num = self.___ex.num
end

function MarkSign:InitView(eventModel)
	self.num.text = tostring(eventModel:GetMarkNum())
end

return MarkSign