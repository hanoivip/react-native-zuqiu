local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object

local GoalEffect = class(unity.base)

function GoalEffect:ctor()

end

function GoalEffect:awake()
    self:RegisterEvent()
end

function GoalEffect:RegisterEvent()
    EventSystem.AddEvent("Match_DestroyGoal", self, self.Destroy)
end

function GoalEffect:RemoveEvent()
    EventSystem.RemoveEvent("Match_DestroyGoal", self, self.Destroy)
end

function GoalEffect:OnAnimEnd()
    self:Destroy()
end

function GoalEffect:Destroy()
    Object.Destroy(self.gameObject)
end

function GoalEffect:onDestroy()
    self:RemoveEvent()
end

return GoalEffect
