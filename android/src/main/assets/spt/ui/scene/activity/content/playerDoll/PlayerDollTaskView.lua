local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local PlayerDollTaskView = class(unity.base)
function PlayerDollTaskView:ctor()
--------Start_Auto_Generate--------
    self.closeBtn = self.___ex.closeBtn
    self.scrollViewSpt = self.___ex.scrollViewSpt
--------End_Auto_Generate----------
end

function PlayerDollTaskView:start()
    DialogAnimation.Appear(self.transform, nil)
    self.closeBtn:regOnButtonClick(function()
        self:Close()
    end)
end

function PlayerDollTaskView:InitView(playerDollModel)
    self.playerDollModel = playerDollModel
    local itemDatas = self.playerDollModel:GetCountRewardListSorted()
    self.scrollViewSpt:InitView(itemDatas, self.playerDollModel)
end

function PlayerDollTaskView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

return PlayerDollTaskView
