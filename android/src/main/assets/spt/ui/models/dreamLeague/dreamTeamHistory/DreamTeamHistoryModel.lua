local Model = require("ui.models.Model")
local DreamTeamHistoryModel = class(Model, "DreamTeamHistoryModel")

function DreamTeamHistoryModel:InitWithProtocol(teamHistoryData)
    self.teamHistoryData = teamHistoryData
    self:SortMatchHistory()
end

function DreamTeamHistoryModel:SortMatchHistory()
    table.sort( self.teamHistoryData.matchHistory, function (a, b)
        return tonumber(a.time) > tonumber(b.time)
    end )
end

function DreamTeamHistoryModel:GetTabData()
    return self.teamHistoryData.matchHistory
end

return DreamTeamHistoryModel
