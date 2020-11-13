local TeamInvestType = require("ui.models.activity.teamInvest.TeamInvestType")
local TeamInvestModel = require("ui.models.activity.teamInvest.TeamInvestModel")
local FreshTeamInvestModel = class(TeamInvestModel)

function FreshTeamInvestModel:GetTeamInvestType()
    return TeamInvestType.FRESH
end

return FreshTeamInvestModel
