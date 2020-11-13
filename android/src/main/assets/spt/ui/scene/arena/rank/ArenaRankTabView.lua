local ArenaRankTabView = class(unity.base)

function ArenaRankTabView:ctor()
    self.btnRankTab = self.___ex.btnRankTab
    self.zoneIndex = self.___ex.zoneIndex
end

function ArenaRankTabView:start()
end

function ArenaRankTabView:InitView(name)
    self.btnRankTab:InitView(name)
end

function ArenaRankTabView:ChangeButtonState(isSelect)
    self.btnRankTab:ChangeState(isSelect)
end

return ArenaRankTabView