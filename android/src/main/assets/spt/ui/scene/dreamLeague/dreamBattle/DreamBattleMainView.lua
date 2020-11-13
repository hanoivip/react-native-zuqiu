local GameObjectHelper = require("ui.common.GameObjectHelper")

local DreamBattleMainView = class(unity.base)

function DreamBattleMainView:ctor()
    self.createHomeBtn = self.___ex.createHomeBtn
    self.findHomeBtn = self.___ex.findHomeBtn
    self.historyBtn = self.___ex.historyBtn
    self.refreshBtn = self.___ex.refreshBtn
    self.scrollView = self.___ex.scrollView
    self.historyScrollView = self.___ex.historyScrollView
    self.backBtn = self.___ex.backBtn
end

function DreamBattleMainView:start()
    self.createHomeBtn:regOnButtonClick(function ()
        if self.onCreateBtnClick then
            self.onCreateBtnClick()
        end
    end)
    self.findHomeBtn:regOnButtonClick(function ()
        res.PushDialog("ui.controllers.dreamLeague.dreamBattle.DreamBattleRoomFindCtrl", self.dreamBattleMainModel)
    end)
    self.historyBtn:regOnButtonClick(function ()
        if self.onHistoryBtnClick then
            self.onHistoryBtnClick()
        end
    end)
    self.refreshBtn:regOnButtonClick(function ()
        if self.onRefreshBtnClick then
            self.onRefreshBtnClick()
        end
    end)
    self.backBtn:regOnButtonClick(function ()
        if self.onBackBtnClick then
            self.onBackBtnClick()
        end
    end)
end

function DreamBattleMainView:InitView(dreamBattleMainModel)
    self.dreamBattleMainModel = dreamBattleMainModel
    self.scrollView:InitView(dreamBattleMainModel:GetRoomData())
    self:InitMainContent(false)
end

-- 参数为是否是历史记录界面
function DreamBattleMainView:InitMainContent(isHistory)
    GameObjectHelper.FastSetActive(self.backBtn.gameObject, isHistory)
    GameObjectHelper.FastSetActive(self.historyBtn.gameObject, not isHistory)
    GameObjectHelper.FastSetActive(self.refreshBtn.gameObject, not isHistory)
    GameObjectHelper.FastSetActive(self.historyScrollView.gameObject, isHistory)
    GameObjectHelper.FastSetActive(self.scrollView.gameObject, not isHistory)
    GameObjectHelper.FastSetActive(self.findHomeBtn.gameObject, not isHistory)
end

return DreamBattleMainView
