local AssistCoachJoinEffectBottomAnimView = class(unity.base, "AssistCoachJoinEffectBottomAnimView")

function AssistCoachJoinEffectBottomAnimView:ctor()
    AssistCoachJoinEffectBottomAnimView.super.ctor(self)
end

function AssistCoachJoinEffectBottomAnimView:OnEndBottomAnim()
    if self.onEndBottomAnim and type(self.onEndBottomAnim) == "function" then
        self.onEndBottomAnim()
    end
end

return AssistCoachJoinEffectBottomAnimView
