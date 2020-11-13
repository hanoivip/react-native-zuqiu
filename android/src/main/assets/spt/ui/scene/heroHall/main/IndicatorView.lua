local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObjectHelper = require("ui.common.GameObjectHelper")

local IndicatorView = class(unity.base, "IndicatorView")

function IndicatorView:ctor()
    -- the resources of indicator
    self.dotRes = self.___ex.dotRes
    -- the object of container
    self.container = self.___ex.container
    self.capacity = 1
end

function IndicatorView:start()
end

function IndicatorView:InitView(num, currIndex)
    assert(self.dotRes ~= nil, "dot's resources is nil")
    assert(self.container ~= nil, "container is nil")

    self.capacity = num or 1
    self.currIndex = currIndex or 1
    self.sptDots = {}

    self:ClearContainer()

    for index = 1, self.capacity do
        local obj, spt = self:CreateDot(index)
        if obj and spt then
            spt:InitView(index)
            self.sptDots[index] = spt
        end
    end

    self:GotoIndex(self.currIndex)
end

function IndicatorView:Previous()
    self:GotoIndex(self.currIndex - 1)
end

function IndicatorView:Next()
    self:GotoIndex(self.currIndex + 1)
end

function IndicatorView:GotoIndex(index)
    index = math.clamp(index, 1, self.capacity)
    if not self.sptDots then return end

    if self.sptDots[self.currIndex] then
        self.sptDots[self.currIndex]:SetSelect(false)
    end
    if self.sptDots[index] then
        self.sptDots[index]:SetSelect(true)
    end
    self.currIndex = index
end

function IndicatorView:CreateDot(index)
    local obj
    if index == 1 and self.dotRes.transform.parent then
        -- use the template if it's already in the view hierarchy
        obj = self.dotRes
    else
        obj = Object.Instantiate(self.dotRes)
    end

    obj.transform:SetParent(self.container.transform, false)
    GameObjectHelper.FastSetActive(obj, true)

    local spt = res.GetLuaScript(obj)

    return obj, spt
end

function IndicatorView:GetDotRes()
    return self.dotRes
end

function IndicatorView:ClearContainer()
    local childCount = self.container.transform.childCount
    if childCount - 1 > 0 then
        for i = 2, childCount do
            Object.Destroy(self.container.transform:GetChild(i - 1).gameObject)
        end
    end
end

function IndicatorView:GetIndicatorList()
    return self.sptDots
end

return IndicatorView