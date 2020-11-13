local RoundSign = class(unity.base)

function RoundSign:ctor()
	self.icon = self.___ex.icon
	self.round = self.___ex.round
	EventSystem.AddEvent("GreenswardInfoUpdate", self, self.RefreshMorale)
end

function RoundSign:InitView(eventModel)
	local buildModel = eventModel:GetBuildModel()
	self:RefreshMorale(buildModel)
	
	self.icon.overrideSprite = res.LoadRes(eventModel:GetSignIcon())
end

function RoundSign:RefreshMorale(eventModel)
	local moraleRound = eventModel:GetMoraleRound()
	if tonumber(moraleRound) > 0 then
		self.round.text = tostring(moraleRound)
	else
		self.round.text = ""
	end
end

function RoundSign:onDestroy()
	EventSystem.RemoveEvent("GreenswardInfoUpdate", self, self.RefreshMorale)
end

return RoundSign