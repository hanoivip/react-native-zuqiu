local UnityEngine = clr.UnityEngine
local Screen = UnityEngine.Screen

local ScreenManager = class(unity.luacomp)
local listenerOnScreenSizeChanged = {}
local lastRegedListeners = {}

function ScreenManager:ctor(...)
    self.super.ctor(self, ...)

    if type(self.___ex) == 'table' then
        if type(self.___ex.OnScreenSizeChanged) == 'table' then
            for k, v in pairs(self.___ex.OnScreenSizeChanged) do
                ScreenManager.RegOnScreenSizeChanged(v)
            end
        end
    end

    self.AdjustOnUpdate = self.___ex.AdjustOnUpdate
    self.AdjustOnLateUpdate = self.___ex.AdjustOnLateUpdate
end

function ScreenManager:onDestroy()
    if type(self.___ex) == 'table' then
        if type(self.___ex.OnScreenSizeChanged) == 'table' then
            for k, v in pairs(self.___ex.OnScreenSizeChanged) do
                ScreenManager.UnregOnScreenSizeChanged(v)
            end
        end
    end
end

function ScreenManager:CheckScreenSize()
    local width, height = ScreenManager.width, ScreenManager.height
    if ScreenManager.changedSizeLastFrame then
        ScreenManager.changedSizeLastFrame = nil
        for k, v in pairs(listenerOnScreenSizeChanged) do
            if type(v) == 'function' then
                v(width, height)
            elseif type(v) == 'userdata' or type(v) == 'table' then
                local func = v.onScreenSizeChanged
                if type(func) == 'function' then
                    func(v, width, height)
                end
            end
        end
    elseif next(lastRegedListeners) then
        for k, v in pairs(listenerOnScreenSizeChanged) do
            if lastRegedListeners[k] then
                if type(v) == 'function' then
                    v(width, height)
                elseif type(v) == 'userdata' or type(v) == 'table' then
                    local func = v.onScreenSizeChanged
                    if type(func) == 'function' then
                        func(v, width, height)
                    end
                end
            end
        end
    end
    if next(lastRegedListeners) then
        lastRegedListeners = {}
    end
    local width, height = Screen.width, Screen.height
    if width ~= ScreenManager.width or height ~= ScreenManager.height then
        ScreenManager.width = width;
        ScreenManager.height = height;
        ScreenManager.changedSizeLastFrame = true
    end
end

function ScreenManager:update()
    if self.AdjustOnUpdate == nil and self.AdjustOnLateUpdate == nil then
        self.AdjustOnUpdate = true
        self.AdjustOnLateUpdate = false
    end
    if self.AdjustOnUpdate then
        self:CheckScreenSize()
    end
end

function ScreenManager:lateUpdate()
    if self.AdjustOnLateUpdate == nil or self.AdjustOnLateUpdate then
        self:CheckScreenSize()
    end
end

function ScreenManager.RegOnScreenSizeChanged(func, real)
    listenerOnScreenSizeChanged[func] = real or func
    lastRegedListeners[func] = true
end

function ScreenManager.UnregOnScreenSizeChanged(func)
    listenerOnScreenSizeChanged[func] = nil
end

return ScreenManager

