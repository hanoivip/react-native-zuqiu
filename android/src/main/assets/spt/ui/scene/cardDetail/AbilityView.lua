local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")
local AbilityView = class(unity.base)

function AbilityView:ctor()
    self.pentagonText = self.___ex.pentagonText
    self.pentagonValue = self.___ex.pentagonValue
    self.valueEffects = self.___ex.valueEffects
    self.animator = self.___ex.animator
end

function AbilityView:InitView(pentagonText, pentagonValue)
    self.pentagonText.text = lang.trans(pentagonText)
    self.pentagonValue.text = tostring(pentagonValue)
    GameObjectHelper.FastSetActive(self.valueEffects, false)
end

function AbilityView:ShowEffect()
    GameObjectHelper.FastSetActive(self.gameObject, false)
    GameObjectHelper.FastSetActive(self.valueEffects, true)
    GameObjectHelper.FastSetActive(self.gameObject, true)
end

return AbilityView