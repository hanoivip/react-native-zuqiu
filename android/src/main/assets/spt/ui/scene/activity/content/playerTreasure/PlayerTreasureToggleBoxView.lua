local GameObjectHelper = require("ui.common.GameObjectHelper")

local PlayerTreasureToggleBoxView = class(unity.base)

function PlayerTreasureToggleBoxView:ctor()
    self.content = self.___ex.content
    self.cancelBtn = self.___ex.cancelBtn
    self.confirmBtn = self.___ex.confirmBtn
    self.close = self.___ex.close
    self.toggleSelect = self.___ex.toggleSelect
    self.toggle = self.___ex.toggle
    self.messageBox = self.___ex.messageBox
end

function PlayerTreasureToggleBoxView:InitView()
    self.isSelect = false
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.cancelBtn:regOnButtonClick(function()
        if type(self.cancleFunc) == "function" then
            self.cancleFunc()
        end
        self:Close()
    end)
    self.confirmBtn:regOnButtonClick(function()
        if type(self.confirmFunc) == "function" then
            self.confirmFunc(self.isSelect)
        end
        self:Close()
    end)
    self.toggle:regOnButtonClick(function()
        self.isSelect = not self.isSelect
        GameObjectHelper.FastSetActive(self.toggleSelect, self.isSelect)
        if type(self.confirmFunc) == "function" then
            self.toggleSelectFunc(self.isSelect)
        end
    end)
    GameObjectHelper.FastSetActive(self.toggleSelect, self.isSelect)
end

function PlayerTreasureToggleBoxView:Close()
    if type(self.closeDialog) == "function" then
        self.closeDialog()
    end
    self.isSelect = false
end

function PlayerTreasureToggleBoxView:ShowToggleBox(content, confirmFunc, cancleFunc, toggleSelectFunc)
    self.content.text = content
    self.cancleFunc = cancleFunc
    self.confirmFunc = confirmFunc
    self.toggleSelectFunc = toggleSelectFunc
end

return PlayerTreasureToggleBoxView
