local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GreenswardGlassesUIView = class(unity.base, "GreenswardGlassesUIView")

function GreenswardGlassesUIView:ctor()
    self.objTip = self.___ex.objTip
end

function GreenswardGlassesUIView:InitView()
end

-- 进入选择区域阶段
function GreenswardGlassesUIView:EnterSelectStep()
    self:ShowTip(true)
end

-- 进入确认阶段
function GreenswardGlassesUIView:EnterConfirmStep()
    self:ShowTip(false)
end

function GreenswardGlassesUIView:ShowTip(isShow)
    GameObjectHelper.FastSetActive(self.objTip.gameObject, isShow)
end

return GreenswardGlassesUIView
