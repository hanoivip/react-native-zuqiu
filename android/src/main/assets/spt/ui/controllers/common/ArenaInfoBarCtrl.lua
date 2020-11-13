local ArenaInfoBarCtrl = class()
local ArenaModel = require("ui.models.arena.ArenaModel")

function ArenaInfoBarCtrl:ctor(infoBarView, parentCtrl, isShowLucky)
    self.arenaModel = nil
    self.infoBarView = infoBarView
    self.parentCtrl = parentCtrl
    self.infoBarView.clickBack = function() self:OnBtnBack() end
    self:InitView()
end

function ArenaInfoBarCtrl:InitView()
    if not self.arenaModel then
        self.arenaModel = ArenaModel.new()
    end
    self.infoBarView:InitView(self.arenaModel)
end

function ArenaInfoBarCtrl:RegOnBtnBack(func)
    if type(func) == "function" then
        self.infoBarView.clickBack = func
    end
end

function ArenaInfoBarCtrl:Refresh()
    self:InitView()
end  

function ArenaInfoBarCtrl:OnBtnBack()
    res.PopSceneImmediate()
end    

return ArenaInfoBarCtrl

