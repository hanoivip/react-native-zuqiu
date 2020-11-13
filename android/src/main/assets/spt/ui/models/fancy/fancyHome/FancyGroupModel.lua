local Model = require("ui.models.Model")
local FancyGroup = require("data.FancyGroup")
local FancyUnlock = require("data.FancyUnlock")
local FancyStarRequire = require("data.FancyStarRequire")
local FancyGroupModel = class(Model, "FancyGroupModel")

function FancyGroupModel:ctor()
    FancyGroupModel.super.ctor(self)
end

function FancyGroupModel:InitData(groupID, fancyCardsMapModel)
    self.groupID = groupID
    self.fancyGroup = FancyGroup[tostring(groupID)]
    self.fancyCardsMapModel = fancyCardsMapModel
    self.fancyCards = {}
    local FancyCardModel = fancyCardsMapModel:GetCardModel()
    for k, v in ipairs(self.fancyGroup.fancyCard) do
    	local fancyCardModel = FancyCardModel.new()
    	fancyCardModel:InitData(v, fancyCardsMapModel)
    	table.insert(self.fancyCards, fancyCardModel)
    end
end

function FancyGroupModel:GetTitle()
	return self.fancyGroup.groupName
end

function FancyGroupModel:GetCard(index)
	return self.fancyCards[index]
end

function FancyGroupModel:GetCardPos(index)
	return self.fancyCards[index]:GetPos()
end

function FancyGroupModel:GetFormationID()
	return self.fancyGroup.formationID
end

function FancyGroupModel:GetUnLockCount()
	local count = 0
	for k, v in pairs(self.fancyGroup.fancyCard) do
		if self.fancyCardsMapModel:GetFancyCardData(v) then
			count = count + 1
		end
    end
    return count
end

function FancyGroupModel:GetStarCount(star)
	local count = 0
	for k, v in pairs(self.fancyCards) do
		if v:GetStar() >= star then
			count = count + 1
		end
	end
	return count
end

function FancyGroupModel:GetStarUpAttr()
	local attr = 0
	for k, v in pairs(self.fancyCards) do
		attr = attr + v:GetStarUpAttr()
	end
	return attr
end

function FancyGroupModel:GetAllSkillAdd()
	local level = 0
	for k, v in pairs(self.fancyCards) do
		level = level + v:GetSkillAdd()
	end
	return level
end

local greenColor = "<color=#7FC148FF>"
local greenYellow = "<color=#FFA500FF>  +%s%%</color>"
function FancyGroupModel:GetLightAttrText(perAttr)
	local data = {}
	data.name = lang.transstr('fancyGroupLight')
	data.attr = {}
	local unlockCount = self:GetUnLockCount()
	for i, v in ipairs(self.fancyGroup.unlockID) do
		local unlockConfig = FancyUnlock[v]
		local strData = {}
		if unlockCount >= unlockConfig.unlockParam then
			strData.str = greenColor .. unlockConfig.title .. ": " .. lang.transstr("fancyAttrContent") .."+" .. unlockConfig.allAttributeNumIncrease .. "</color>"
		else
			strData.str = unlockConfig.title .. ": " .. lang.transstr("fancyAttrContent") .. "+" .. unlockConfig.allAttributeNumIncrease
		end
		if perAttr > 0 then
			strData.str = strData.str .. string.format(greenYellow, perAttr)
		end
		table.insert(data.attr, strData)
	end
	return data
end

function FancyGroupModel:GetStarAttrText(perAttr)
	local data = {}
	data.name = lang.transstr("fancyGroupStar")
	data.attr = {}
	local attr = self:GetStarUpAttr()
	local skillLev = self:GetAllSkillAdd()
	if attr > 0 then
		table.insert(data.attr, {str = greenColor .. lang.transstr("fancyAttrContent") .. ": +" .. attr .. "</color>"})
	else
		table.insert(data.attr, {str = lang.transstr("fancyAttrContent") .. ": +" .. attr})
	end
	if perAttr > 0 then
		data.attr[1].str = data.attr[1].str .. string.format(greenYellow, perAttr)
	end
	if skillLev > 0 then
		table.insert(data.attr, {str = greenColor .. lang.transstr("fancyAttrLevelContent") .. ": +" .. skillLev .. "</color>"})
	else
		table.insert(data.attr, {str = lang.transstr("fancyAttrLevelContent") .. ": +" .. skillLev})
	end
	return data
end

function FancyGroupModel:GetAllPerAttr()
	local perAttr = 0
	for k, v in ipairs(self.fancyGroup.starRequireID) do
		local fancyStarRequire = FancyStarRequire[v]
		local startCount = self:GetStarCount(fancyStarRequire.starParam)
		if startCount >= fancyStarRequire.numParam then
			perAttr = perAttr + fancyStarRequire.allAttributePercentIncrease
		end
	end
	return perAttr/100
end

function FancyGroupModel:GetAllStarAttrText()
	local data = {}
	data.name = lang.transstr("fancyGroupAllStar")
	data.attr = {}
	for k, v in ipairs(self.fancyGroup.starRequireID) do
		local str = ""
		local exStr = nil
		local fancyStarRequire = FancyStarRequire[v]
		local startCount = self:GetStarCount(fancyStarRequire.starParam)
		local bColor = false
		if startCount >= fancyStarRequire.numParam then
			bColor = true
			str = greenColor .. string.format(fancyStarRequire.title, fancyStarRequire.numParam, fancyStarRequire.numParam)
		else
			str = string.format(fancyStarRequire.title, startCount, fancyStarRequire.numParam)
		end
		if fancyStarRequire.allAttributePercentIncrease ~= 0 then
			str = str .. ": " .. lang.transstr("fancyExAttr") .."+" .. (fancyStarRequire.allAttributePercentIncrease / 100) .. "%"
		end
		if fancyStarRequire.allSkillsIncrease ~= 0 then
			if fancyStarRequire.allAttributePercentIncrease == 0 then
				str = str .. ": " .. lang.transstr("fancyAttrLevelContent") .. "+" .. fancyStarRequire.allSkillsIncrease
			else
				exStr = lang.transstr("fancyAttrLevelContent") .. "+" .. fancyStarRequire.allSkillsIncrease
				if bColor then
					exStr = greenColor .. exStr .. "</color>"
				end
			end
		end
		if bColor then
			str = str .. "</color>"
		end
		table.insert(data.attr, {str = str, exStr = exStr})
	end
	return data
end

return FancyGroupModel
