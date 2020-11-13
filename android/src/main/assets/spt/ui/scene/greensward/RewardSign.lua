local RewardSign = class(unity.base)

function RewardSign:ctor()
	self.icon = self.___ex.icon
end

function RewardSign:InitView(eventModel)
	self.icon.overrideSprite = res.LoadRes(eventModel:GetSignIcon())
end

return RewardSign