local EventSystem = require ("EventSystem")
local Model = require("ui.models.Model")
local PlayerCardModel = require("ui.models.cardDetail.PlayerCardModel")
local Formation = require("data.Formation")
local FormationConstants = require("ui.scene.formation.FormationConstants")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")

local MatchPlayerTeamsModel = class(PlayerTeamsModel, "MatchPlayerTeamsModel")

function MatchPlayerTeamsModel:ctor()
    MatchPlayerTeamsModel.super.ctor(self)
end

function MatchPlayerTeamsModel:Init(data)
    if data ~= nil then
        self.data = clone(data)
        self:SetNowTeamData(self:GetNowTeamId())
    end
end

function MatchPlayerTeamsModel:GetData()
    return self.data
end

--- 保存数据
-- @param data 队伍数据
function MatchPlayerTeamsModel:SaveData(data)
    
end

-- 比赛中上场的球员已经筛选过 不用再次筛选
function MatchPlayerTeamsModel:IsPlayerInInitTeam()
    return true
end

return MatchPlayerTeamsModel
