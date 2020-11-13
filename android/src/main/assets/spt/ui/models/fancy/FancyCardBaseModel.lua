local Model = require("ui.models.Model")
local FancyCard = require("data.FancyCard")
local FancyGroup = require("data.FancyGroup")
local FancySort = require("data.FancySort")
local FancyStarUp = require("data.FancyStarUp")
local FancyCardBaseModel = class(Model, "FancyCardBaseModel")

function FancyCardBaseModel:ctor()
	FancyCardBaseModel.super.ctor(self)
	self.staticData = {} --配置数据
end

function FancyCardBaseModel:InitData(id, fancyCardsMapModel)
	self.id = id
	self.staticData = FancyCard[tostring(id)] or {}
	self.fancyCardsMapModel = fancyCardsMapModel
end

local function GetIconIndex(quality)
	if quality == 1 then
		return "A"
	elseif quality == 2 then
		return "S"
	elseif quality == 3 then
		return "SS"
	end
end

local function GetGroupConfig(id)
	return FancyGroup[tostring(id)]
end

local function GetSortsConfig(id)
	return FancySort[tostring(id)]
end

function FancyCardBaseModel:GetID()
	return self.id
end

--获取品质
function FancyCardBaseModel:GetQuality()
	return self.staticData.quality
end
--获取卡名字
function FancyCardBaseModel:GetName()
	return self.staticData.name
end
--获取卡名字颜色
function FancyCardBaseModel:GetNameColor()
	return GetGroupConfig(self.staticData.groupID).cardNameColorBig
end
--获取组id
function FancyCardBaseModel:GetGroupID()
	return self.staticData.groupID
end
--获取梦幻卡名字
function FancyCardBaseModel:GetFancyName()
	return GetGroupConfig(self.staticData.groupID).fancyCardName
end
--獲取梦幻卡名字颜色
function FancyCardBaseModel:GetFancyNameColor(isBig)
	local cfg = GetGroupConfig(self.staticData.groupID)
	if isBig then
		return cfg.groupNameColorBig, cfg.groupNameShadowColorBig
	else
		return cfg.groupNameColorSmall, cfg.groupNameShadowColorSmall
	end
end
--获取卡组名
function FancyCardBaseModel:GetGroupName()
	return GetGroupConfig(self.staticData.groupID).groupName
end
--获取大卡组名
function FancyCardBaseModel:GetBigGroupName()
	return GetSortsConfig(GetGroupConfig(self.staticData.groupID).sortID).sortName
end
--获取位置
function FancyCardBaseModel:GetPos()
	return self.staticData.posArray
end
--获取队名底图
function FancyCardBaseModel:GetFancyBg()
	return GetSortsConfig(GetGroupConfig(self.staticData.groupID).sortID).sortIcon
end
--获取小队名底图
function FancyCardBaseModel:GetGroupIcon(isBig)
	local icon = GetGroupConfig(self.staticData.groupID).groupIcon
	return (isBig and "BigGroup/" or "SmallGroup/") .. icon
end

--获取背景
function FancyCardBaseModel:GetBg(isBig)
	return (isBig and "Big/" or "Small/") .. GetIconIndex(self:GetQuality()) .. "cardbg"
end
--获取背景边框
function FancyCardBaseModel:GetBgSide(isBig)
	return (isBig and "Big/" or "Small/") .. GetIconIndex(self:GetQuality()) .. "Frame"
end
--获取遮罩
function FancyCardBaseModel:GetMask(isBig)
	return (isBig and "Big/" or "Small/") .. GetIconIndex(self:GetQuality()) .. "Mask"
end
--获取外边框遮罩 只有大卡有
function FancyCardBaseModel:GetSideMask()
	return "Big/" .. GetIconIndex(self:GetQuality()) .. "Mask1"
end

function FancyCardBaseModel:GetFancyInfo()
	if not self.fancyCardsMapModel then
		--这里认为是不属于任何一个人的卡
		return nil
	end
	return self.fancyCardsMapModel:GetFancyCardData(tostring(self.id))
end

function FancyCardBaseModel:GetFancyCardsMapModel()
	return self.fancyCardsMapModel
end

--获取星级
function FancyCardBaseModel:GetStar()
	local fancyInfo = self:GetFancyInfo()
	if fancyInfo then
		return fancyInfo.star
	else
		return -1
	end
end
--獲取數量
function FancyCardBaseModel:GetCount()
	local fancyInfo = self:GetFancyInfo()
	if fancyInfo then
		return fancyInfo.num
	else
		return -1
	end
end
--获取头像
function FancyCardBaseModel:GetHead()
	return self.staticData.pictureID
end
--获取品质图标
function FancyCardBaseModel:GetQualityIcon()
	return GetIconIndex(self:GetQuality())
end

--获取技能等级加成
function FancyCardBaseModel:GetSkillAddByStar(star)
	for k, v in pairs(FancyStarUp[tostring(self:GetQuality())]) do
		if v.star == star then
			return v.allSkills
		end
	end
	return 0
end

--获取技能等级加成
function FancyCardBaseModel:GetSkillAdd()
	local star = self:GetStar()
	if star < 0 then
		return 0
	end
	return self:GetSkillAddByStar(star)
end

function FancyCardBaseModel:GetNextSkillAdd()
	local star = self:GetStar()
	if star < 0 then
		return 0
	end
	return self:GetSkillAddByStar(star + 1)
end

function FancyCardBaseModel:GetStarUpAttrByStar(star)
	for k, v in pairs(FancyStarUp[tostring(self:GetQuality())]) do
		if v.star == star then
			return v.allAttributeNum
		end
	end
	return 0
end

--获取升星加成
function FancyCardBaseModel:GetStarUpAttr()
	local star = self:GetStar()
	if star < 0 then
		return 0
	end
	return self:GetStarUpAttrByStar(star)
end

--获取升星加成
function FancyCardBaseModel:GetNextStarUpAttr()
	local star = self:GetStar()
	if star < 0 then
		return 0
	end
	return self:GetStarUpAttrByStar(star + 1)
end

function FancyCardBaseModel:GetStarUpConfig()
	local star = self:GetStar()
	for k, v in pairs(FancyStarUp[tostring(self:GetQuality())]) do
		if v.star == star then
			return v
		end
	end
	return nil
end

function FancyCardBaseModel:IsHaveNextStar()
	local star = self:GetStar()
	for k, v in pairs(FancyStarUp[tostring(self:GetQuality())]) do
		if v.star == star + 1 then
			return true
		end
	end
	return false
end

function FancyCardBaseModel:GetAccess()
	local cfg = self.staticData.fancyCardAccess
	local str = ""
	for i, v in ipairs(cfg) do
		str = str .. v
		if i ~= #cfg then
			str = str .. "\n"
		end
	end
	return str
end

function FancyCardBaseModel:IsNew()
	return self.fancyCardsMapModel:IsNewTip(self.id)
end

function FancyCardBaseModel:ResetNew()
	self.fancyCardsMapModel:SetNewTip(self.id, false)
end

return FancyCardBaseModel