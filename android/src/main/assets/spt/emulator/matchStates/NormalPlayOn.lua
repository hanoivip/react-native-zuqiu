local MatchState = import("./MatchState")
local Ball = import("../Ball")

local NormalPlayOn = class(MatchState)

function NormalPlayOn:ctor(match)
    NormalPlayOn.super.ctor(self, match, "NormalPlayOn")
end

function NormalPlayOn:Enter()

end

function NormalPlayOn:Execute()
    self.super.Execute(self)
end

function NormalPlayOn:Exit()

end

return NormalPlayOn
