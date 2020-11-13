local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3

local FitParent = class(unity.base)

function FitParent:onScreenSizeChanged()
    -- 获取当前控件的宽度和高度
    local width = self.transform.rect.width
    local height = self.transform.rect.height

    -- 获取父节点的宽度和高度
    local parentTransform = self.transform.parent
    local parentWidth = parentTransform.rect.width
    local parentHeight = parentTransform.rect.height

    -- 设置scale
    local scaleWidth = parentWidth / width
    local scaleHeight = parentHeight / height

    self.transform.localScale = Vector3(scaleWidth, scaleHeight, 1)
end

function FitParent:start()
    require('ui.control.manager.ScreenManager').RegOnScreenSizeChanged(self)
    self:onScreenSizeChanged()
end

function FitParent:onEnable()
    require('ui.control.manager.ScreenManager').RegOnScreenSizeChanged(self)
    self:coroutine(function()
        unity.waitForEndOfFrame()
        self:onScreenSizeChanged()
    end)
end

function FitParent:onDisable()
    require('ui.control.manager.ScreenManager').UnregOnScreenSizeChanged(self)
end

return FitParent