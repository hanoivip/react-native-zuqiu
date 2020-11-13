local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local ActivityView = class(unity.base)

function ActivityView:ctor()
    self.infoBar = self.___ex.infoBar
    self.scroll = self.___ex.scroll
    self.contentRect =  self.___ex.contentRect
    self.labelRect = self.___ex.labelRect
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.animator = self.___ex.animator
end

function ActivityView:start()
end

function ActivityView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function ActivityView:Clear()
    self:ClearChild(self.contentRect)
    self.scroll:Clear()
end

function ActivityView:ClearChild(parentRect)
    if parentRect.childCount > 0 then 
        for i = parentRect.childCount, 1, -1 do
            local child = parentRect:GetChild(i - 1).gameObject
            Object.Destroy(child)
        end
    end
end

function ActivityView:OnLeave()
    if self.onAnimationLevelComplete then
        self.onAnimationLevelComplete()
    end
end

function ActivityView:PlayLeaveAnimation()
    self.animator:Play("ActivityLeave")
end


return ActivityView
