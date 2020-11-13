local Model = require("ui.models.Model")

local CompeteGuessReplayModel = class(Model, "CompeteGuessReplayModel")

function CompeteGuessReplayModel:ctor()
end

function CompeteGuessReplayModel:InitWithMatchData(matchData)
    self.matchData = matchData
end

function CompeteGuessReplayModel:GetStatusData()
    return self.matchData
end

function CompeteGuessReplayModel:GetMatchData(idx)
    local match = self.matchData.match[idx] or {}
    local defender = nil -- 主场，在左
    local attacker = nil -- 客场，在右

    if match ~= nil then
        if self.matchData.player2.pid == match.attacker.attackerPid and self.matchData.player1.pid == match.defender.opponentPid then
            defender = self.matchData.player1
            attacker = self.matchData.player2
        end
        if self.matchData.player1.pid == match.attacker.attackerPid and self.matchData.player2.pid == match.defender.opponentPid then
            defender = self.matchData.player2
            attacker = self.matchData.player1
        end
    end
    return match.vid, defender, attacker
end

function CompeteGuessReplayModel:GetMatchCount()
    return table.nums(self.matchData.match)
end

return CompeteGuessReplayModel
