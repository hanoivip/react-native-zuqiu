local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color

local ArrowView = class(unity.base)

function ArrowView:ctor()
    self.bg = self.___ex.bg
end

function ArrowView:InitView(isOpen)
    if isOpen then
        self.bg.color = Color.white
    else
        self.bg.color = Color(0, 1, 1)
    end
end

return ArrowView