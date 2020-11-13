local GameObjectHelper = require("ui.common.GameObjectHelper")
local AdditionSymbolView = class(unity.base)

function AdditionSymbolView:ctor()
    self.symbol = self.___ex.symbol
    self.textGradient = self.___ex.textGradient
	self.effect = self.___ex.effect
end

function AdditionSymbolView:InitView(isRise)
	local pic = isRise and "Success" or "Success_Dis"
	self.symbol.overrideSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/Compete/Common/Mix/" .. pic .. ".png")
	self.textGradient.enabled = isRise
	GameObjectHelper.FastSetActive(self.effect.gameObject, isRise)
end

return AdditionSymbolView