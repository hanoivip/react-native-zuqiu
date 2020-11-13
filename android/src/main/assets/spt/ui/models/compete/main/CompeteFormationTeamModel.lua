local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local FormationConstants = require("ui.scene.formation.FormationConstants")

local CompeteFormationTeamModel = class(PlayerTeamsModel, "CompeteFormationTeamModel")

function CompeteFormationTeamModel:ctor()
    CompeteFormationTeamModel.super.ctor(self)
end

function CompeteFormationTeamModel:Init(data)
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

function CompeteFormationTeamModel:InitWithProtocol(data)
    -- 匹配team格式
    local newData = {}
    newData.currTid = data.ptid
    newData.teams = {}
    local teamData = data
    teamData.tid = data.ptid
    newData.teams[tostring(teamData.tid)] = teamData

    self:SaveData(newData)
    self:Init(newData)
    self:CacheInitAndRep()
    self:OnTeamsInfoChanged()
end

function CompeteFormationTeamModel:SetCompeteSpecialTeamData(worldTournamentSeasonData)
    self.worldTournamentSeasonData = worldTournamentSeasonData
end

function CompeteFormationTeamModel:GetCompeteSpecialTeamData()
    return self.worldTournamentSeasonData
end

function CompeteFormationTeamModel:GetData()
    return self.data
end

function CompeteFormationTeamModel:SaveData(data)
end

return CompeteFormationTeamModel
