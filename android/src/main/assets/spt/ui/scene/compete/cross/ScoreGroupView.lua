local CompeteEnumHelper = require("ui.scene.compete.cross.CompeteEnumHelper")
local ScoreGroupView = class(unity.base)

function ScoreGroupView:ctor()
    self.team1 = self.___ex.team1
    self.team2 = self.___ex.team2
    self.team3 = self.___ex.team3
    self.team4 = self.___ex.team4
    self.icon = self.___ex.icon
end

local TeamGroup = 4
function ScoreGroupView:InitView(matchModel, index)
	local data = matchModel:GetAppointData(index)
	for i = 1, TeamGroup do
		self["team" .. i]:InitView(i, matchModel, data)
	end
	local symbol = CompeteEnumHelper.ScoreSymbol[index] or "Z"
	self.icon.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Images/" .. symbol .. ".png")
end

return ScoreGroupView