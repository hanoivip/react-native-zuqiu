local AssistCoachJoinEffectTopAnimView = class(unity.base, "AssistCoachJoinEffectTopAnimView")

function AssistCoachJoinEffectTopAnimView:ctor()
    AssistCoachJoinEffectTopAnimView.super.ctor(self)
end

function AssistCoachJoinEffectTopAnimView:OnEndTopAnim()
    if self.onEndTopAnim and type(self.onEndTopAnim) == "function" then
        self.onEndTopAnim()
    end
end

function AssistCoachJoinEffectTopAnimView:OnStartBottomAnim()
    if self.onStartBottomAnim and type(self.onStartBottomAnim) == "function" then
        self.onStartBottomAnim()
    end
end

function AssistCoachJoinEffectTopAnimView:OnCloseDialog()
    if self.onCloseDialog and type(self.onCloseDialog) == "function" then
        self.onCloseDialog()
    end
end

return AssistCoachJoinEffectTopAnimView
