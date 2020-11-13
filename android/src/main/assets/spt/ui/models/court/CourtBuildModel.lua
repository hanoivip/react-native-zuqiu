local Building = require("data.Building")
local BuildingBase = require("data.BuildingBase")
local LeagueInfoModel = require("ui.models.league.LeagueInfoModel")
local PlayerGenericModel = require("ui.models.playerGeneric.PlayerGenericModel")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildIncludeType = require("ui.scene.court.CourtBuildIncludeType")
local Model = require("ui.models.Model")

local CourtBuildModel = class(Model, "CourtBuildModel")

function CourtBuildModel:ctor()
    CourtBuildModel.super.ctor(self)
end

function CourtBuildModel:Init(data)
    if not data then
        data = cache.getCourtBuildData()
    end
    self.data = data
    self.list = self.data and self.data.list
    self.cd = self.data and self.data.cd or {}
    self.set = self.data and self.data.matchSet or {}
end

function CourtBuildModel:InitWithProtocol(data)
    assert(type(data) == "table")
    cache.setCourtBuildData(data)
    self:Init(data)
    local cd = self.data.cd
    if cd and next(cd) then
        self:SetBuildTime(cd.type, cd.lastTime)
    end
end

function CourtBuildModel:HasBuildUpgrading()
    local isUpgrading = false
    if self.cd and next(self.cd) then 
        local time = self:GetBuildUpgradingTime()
        isUpgrading = tobool(time > 0)
    end
    return isUpgrading
end

function CourtBuildModel:GetBuildUpgradingType()
    return self.data.cd and self.data.cd.type
end

-- 同时只能有一个建筑升级
function CourtBuildModel:GetBuildUpgradingTime()
    if self.cd and next(self.cd) then 
        return self:GetBuildTime(self:GetBuildUpgradingType())
    end
    return 0
end

--* 服务器导出json中是从1开始（对应最低级lv0） 所有等级从表中查询均+1
-- 建筑是否达到最高级
function CourtBuildModel:IsBuildMaxLvl(name, lvl)
    local isMax = false
    if lvl > 0 then     
        lvl = lvl + 1
        local buildTable = Building[name]
        local buildInfo = buildTable[lvl]
        if not buildInfo then 
            isMax = true
        end
    end
    return isMax
end

-- 获取建筑资源index
function CourtBuildModel:GetBuildIcon(name, lvl)

    if name == CourtBuildType.ParkingBuild and tonumber(lvl) >= 7 then
        lvl = 4
    end 

    lvl = lvl + 1
    local buildTable = Building[name]
    local icon = buildTable[lvl] and buildTable[lvl].picIndex
    return icon
end

-- 获取3D建筑资源
function CourtBuildModel:Get3DBuildResName(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    if buildTable then
        local data = buildTable[lvl]
        if data then
            return data.resIndex
        end
    end
    return nil
end

--获取3D建筑升级中小物件特效资源
function CourtBuildModel:GetEffectResName(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    if buildTable then
        local data = buildTable[lvl]
        if data then
            return data.effectRes
        end
    end
    return nil
end

--获取3D建筑升级中需要变灰的建筑物节点名字
function CourtBuildModel:GetBuildingNodeName(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    if buildTable then
        local data = buildTable[lvl]
        if data then
            return data.buildingNode
        end
    end
    return nil
end

--获取3D建筑升级中围栏特效资源
function CourtBuildModel:GetBuildBorderEffectName(name)
    local borderEffectResName = nil
    if name == CourtBuildType.StadiumBuild then
        borderEffectResName = "QJ_JianSheZhong_01_QC00"
    elseif name == CourtBuildType.ParkingBuild then
        borderEffectResName = "QJ_JianSheZhong_01_TCC00"
    elseif name == CourtBuildType.ScoutBuild then
        borderEffectResName = "QJ_JianSheZhong_01_QTS00"
    elseif name == CourtBuildType.CommunicationBuild then
        borderEffectResName = "QJ_JianSheZhong_01_JL00"
    elseif name == CourtBuildType.TechnologyHallBuild then
        borderEffectResName = "nil"
    end
    return borderEffectResName
end

-- 建筑升级描述
function CourtBuildModel:GetBuildUpgradeConditionDesc(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    local conditionDesc = buildTable[lvl] and buildTable[lvl].conditionDesc
    return conditionDesc
end

--建筑效果数值
function CourtBuildModel:GetBuildIndex(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    local buildIndex = buildTable[lvl] and buildTable[lvl].index

    if buildIndex == nil then
        return buildIndex
    end
    if name == CourtBuildType.AudienceBuild or name == CourtBuildType.ParkingBuild then
        buildIndex = buildIndex[1]
    else
        buildIndex = tonumber(buildIndex[1]) / 10000
    end

    return buildIndex
end

-- 建筑升级效果
function CourtBuildModel:GetBuildUpgradeEffectDesc(name)
    local buildTable = BuildingBase[name]
    local fuctionDesc = buildTable.fuctionDesc
    return fuctionDesc
end

-- 获取建筑显示名称
function CourtBuildModel:GetBuildShowName(name)
    local buildTable = BuildingBase[name] or {}
    local showName = buildTable.name or ""
    return showName
end

-- 建筑升级用时(分钟)
function CourtBuildModel:GetBuildUpgradeTime(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    local time = buildTable[lvl] and buildTable[lvl].time or 0
    return time
end

-- 建筑升级消耗金钱
function CourtBuildModel:GetBuildUpgradeCost(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    local cost = buildTable[lvl] and buildTable[lvl].cost or 0
    return string.formatNumWithUnit(cost)
end

function CourtBuildModel:JudgeCondition(condition)
    local buildLvl, needLvl = -1, 0
    local needBuildName, desc = ""
    if type(condition) == "table" then
        needBuildName = condition[1]
        needLvl = condition[2]
        if needBuildName == "League" then
            local leagueInfoModel = LeagueInfoModel.new()
            local leagueLvl = leagueInfoModel:GetLeagueLevel()
            if not leagueLvl then
                local playerGenericModel = PlayerGenericModel.new()
                leagueLvl = playerGenericModel:GetLeagueDiff()
            end
            buildLvl = leagueLvl
			desc = lang.trans("league_unlock", needLvl)
        elseif needBuildName == "Stadium" then
            local stadiumLvl = self:GetBuildLevel(CourtBuildType.StadiumBuild)
            buildLvl = stadiumLvl
        end
    end
    local isOpen = tobool(tonumber(buildLvl) >= tonumber(needLvl))
    return isOpen, needLvl, needBuildName, desc
end

function CourtBuildModel:IsBuildBeUsed(settingType, technologyType, typeName)
    local setType = self:GetDevelopSetAndLvl(settingType, technologyType)
    local isBeUsed = tobool(setType == typeName)
	return isBeUsed
end

function CourtBuildModel:IsDefaultType(typeName)
	local isDefaultBuild = tobool(typeName == CourtBuildType.GrassBuild or 
									typeName == CourtBuildType.SunShineBuild)
	return isDefaultBuild
end

-- 所需建筑是否开启
function CourtBuildModel:IsBuildOpen(name, lvl)
    lvl = lvl + 1
    local buildTable = Building[name]
    local condition = buildTable[lvl] and buildTable[lvl].condition

    return self:JudgeCondition(condition)
end

-- 建筑是否解锁（科技馆配置）
function CourtBuildModel:IsBuildUnlock(name)
    local buildTable = BuildingBase[name]
    local condition = buildTable.condition

    return self:JudgeCondition(condition)
end

-- 获取建筑等级
function CourtBuildModel:GetBuildLevel(name)
    return self.list[name] and self.list[name].lvl or 0
end

-- 更新建筑等级
function CourtBuildModel:SetBuildLevel(name, lvl)
    if self.list[name] then  
        self.list[name].lvl = lvl
    end
end

-- 获取建筑时间
function CourtBuildModel:GetBuildTime(name)
    local time = 0
    if self.cd.type == name then 
        time = self.cd.lastTime
    end
    return time
end

-- 更新建筑时间
function CourtBuildModel:SetBuildTime(name, time)
    self.cd.type = name
    self.cd.lastTime = time
end

-- 获取建筑等级标题
function CourtBuildModel:GetBuildLevelStr(courtBuildType)
    local courtLvl = self:GetBuildLevel(courtBuildType)
    local courtLevelStr = "Lv" .. courtLvl
    local name = self:GetBuildShowName(courtBuildType)
    local buildStr = name .. " " .. courtLevelStr
    return buildStr
end

-- 获取影响技能或属性
function CourtBuildModel:GetEffect(name, lvl)
    lvl = lvl + 1
    local isEffectSkill = false
    local buildTable = BuildingBase[name] or {}
    local buildData = Building[name]
    local skillEffect = buildTable.skillAffect or {}
    local attrEffect = buildTable.attrAffect or {}
    if type(skillEffect) == 'table' and next(skillEffect) then 
        isEffectSkill = true
        local effectLvl = buildData[lvl] and buildData[lvl].skillEffect
        return isEffectSkill, skillEffect, effectLvl
    elseif type(attrEffect) == 'table' and next(attrEffect) then
        local effectPoint = buildData[lvl] and buildData[lvl].attrEffect
        return isEffectSkill, attrEffect, effectPoint
    end

    return nil
end

-- 科技馆比赛配置
function CourtBuildModel:GetMatchSet(setType)
    return self.set[setType]
end

-- 科技馆研发当前配置项
-- setType 竞技场，冠军联赛等
-- technologyDevelopType 草皮，天气等 
function CourtBuildModel:GetDevelopSetAndLvl(setType, technologyDevelopType)
    local matchSet = self:GetMatchSet(setType) or {}
    local developData = matchSet[technologyDevelopType] or {}
    return developData.type, developData.lvl
end

-- 科技馆设置研发选项
function CourtBuildModel:MatchSet(setType, technologyDevelopType, typeName)
    self.set[setType][technologyDevelopType].type = typeName
    EventSystem.SendEvent("ChangeTechnologySetting")
end

function CourtBuildModel:IsGrass(name)
    return (name == CourtBuildType.GrassBuild) or 
    (name == CourtBuildType.MixedBuild) or 
    (name == CourtBuildType.NatureShortBuild) or 
    (name == CourtBuildType.NatureLongBuild) or 
    (name == CourtBuildType.ArtificialShortBuild) or 
    (name == CourtBuildType.ArtificialLongBuild) 
end

function CourtBuildModel:IsWeather(name)
    return (name == CourtBuildType.SunShineBuild) or 
    (name == CourtBuildType.RainBuild) or 
    (name == CourtBuildType.SnowBuild) or 
    (name == CourtBuildType.WindBuild) or 
    (name == CourtBuildType.FogBuild) or 
    (name == CourtBuildType.SandBuild) or
    (name == CourtBuildType.HeatBuild)
end

-- 体育场和科技馆都有子建筑
function CourtBuildModel:HasBuildChildIsBuilding(name)
    local isChildBuilding = false
    local childBuildTime = 0
    local buildChildren = self:HasBuildChild(name)
    if buildChildren then 
        for i, child in ipairs(buildChildren) do
            local time = self:GetBuildTime(child) 
            if time > 0 then 
                isChildBuilding = true
                childBuildTime = time
                break
            end
        end
    end
    return isChildBuilding, childBuildTime
end

function CourtBuildModel:HasBuildChild(name)
    return CourtBuildIncludeType.GetBuildChild(name)
end

function CourtBuildModel:IsBuildChild(parent, child)
    local buildChildren = self:HasBuildChild(parent)
    if buildChildren then 
        for i, childName in ipairs(buildChildren) do
            if childName == child then 
                return true
            end
        end
    end
    return false
end

function CourtBuildModel:HasCanUpBuilding()
    for k, v in pairs(Building) do
        local lvl = self:GetBuildLevel(k) + 1
        if self:IsBuildOpen(k, lvl) then
            if self:IsBuildChild(CourtBuildType.TechnologyHallBuild, k) then
                if self:IsBuildUnlock(k) then
                    return true
                end
            elseif k ~= CourtBuildType.CommunicationBuild then
                return true
            end
        end
    end
end

function CourtBuildModel:HasBuildChildCanUp(courtBuildType)
    local child = self:HasBuildChild(courtBuildType)
    if child and courtBuildType == CourtBuildType.TechnologyHallBuild then
        for k, v in pairs(child) do
            local lvl = self:GetBuildLevel(v) + 1
            if self:IsBuildOpen(v, lvl) and self:IsBuildUnlock(v) then
                return true
            end
        end
    elseif child then
        for k, v in pairs(child) do
            local lvl = self:GetBuildLevel(v) + 1
            if self:IsBuildOpen(v, lvl) then
                return true
            end
        end
    end
end

function CourtBuildModel:SetScoutPlayerSortIndex(sortIndex)
    self.scoutPlayerSortIndex = sortIndex
end

function CourtBuildModel:GetScoutPlayerSortIndex()
    return self.scoutPlayerSortIndex
end

function CourtBuildModel:SetScoutExtraPlayerScrollPos(scrollPos)
    self.scoutExtraPlayerSortIndex = scrollPos
end

function CourtBuildModel:GetScoutExtraPlayerScrollPos()
    return self.scoutExtraPlayerSortIndex
end

return CourtBuildModel
