local GameObjectHelper = require("ui.common.GameObjectHelper")
local PlayerTreasureBoxView = class()

function PlayerTreasureBoxView:ctor()
    self.closeGo = {self.___ex.closeGo1}
    self.openGo = {self.___ex.openGo1}
    self.boxBtn = self.___ex.boxBtn
    self.animator = self.___ex.animator
end

function PlayerTreasureBoxView:InitView(index, state, clickCallBack)
    self.state = state
    for i,v in ipairs(self.openGo) do
        GameObjectHelper.FastSetActive(v, state)
    end
    for i,v in ipairs(self.closeGo) do
        GameObjectHelper.FastSetActive(v, not state)
    end
    if state then
        self:OpenState()
    else
        self:CloseBox()
    end
    self.boxBtn:regOnButtonClick(function()
        if type(clickCallBack) == "function" then
            clickCallBack(index)
        end
    end)
end

function PlayerTreasureBoxView:OpenBox()
    self.state = true
    self.animator:Play("PlayerTreasureBoxItemOpenAnimation")
end

function PlayerTreasureBoxView:CloseBox()
    self.state = false
    self.animator:Play("PlayerTreasureCloseAnimation")
end

function PlayerTreasureBoxView:RefreshBox()
    if self.state then
        self.animator:Play("PlayerTreasureBoxItemOpenReflashAnimation")
    else
        self.animator:Play("PlayerTreasureBoxItemReflashAnimation")
    end
    self.state = false
end

function PlayerTreasureBoxView:OpenState()
    self.state = true
    self.animator:Play("PlayerTreasureBoxItemOpenState")
end

return PlayerTreasureBoxView