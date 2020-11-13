local MatchState = import("./MatchState")

local PenaltyShootOut = class(MatchState)

function PenaltyShootOut:ctor(match)
    PenaltyShootOut.super.ctor(self, match, "PenaltyShootOut")
end

function PenaltyShootOut:Enter()

end

function PenaltyShootOut:Execute()
    self.match.playerTeam.shootOutScore = 0
    self.match.opponentTeam.shootOutScore = 0
    while self.match.playerTeam.shootOutScore == self.match.opponentTeam.shootOutScore do
        self.match.playerTeam.shootOutScore = math.random(3, 5)
        self.match.opponentTeam.shootOutScore = math.random(3, 5)
    end

    self.match:changeState("GameOver")
end

function PenaltyShootOut:Exit()

end

return PenaltyShootOut
