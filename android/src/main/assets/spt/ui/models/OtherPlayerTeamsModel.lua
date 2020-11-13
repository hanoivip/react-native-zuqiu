local Model = require("ui.models.Model")
local FormationType = require("ui.common.enum.FormationType")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local OtherPlayerTeamsModel = class(Model, "OtherPlayerTeamsModel")

function OtherPlayerTeamsModel:ctor(otherPlayerCardsMapModel)
    self.otherPlayerCardsMapModel = otherPlayerCardsMapModel
    self.formationType = FormationType.DEFAULT
    self.data = nil
    self.super.ctor(self)
end

function OtherPlayerTeamsModel:Init(data)
    if not data then
        data = cache.getOtherPlayerTeams()
    end

    if data ~= nil then
        self.data = clone(data)
    end
end

function OtherPlayerTeamsModel:SetFormationType(formationType)
    self.formationType = formationType
end

function OtherPlayerTeamsModel:GetFormationType()
    return self.formationType
end

-- 只有主阵型场景才算特性加成
function OtherPlayerTeamsModel:SetHomeCourtState(byHomeCourt)
    self.homeCourt = byHomeCourt
end

function OtherPlayerTeamsModel:IsHomeCourt()
    return self.homeCourt
end

function OtherPlayerTeamsModel:InitWithProtocol(data)
    self:SaveData(data)
    self:Init(data)
end

function OtherPlayerTeamsModel:SaveData(data)
    if type(data) == 'table' then
        cache.setOtherPlayerTeams(data)
    else
        cache.setOtherPlayerTeams(self.data)
    end
end

--- 获取阵型Id
function OtherPlayerTeamsModel:GetFormationId()
    return self.data.formationID
end

function OtherPlayerTeamsModel:GetInitPlayerCacheData()
    return self:GetInitPlayersData()
end

function OtherPlayerTeamsModel:GetReplacePlayerCacheData()
    return self:GetReplacePlayersData()
end

--- 获取首发球员数据
function OtherPlayerTeamsModel:GetInitPlayersData()
    return self.data.init
end

--- 获取替补球员数据
function OtherPlayerTeamsModel:GetReplacePlayersData()
    return self.data.rep
end

-- 获得战术信息
function OtherPlayerTeamsModel:GetTacticsData()
    return self.data.tactics
end

--- 球员是否在首发阵容中
function OtherPlayerTeamsModel:IsPlayerInInitTeam(pcid)
    pcid = tonumber(pcid)
    local initPlayersData = self:GetInitPlayersData()
    for k, v in pairs(initPlayersData) do
        if pcid == tonumber(v) then
            return true
        end
    end
    return false
end

--- 球员是否在替补阵容中
function OtherPlayerTeamsModel:IsPlayerInReplaceTeam(pcId)
    pcId = tonumber(pcId)
    local replacePlayersData = self:GetReplacePlayersData()
    for k, v in pairs(replacePlayersData) do
        if pcId == v then
            return true
        end
    end
    return false
end

-- 根据pcid 获取当前球员所处首发阵型位置(服务器数据roleId)
function OtherPlayerTeamsModel:GetStarterPlayerInTeamPos(pcId, teamId)
    pcId = tonumber(pcId)
    local initPlayersData = self:GetInitPlayersData()
    for pos, v in pairs(initPlayersData) do
        if pcId == tonumber(v) then
            return pos
        end
    end
    return -1
end

function OtherPlayerTeamsModel:IsExistCardIDInInitTeam(cid)
    local initPlayersData = self:GetInitPlayersData()
    for k, v in pairs(initPlayersData) do
        if v ~= 0 then
            local data = self.otherPlayerCardsMapModel:GetCardData(v)
            local cardCid = data and data.cid or ""
            if tostring(cid) == tostring(cardCid) then
                return true
            end
        end
    end
    return false
end

function OtherPlayerTeamsModel:IsExistCardIDInReplaceTeam(cid)
    local replacePlayersData = self:GetReplacePlayersData()
    for k, v in pairs(replacePlayersData) do
        if v ~= 0 then
            local data = self.otherPlayerCardsMapModel:GetCardData(v)
            local cardCid = data and data.cid or ""
            if tostring(cid) == tostring(cardCid) then
                return true
            end
        end
    end
    return false
end

--- 球员在首发阵容中的位置
-- @param pcId 球员卡牌Id
-- @return pos or false
function OtherPlayerTeamsModel:GetPlayerInInitTeamPos(pcId)
    pcId = tonumber(pcId)
    local initPlayersData = self:GetInitPlayersData()

    for k, v in pairs(initPlayersData) do
        if pcId == v then
            return k
        end
    end

    return false
end

-- 阵型类型 FormationConstants.TeamType
function OtherPlayerTeamsModel:SetTeamType(teamType)
    self.teamType = teamType
end

function OtherPlayerTeamsModel:GetTeamType()
    return self.teamType or FormationConstants.TeamType.NORMAL
end

return OtherPlayerTeamsModel