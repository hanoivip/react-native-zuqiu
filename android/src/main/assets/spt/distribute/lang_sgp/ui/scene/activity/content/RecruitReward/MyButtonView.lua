local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")
local MyButtonView = class(unity.base)

function MyButtonView:ctor()
    self.btnUpGo = self.___ex.btnUpGo
    self.btnDownGo = self.___ex.btnDownGo
    self.txtLabel = self.___ex.txtLabel
end

function MyButtonView:start()
end

function MyButtonView:InitView(isClicked)
    self:ChangeToSelectedState(isClicked)
end

function MyButtonView:ChangeToSelectedState(isClicked)
    GameObjectHelper.FastSetActive(self.btnDownGo, isClicked)
    GameObjectHelper.FastSetActive(self.btnUpGo, not isClicked)
end

return MyButtonView