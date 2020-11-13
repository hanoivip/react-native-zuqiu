local BuildingBase = require("data.BuildingBase")
local GreenswardEventModel = require("ui.models.greensward.event.GreenswardEventModel")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local LeaderEventModel1 = class(GreenswardEventModel, "LeaderEventModel1")

function LeaderEventModel1:ctor()
    LeaderEventModel1.super.ctor(self)
    self.ctrlPath = "ui.controllers.greensward.dialog.OpponentDialogCtrl"
end

function LeaderEventModel1:TriggerEvent()
	EventSystem.SendEvent("GreenswardOpponentEventTrigger", self)
end

function LeaderEventModel1:HasEvent()
    return true
end

function LeaderEventModel1:GetEventResName()
    return "OpponentEvent"
end

function LeaderEventModel1:GetNameBorderName()
	return "Name_Border3"
end

function LeaderEventModel1:GetSignPrefabName()
	return "EnemySign2"
end

function LeaderEventModel1:GetCloudEffectRes()
	local st = self:GetCurrentState()
	if tobool(tonumber(st) == GreenswardEventModel.EventStatus.Lock_Effect) then
		return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectLight.prefab"
	elseif tobool(tonumber(st) == GreenswardEventModel.EventStatus.LockWithSign) then
		return "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Effect/EffectEddy.prefab"
	end
end

function LeaderEventModel1:GetEffectBuffText(info)
	local weather = info.wea
	local floorData = self:GetAdventureFloorData()
	local smallBossBuff = floorData.smallBossBuff or 0
	local smallBossDebuff = floorData.smallBossDebuff or 0
	local name = BuildingBase[weather] and BuildingBase[weather].name or ""
	local advWea = info.advWea or {}
	local disWea = info.disWea or {}
	for i, v in ipairs(advWea) do
		if v == weather then
			return lang.trans("adventure_weather_effect1", name, smallBossBuff .. "%")
		end
	end
	for i, v in ipairs(disWea) do
		if v == weather then 
			return lang.trans("adventure_weather_effect2", name, smallBossDebuff .. "%")
		end
	end
	return lang.trans("adventure_weather_effect3")
end

function LeaderEventModel1:GetTipsText(info)
	local advWea = info.advWea or {}
	local disWea = info.disWea or {}
	local advDesc, disDesc = "", ""
	for i, v in ipairs(advWea) do
		if i > 1 then 
			advDesc = advDesc .. "、"
		end
		local name = BuildingBase[v].name
		advDesc = advDesc .. name
	end
	local advTip = lang.transstr("adventure_weather_desc1", advDesc)
	for i, v in ipairs(disWea) do
		if i > 1 then 
			disDesc = disDesc .. "、"
		end
		local name = BuildingBase[v].name
		disDesc = disDesc .. name
	end
	local disTip = lang.transstr("adventure_weather_desc2", disDesc)
	return advTip, disTip
end

function LeaderEventModel1:GetNameColorParam()
    return 255, 255, 255
end

return LeaderEventModel1
