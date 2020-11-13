local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local FormationCacheDataModel = require("ui.models.formation.FormationCacheDataModel")
local MatchInfoModel = require("ui.models.MatchInfoModel")

local MatchFormationCacheDataModel = class(FormationCacheDataModel, "CompeteFormationCacheDataModel")

function MatchFormationCacheDataModel:ctor(playerTeamsModel)
    self.playerTeamsModel = playerTeamsModel
    self.initPlayerCacheDataWithKeyPlayers = {}
    self.keyPlayersCacheData = {}
    self.initPlayerCacheData = {}
    self.replacePlayerCacheData = {}
    self.formationId = 0
    self.formationDataChanged = false
    self.initPlayersChanged = false
    self.replacePlayersChanged = false
    self.formationIdChanged = false
    self.keyPlayersChanged = false
    self.initPcids = {}
    self.repPcids = {}
    self:InitCacheData()
end

function MatchFormationCacheDataModel:InitCacheData()
    self:SetInitPlayersCacheDataWithKeyPlayers()
    self:SetKeyPlayersCacheData()
    self:SetInitPlayerCacheData()
    self:SetReplacePlayerCacheData()
    self:SetFormationIdCacheData()
end

-- 缓存首发球员数据
function MatchFormationCacheDataModel:SetInitPlayerCacheData(initPlayersData)
    self.initPlayersChanged = false
    if initPlayersData then
        self.initPlayerCacheData = clone(initPlayersData)
        if self:CheckInitPlayersChanged() then
            self.initPlayersChanged = true
        end
    else
        self.initPlayerCacheData = self.playerTeamsModel:GetInitPlayersData(self.playerTeamsModel:GetNowEditTeamId())
    end
    self.initPcids = self:AllotTeamPcids(self.initPlayerCacheData)
    self:OnFormationDataChanged()
end

function MatchFormationCacheDataModel:GetInitPlayerCacheData()
    return self.initPlayerCacheData
end

-- 缓存替补球员数据
function MatchFormationCacheDataModel:SetReplacePlayerCacheData(replacePlayersData)
    self.replacePlayersChanged = false
    if replacePlayersData then
        self.replacePlayerCacheData = clone(replacePlayersData)
        if self:CheckReplacePlayersChanged() then
            self.replacePlayersChanged = true
        end
    else
        self.replacePlayerCacheData = self.playerTeamsModel:GetReplacePlayersData(self.playerTeamsModel:GetNowEditTeamId())
    end
    self.repPcids = self:AllotTeamPcids(self.replacePlayerCacheData)
    self:OnFormationDataChanged()
end

function MatchFormationCacheDataModel:GetReplacePlayerCacheData()
    return self.replacePlayerCacheData
end

function MatchFormationCacheDataModel:SetFormationIdCacheData(formationId)
    self.formationIdChanged = false
    if formationId then
        self.formationId = formationId
        if self:CheckFormationIdChanged() then
            self.formationIdChanged = true
        end
    else
        self.formationId = self.playerTeamsModel:GetFormationId(self.playerTeamsModel:GetNowEditTeamId())
    end
    self:OnFormationDataChanged()
end

function MatchFormationCacheDataModel:GetFormationIdCacheData()
    return self.formationId
end

-- 缓存每次设置关键球员时的首发球员缓存数据
function MatchFormationCacheDataModel:SetInitPlayersCacheDataWithKeyPlayers(initPlayersData)
    if initPlayersData then
        self.initPlayerCacheDataWithKeyPlayers = clone(initPlayersData)
    else
        self.initPlayerCacheDataWithKeyPlayers = self.playerTeamsModel:GetInitPlayersData(self.playerTeamsModel:GetNowEditTeamId())
    end
end

function MatchFormationCacheDataModel:GetInitPlayersCacheDataWithKeyPlayers()
    return self.initPlayerCacheDataWithKeyPlayers
end

-- 设置操作关键球员设置后的关键球员缓存数据
function MatchFormationCacheDataModel:SetKeyPlayersCacheData(keyPlayersData)
    self.keyPlayersChanged = false
    if keyPlayersData then
        self.keyPlayersCacheData = clone(keyPlayersData)
        if self:CheckKeyPlayersChanged() then
            self.keyPlayersChanged = true
        end
    else
        self.keyPlayersCacheData = self.playerTeamsModel:GetNowTeamKeyPlayersData()
    end
    self:OnFormationDataChanged()
end

function MatchFormationCacheDataModel:GetKeyPlayersCacheData()
    return clone(self.keyPlayersCacheData)
end

-- 判断自从上次设置关键球员后首发球员是否发生变化
function MatchFormationCacheDataModel:CheckInitPlayersChangedWithKeyPlayers(newInitPlayersData)
    local oldInitPlayersData = self:GetInitPlayersCacheDataWithKeyPlayers()

    for pos, pcId in pairs(oldInitPlayersData) do
        if pcId ~= tonumber(newInitPlayersData[pos]) then
            return true
        end
    end

    for pos, pcId in pairs(newInitPlayersData) do
        if tonumber(pcId) ~= oldInitPlayersData[pos] then
            return true
        end
    end

    return false
end

function MatchFormationCacheDataModel:GetCardModelWithPcid(pcid)
    return PlayerCardModel.new(pcid)
end

-- 设置关键球员默认数据
function MatchFormationCacheDataModel:SetKeyPlayersDefaultData()
    local maxCaptainAttrTable = {
        powerAttr = 0,
        pcid = 0,
        skillId = "F01",
        skillLevel = 0,
    }
    local maxFreeKickShootAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F02",
    }
    local maxFreeKickPassAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F02",
    }
    local maxSpotKickAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F03",
    }
    local maxCornerAttrTable = {
        normalAttr = 0,
        pcid = 0,
        skillId = "F04",
    }

    local isCaptainSkillExisted, isCaptainSkillLevelSame = self:CheckCaptainSkillExisted()
    for pis, pcid in pairs(self.initPlayerCacheDataWithKeyPlayers) do
        if pcid ~= 0 then
            local cardModel = self:GetCardModelWithPcid(pcid)
            local baseNum, plusNum, trainNum, shootAttr, passAttr
            baseNum, plusNum, trainNum, shootAttr = cardModel:GetAbility("shoot")
            baseNum, plusNum, trainNum, passAttr = cardModel:GetAbility("pass")

            -- 直接任意球属性
            local isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxFreeKickShootAttrTable.skillId)
            if isSkillExisted then
                shootAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
            end
            if shootAttr > maxFreeKickShootAttrTable.normalAttr then
                maxFreeKickShootAttrTable.normalAttr = shootAttr
                maxFreeKickShootAttrTable.pcid = pcid
            end

            -- 间接任意球属性
            isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxFreeKickPassAttrTable.skillId)
            if isSkillExisted then
                passAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
            end
            if passAttr > maxFreeKickPassAttrTable.normalAttr then
                maxFreeKickPassAttrTable.normalAttr = passAttr
                maxFreeKickPassAttrTable.pcid = pcid
            end

            -- 点球属性
            isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxSpotKickAttrTable.skillId)
            if isSkillExisted then
                shootAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
            end
            if shootAttr > maxSpotKickAttrTable.normalAttr then
                maxSpotKickAttrTable.normalAttr = shootAttr
                maxSpotKickAttrTable.pcid = pcid
            end

            -- 角球属性
            isSkillExisted = self:CheckKeyPlayerSkillExisted(cardModel, maxCornerAttrTable.skillId)
            if isSkillExisted then
                passAttr = self:GetKeyPlayerMaxAttrWithSkill(cardModel)
            end
            if passAttr > maxCornerAttrTable.normalAttr then
                maxCornerAttrTable.normalAttr = passAttr
                maxCornerAttrTable.pcid = pcid
            end

            -- 队长属性
            -- 队长技能存在时，选择技能等级最高的球员，如果等级相同，则选择战力最高的球员
            if isCaptainSkillExisted then
                local skillItemModel = self:CheckKeyPlayerSkillExisted(cardModel, maxCaptainAttrTable.skillId)
                if skillItemModel then
                    if isCaptainSkillLevelSame then
                        local powerAttr = cardModel:GetPower()
                        if powerAttr > maxCaptainAttrTable.powerAttr then
                            maxCaptainAttrTable.powerAttr = powerAttr
                            maxCaptainAttrTable.pcid = pcid
                        end
                    else
                        local cardSkillLevel = skillItemModel:GetLevel()
                        if cardSkillLevel > maxCaptainAttrTable.skillLevel then
                            maxCaptainAttrTable.skillLevel = cardSkillLevel
                            maxCaptainAttrTable.pcid = pcid
                        end
                    end
                end
            -- 队长技能不存在时，则选择战力最高的球员
            else
                local powerAttr = cardModel:GetPower()
                if powerAttr > maxCaptainAttrTable.powerAttr then
                    maxCaptainAttrTable.powerAttr = powerAttr
                    maxCaptainAttrTable.pcid = pcid
                end
            end
        end
    end

    local keyPlayersData = {}
    if self:HasInitPlayers(self.initPlayerCacheDataWithKeyPlayers) then
        keyPlayersData.captain = maxCaptainAttrTable.pcid
        keyPlayersData.freeKickShoot = maxFreeKickShootAttrTable.pcid
        keyPlayersData.freeKickPass = maxFreeKickPassAttrTable.pcid
        keyPlayersData.spotKick = maxSpotKickAttrTable.pcid
        keyPlayersData.corner = maxCornerAttrTable.pcid
    else
        keyPlayersData.captain = 0
        keyPlayersData.freeKickShoot = 0
        keyPlayersData.freeKickPass = 0
        keyPlayersData.spotKick = 0
        keyPlayersData.corner = 0
    end
    self:SetKeyPlayersCacheData(keyPlayersData)
end

function MatchFormationCacheDataModel:HasInitPlayers(playersData)
    for pos, pcid in pairs(playersData) do
        if pcid ~= 0 then
            return true
        end
    end
    return false
end

-- 当关键球员技能存在时，获得关键球员的五维属性中最大的属性
function MatchFormationCacheDataModel:GetKeyPlayerMaxAttrWithSkill(playerCardModel)
    local baseNum, plusNum, trainNum
    local shootAttr, passAttr, dribbleAttr, interceptAttr, stealAttr
    baseNum, plusNum, trainNum, shootAttr = playerCardModel:GetAbility("shoot")
    baseNum, plusNum, trainNum, passAttr = playerCardModel:GetAbility("pass")
    baseNum, plusNum, trainNum, dribbleAttr = playerCardModel:GetAbility("dribble")
    baseNum, plusNum, trainNum, interceptAttr = playerCardModel:GetAbility("intercept")
    baseNum, plusNum, trainNum, stealAttr = playerCardModel:GetAbility("steal")
    return math.max(shootAttr, passAttr, dribbleAttr, interceptAttr, stealAttr)
end

-- 检查关键球员技能是否存在
function MatchFormationCacheDataModel:CheckKeyPlayerSkillExisted(playerCardModel, skillId)
    local skillCount = playerCardModel:GetSkillAmount()
    for slot = 1, skillCount do
        local skillItemModel = playerCardModel:GetSkillItemModelBySlot(slot)
        if skillItemModel and skillItemModel:GetSkillID() == skillId and skillItemModel:IsOpen() then
            return skillItemModel
        end
    end
    return nil
end

-- 检查首发球员中是否有球员有队长技能,如果有是否等级相同
function MatchFormationCacheDataModel:CheckCaptainSkillExisted()
    local isSkillExisted = false
    local isSkillLevelSame = true
    local skillLevel = 0
    for pis, pcid in pairs(self.initPlayerCacheDataWithKeyPlayers) do
        if pcid ~= 0 then
            local cardModel = self:GetCardModelWithPcid(pcid)
            local skillItemModel = self:CheckKeyPlayerSkillExisted(cardModel, "F01")
            if skillItemModel then
                isSkillExisted = true
                local cardSkillLevel = skillItemModel:GetLevel()
                if skillLevel == 0 then
                    skillLevel = cardSkillLevel
                end
                if cardSkillLevel ~= skillLevel then
                    isSkillLevelSame = false
                    break
                end
            end
        end
    end
    return isSkillExisted, isSkillLevelSame
end

-- 判断阵型Id是否已修改
function MatchFormationCacheDataModel:CheckFormationIdChanged()
    if self.playerTeamsModel:CheckFormationIdChanged(self.playerTeamsModel:GetNowEditTeamId(), self.formationId) then
        return true
    end
    return false
end

-- 判断首发球员是否已修改
function MatchFormationCacheDataModel:CheckInitPlayersChanged()
    if self.playerTeamsModel:CheckInitPlayersChanged(self.playerTeamsModel:GetNowEditTeamId(), self.initPlayerCacheData) then
        return true
    end
    return false
end

-- 判断替补球员是否已修改
function MatchFormationCacheDataModel:CheckReplacePlayersChanged()
    if self.playerTeamsModel:CheckReplacePlayersChanged(self.playerTeamsModel:GetNowEditTeamId(), self.replacePlayerCacheData) then
        return true
    end
    return false
end

-- 判断关键球员是否已修改
function MatchFormationCacheDataModel:CheckKeyPlayersChanged()
    if self.playerTeamsModel:CheckKeyPlayersChanged(self.keyPlayersCacheData) then
        return true
    end
    return false
end

-- 判断战术是否已修改
function MatchFormationCacheDataModel:CheckTacticsChanged()
    if self.playerTeamsModel:CheckTacticsChanged(self.tacticsCacheData) then
        return true
    end
    return false
end

function MatchFormationCacheDataModel:OnFormationDataChanged()
    self.formationDataChanged = self.initPlayersChanged or self.replacePlayersChanged or self.formationIdChanged or self.keyPlayersChanged
    EventSystem.SendEvent("MatchFormationDataChange", self.formationDataChanged)
end

--- 球员是否在首发阵容中
-- @param pcId 球员卡牌Id
-- @return boolean
function MatchFormationCacheDataModel:IsPlayerInInitTeam(pcId, teamId)
    pcId = tonumber(pcId)
    local initPlayersData = self:GetInitPlayerCacheData()
    for k, v in pairs(initPlayersData) do
        if pcId == v then
            return true
        end
    end
    return false
end

function MatchFormationCacheDataModel:IsExistCardIDInInitTeam(cid, teamId)
    local initPlayersData = self:GetInitPlayerCacheData()
    for k, v in pairs(initPlayersData) do
        if v ~= 0 then
            local tmpCardModel = SimpleCardModel.new(v)
            if tostring(cid) == tostring(tmpCardModel:GetCid()) then
                return true
            end
        end
    end
    return false
end

function MatchFormationCacheDataModel:IsExistCardIDInReplaceTeam(cid, teamId)
    local replacePlayersData = self:GetReplacePlayerCacheData()
    for k, v in pairs(replacePlayersData) do
        if v ~= 0 then
            local tmpCardModel = SimpleCardModel.new(v)
            if tostring(cid) == tostring(tmpCardModel:GetCid()) then
                return true
            end
        end
    end
    return false
end

--- 球员是否在替补阵容中
-- @param pcId 球员卡牌Id
-- @return boolean
function MatchFormationCacheDataModel:IsPlayerInReplaceTeam(pcId, teamId)
    pcId = tonumber(pcId)
    local replacePlayersData = self:GetReplacePlayerCacheData()
    for k, v in pairs(replacePlayersData) do
        if pcId == v then
            return true
        end
    end
    return false
end

function MatchFormationCacheDataModel:GetNowTeamId()
    return self.playerTeamsModel:GetNowEditTeamId()
end

function MatchFormationCacheDataModel:GetNowTeamTacticsData()
    if not self.matchInfoModel then
        self.matchInfoModel = MatchInfoModel.GetInstance()
    end
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    return self.playerTeamData.tactics or {}
end

return MatchFormationCacheDataModel