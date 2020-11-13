local Skill = import("../Skill")
local TeamLeader = import("./TeamLeader")

local TeamLeaderEx1 = class(TeamLeader, "TeamLeaderEx1")
TeamLeaderEx1.id = "F01_1"
TeamLeaderEx1.alias = "团队领袖"

local minAddConfig = 0.222
local maxAddConfig = 0.42

function TeamLeaderEx1:ctor(level)
    TeamLeader.ctor(self, level)
    self.ex1AddRatio = Skill.lerpLevel(minAddConfig, maxAddConfig, level)
end

return TeamLeaderEx1
