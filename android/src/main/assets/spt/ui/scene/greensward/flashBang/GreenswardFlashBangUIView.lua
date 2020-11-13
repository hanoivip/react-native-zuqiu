local UnityEngine = clr.UnityEngine
local GameObjectHelper = require("ui.common.GameObjectHelper")

local GreenswardFlashBangUIView = class(unity.base, "GreenswardFlashBangUIView")

function GreenswardFlashBangUIView:ctor()
    self.objTip = self.___ex.objTip
end

function GreenswardFlashBangUIView:InitView()
end

-- 进入选择区域阶段
function GreenswardFlashBangUIView:EnterSelectStep()
    self:ShowTip(true)
end

-- 进入确认阶段
function GreenswardFlashBangUIView:EnterConfirmStep()
    self:ShowTip(false)
end

function GreenswardFlashBangUIView:ShowTip(isShow)
    GameObjectHelper.FastSetActive(self.objTip.gameObject, isShow)
end

return GreenswardFlashBangUIView
