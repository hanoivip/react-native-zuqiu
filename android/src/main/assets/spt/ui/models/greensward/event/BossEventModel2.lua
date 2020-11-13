local AdventureEventTips = require("data.AdventureEventTips")
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local BossEventModel2 = class(GreenswardEventModel, "BossEventModel2")

function BossEventModel2:ctor()
	BossEventModel2.super.ctor(self)
	self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function BossEventModel2:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function BossEventModel2:HasEvent()
	return true
end

function BossEventModel2:GetEventResName()
	return "OpponentEvent"
end

function BossEventModel2:HasUnlock()
	return false
end

function BossEventModel2:HasFog()
	return false
end

function BossEventModel2:GetNameColorParam()
    return 255, 245, 94
end

function BossEventModel2:GetNameBorderName()
	return "Name_Border2"
end

function BossEventModel2:GetSignPrefabName()
	return "EnemySign1"
end

-- 消灭掉boss要求的敌人后会更改提示
local EnemyKilltips = 61
function BossEventModel2:GetDescText()
	local data = self:GetData()
	local guard = data.guard
	local descMap = self:GetDescMap()
	local st = self:GetCurrentState()
	local descIndex = descMap[tostring(st)]
	local desc = ""
	if guard then
		descIndex = descMap[tostring(EnemyKilltips)]
	end
	if descIndex then
		desc = AdventureEventTips[tostring(descIndex)].desc or AdventureEventTips[tonumber(descIndex)].desc or  ""
	end

	return desc
end

function BossEventModel2:GetPicIndex()
	local currentFloor = self:GetCurrentFloor()
	local totalFloor = self:GetTotalFloor()
	if tonumber(currentFloor) == tonumber(totalFloor) then
		return nil
	end
	return self.staticData.picIndex
end

function BossEventModel2:GetChallengeText()
	local currentFloor = self:GetCurrentFloor()
	local totalFloor = self:GetTotalFloor()
	if tonumber(currentFloor) == tonumber(totalFloor) then
		return lang.trans("adventure_challenge_tip3")
	else
		return lang.trans("adventure_challenge_tip2")
	end
end

return BossEventModel2