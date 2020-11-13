local Model = require("ui.models.Model")

local DreamHallHistoryModel = class(Model, "DreamHallHistoryModel")


function DreamHallHistoryModel:InitWithProtocol(teamData, matchScore)
    self.teamData = teamData
    self.matchScore = matchScore
    self.homeTeam = {}
    self.homeTeam.members = {}
    self.homeTeam.nation = matchScore.homeTeamEn
    self.awayTeam = {}
    self.awayTeam.members = {}
    self.awayTeam.nation = matchScore.awayTeamEn
    for k, v in pairs(teamData.teamInfo) do
        if v.nation == matchScore.homeTeamEn then
            table.insert(self.homeTeam.members, v)
        else
            table.insert(self.awayTeam.members, v)
        end
    end
end

function DreamHallHistoryModel:GetHomeName()
    return self.matchScore.homeTeam
end

function DreamHallHistoryModel:GetAwayName()
    return self.matchScore.awayTeam
end

function DreamHallHistoryModel:GetScoreText()
    return self.matchScore.homeTeam
end

function DreamHallHistoryModel:GetScoreText()
    return (self.matchScore.homeScore + (self.matchScore.homePenaltyScore or 0)) .. ":" .. (self.matchScore.awayScore + (self.matchScore.awayPenaltyScore or 0))
end

function DreamHallHistoryModel:GetHomeTeamData()
    return self.homeTeam
end

function DreamHallHistoryModel:GetAwayTeamData()
    return self.awayTeam
end

return DreamHallHistoryModel