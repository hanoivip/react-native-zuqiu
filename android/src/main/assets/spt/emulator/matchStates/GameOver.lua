local MatchState = import("./MatchState")

local GameOver = class(MatchState)

function GameOver:ctor(match)
    GameOver.super.ctor(self, match, "GameOver")
end

function GameOver:Enter()
    self.match:resetAthletesStates()
    self.match.ball.nextTask = nil
end

function GameOver:Execute()
end

function GameOver:Exit()

end

return GameOver
