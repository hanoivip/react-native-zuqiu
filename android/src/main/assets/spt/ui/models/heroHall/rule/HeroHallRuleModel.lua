local Model = require("ui.models.Model")
local FootballHallExplain = require("data.FootballHallExplain")

local HeroHallRuleModel = class(Model, "HeroHallRuleModel")

function HeroHallRuleModel:ctor()
end

function HeroHallRuleModel:GetTitle()
    return FootballHallExplain["1"].title
end

function HeroHallRuleModel:GetIntro()
    return FootballHallExplain["1"].desc
end

return HeroHallRuleModel