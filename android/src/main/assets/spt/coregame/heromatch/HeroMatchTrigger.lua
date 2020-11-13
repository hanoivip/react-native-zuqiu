local MatchLoader = require('coregame.MatchLoader')

local HeroMatchTrigger = class(unity.base)

function HeroMatchTrigger:ctor()
end

function HeroMatchTrigger:start()
    MatchLoader.startHeroMatch()
end

return HeroMatchTrigger