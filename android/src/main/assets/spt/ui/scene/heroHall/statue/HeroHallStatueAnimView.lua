local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local LuaButton = require("ui.control.button.LuaButton")

local HeroHallStatueAnimView = class(LuaButton, "HeroHallStatueAnimView")

function HeroHallStatueAnimView:ctor()
    HeroHallStatueAnimView.super.ctor(self)
end

function HeroHallStatueAnimView:InitView(heroHallStatueView)
    self.heroHallStatueView = heroHallStatueView
end

function HeroHallStatueAnimView:ChangeEfxIcon()
    self.heroHallStatueView:ChangeEfxIcon()
end

function HeroHallStatueAnimView:FinishUpgradeEffect()
    self.heroHallStatueView:FinishUpgradeEffect()
end

return HeroHallStatueAnimView