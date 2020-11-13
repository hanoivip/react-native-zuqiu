local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TransportJournalView = class(unity.base)

function TransportJournalView:ctor()
    self.menuGroup = self.___ex.menuGroup
    self.closeBtn = self.___ex.closeBtn
    self.matchRecordscrollView = self.___ex.matchRecordscrollView
    self.matchSignScrollView = self.___ex.matchSignScrollView
    self.protectScrollView = self.___ex.protectScrollView
    self.warn = self.___ex.warn

    DialogAnimation.Appear(self.transform)
end

function TransportJournalView:start()
    self.closeBtn:regOnButtonClick(function ()
        self:Close()
    end)
end

function TransportJournalView:InitView(data)
    self.data = data
end

function TransportJournalView:InitMatchView()
    self.menuGroup:selectMenuItem("match")
    self.matchRecordscrollView:InitView(self.data.battle)
    GameObjectHelper.FastSetActive(self.matchRecordscrollView.gameObject, true)
    GameObjectHelper.FastSetActive(self.matchSignScrollView.gameObject, false)
    GameObjectHelper.FastSetActive(self.protectScrollView.gameObject, false)
    GameObjectHelper.FastSetActive(self.warn, true)
end

function TransportJournalView:InitSignView()
    self.menuGroup:selectMenuItem("sign")
    self.matchSignScrollView:InitView(self.data.markPlayers)
    GameObjectHelper.FastSetActive(self.matchSignScrollView.gameObject, true)
    GameObjectHelper.FastSetActive(self.matchRecordscrollView.gameObject, false)
    GameObjectHelper.FastSetActive(self.protectScrollView.gameObject, false)
    GameObjectHelper.FastSetActive(self.warn, true)
end

function TransportJournalView:InitProtectView()
    self.menuGroup:selectMenuItem("protect")
    self.protectScrollView:InitView(self.data.guardPlayer)
    GameObjectHelper.FastSetActive(self.protectScrollView.gameObject, true)
    GameObjectHelper.FastSetActive(self.matchRecordscrollView.gameObject, false)
    GameObjectHelper.FastSetActive(self.matchSignScrollView.gameObject, false)
    GameObjectHelper.FastSetActive(self.warn, false)
end

function TransportJournalView:RegOnMenuGroup(tag, func)
    if type(tag) == "string" and type(func) == "function" then
        self.menuGroup:BindMenuItem(tag, func)
    end
end

function TransportJournalView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function ()
            self.closeDialog()
        end)
    end
end

function TransportJournalView:onDestroy()

end

return TransportJournalView