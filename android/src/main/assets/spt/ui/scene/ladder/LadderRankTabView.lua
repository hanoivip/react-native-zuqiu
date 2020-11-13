local LadderRankTabView = class(unity.base)

function LadderRankTabView:ctor()
    self.btnRankTab = self.___ex.btnRankTab
end

function LadderRankTabView:start()
end

function LadderRankTabView:InitView(name)
    self.btnRankTab:InitView(name)
end

function LadderRankTabView:ChangeButtonState(isSelect)
    self.btnRankTab:ChangeState(isSelect)
end

return LadderRankTabView