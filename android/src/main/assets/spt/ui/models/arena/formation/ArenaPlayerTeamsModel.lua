local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local CardConfig = require("ui.common.card.CardConfig")
local ArenaTeamCardQuality = require("data.ArenaTeamCardQuality")
local CardHelper = require("ui.scene.cardDetail.CardHelper")

local ArenaPlayerTeamsModel = class(PlayerTeamsModel, "ArenaPlayerTeamsModel")

function ArenaPlayerTeamsModel:ctor(teamType, matchArenaType, arenaModel)
    self.teamType = teamType
    self.matchArenaType = matchArenaType
    self.arenaModel = arenaModel
    ArenaPlayerTeamsModel.super.ctor(self)
end

function ArenaPlayerTeamsModel:Init(data)
    if data ~= nil then
        self.data = clone(data)
        if not next(self.data) then
            self:SetNowTeamId(0)
            self.data.teams = {}
            self.nowFormationId = 10
        end
        self:SetNowTeamData(self:GetNowTeamId())
        self:SetSelectedType(self:GetSelectedType())
    end
end

function ArenaPlayerTeamsModel:GetData()
    return self.data
end

function ArenaPlayerTeamsModel:SaveData(data)
end

function ArenaPlayerTeamsModel:GetTeamType()
    return self.teamType
end

function ArenaPlayerTeamsModel:GetMatchArenaType()
    return self.matchArenaType
end

-- 是否在赛程中，不能清空当前比赛阵型
function ArenaPlayerTeamsModel:IsMatchingArena()
    if self.arenaModel:IsMatch(self.teamType) then 
        local matchArenaType = self.arenaModel:GetMatchArena(self.teamtype)
        return tobool(matchArenaType == self.teamType)
    elseif self.arenaModel:IsSign(self.teamType) then 
        local allotArena = self.arenaModel:GetAllotArena(self.teamType)
        return tobool(allotArena == self.teamType)
    end
    return false
end

local arenaTeamCardQuality
function ArenaPlayerTeamsModel:CheckCardQuality(teamtype, quality)
    if not arenaTeamCardQuality then
        arenaTeamCardQuality = {}
        for k, v in pairs(ArenaTeamCardQuality) do
            if not arenaTeamCardQuality[k] then
                arenaTeamCardQuality[k] = {}
            end
            for k1, v1 in pairs(v.quality) do
                arenaTeamCardQuality[k][v1] = 1
            end
        end
    end
    if not arenaTeamCardQuality[teamtype] then
        return false
    end
    
    return arenaTeamCardQuality[teamtype][quality] and true or false
end

function ArenaPlayerTeamsModel:SetAllCardsData()
    self.allCardsData = {}
    -- 获取卡牌背包中的数据
    local allCardsData = cache.getPlayerCardsMap()
    for k, v in pairs(allCardsData) do
        local playerCardModel = self:GetCardModelWithPcid(v.pcid)
        local fixQuality = CardHelper.GetQualityConfigFixed(playerCardModel:GetCardQuality(), playerCardModel:GetCardQualitySpecial())
        if self:CheckCardQuality(self.teamType, fixQuality) then
            self.allCardsData[k] = v
        end
    end
end

return ArenaPlayerTeamsModel
