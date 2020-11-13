local CrossContentOrder = require("ui.scene.compete.cross.CrossContentOrder")
local MatchScheduleType = require("ui.scene.arena.schedule.MatchScheduleType")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CompeteOutCup = class(unity.base)

function CompeteOutCup:ctor()
	self.cupImage = self.___ex.cupImage
	self.nameTxt = self.___ex.name
	self.effect1 = self.___ex.effect1
	self.effect2 = self.___ex.effect2
end

function CompeteOutCup:InitView(matchModel)
	local crossType = matchModel:GetCrossType()
	local index = 1
	if crossType == CrossContentOrder.Universe_Knockout then 
		index = 2
	elseif crossType == CrossContentOrder.Galaxy_Knockout then 
		index = 1
	end
	self.cupImage.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Bytes/Cup" .. index .. ".png")
	self.cupImage:SetNativeSize()

	local scheduleData = matchModel:GetMatchScheduleData(MatchScheduleType.Final) or {}
	local winnerName = ""
	local matchData = scheduleData[1] or {}
	local winnerPid = matchData.winner
	if winnerPid then 
		local teamList = matchModel:GetTeamList()
		local teamInfo = teamList[winnerPid] or { }
		winnerName = teamInfo.name or ""
	end
	self.nameTxt.text = winnerName
	GameObjectHelper.FastSetActive(self.effect1.gameObject, index == 1)
	GameObjectHelper.FastSetActive(self.effect2.gameObject, index == 2)
end

return CompeteOutCup