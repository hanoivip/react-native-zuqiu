local LuaButton = require("ui.control.button.LuaButton")
local AssetFinder = require("ui.common.AssetFinder")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local FirstTeamCourtSpotView = class(LuaButton)

function FirstTeamCourtSpotView:ctor()
    FirstTeamCourtSpotView.super.ctor(self)
    self.point = self.___ex.point
    self.lightCircle = self.___ex.lightCircle
end

function FirstTeamCourtSpotView:InitView(quality)
    self.point.overrideSprite = AssetFinder.GetPositionQualityPoint(quality)
end

function FirstTeamCourtSpotView:SetLight(isLight)
    GameObjectHelper.FastSetActive(self.lightCircle, tobool(isLight))
end

return FirstTeamCourtSpotView
