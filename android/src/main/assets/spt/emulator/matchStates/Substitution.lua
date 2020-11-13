local MatchState = import("./MatchState")

local Substitution = class(MatchState)

function Substitution:ctor(match)
    Substitution.super.ctor(self, match, "Substitution")
end

function Substitution:Enter()
    self.match:changeState("NormalPlayOn")
end

function Substitution:Execute()

end

function Substitution:Exit()
    
end

return Substitution
