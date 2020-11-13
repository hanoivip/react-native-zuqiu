local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")

local PlayerRecycleLabelItemView = class(LuaButton, "PlayerRecycleLabelItemView")

function PlayerRecycleLabelItemView:ctor()
    PlayerRecycleLabelItemView.super.ctor(self)
    self.btnUpGo = self.___ex.btnUpGo
    self.btnDownGo = self.___ex.btnDownGo
    self.txtLabel = self.___ex.txtLabel
    self.btnDisableGo = self.___ex.btnDisableGo
    self.isSelect = false
end

function PlayerRecycleLabelItemView:InitView(data)
    self.isSelect = false
    self.data = data
    self:InitButtonState()
    self.txtLabel.text = lang.trans(data.labelName)
end

function PlayerRecycleLabelItemView:InitButtonState()
    self:unselectBtn()
    self:onPointEventHandle(true)
end

function PlayerRecycleLabelItemView:SetSelect(isSelect)
    self.isSelect = isSelect
    self.isOpen = self.data.isOpen
    self.canUse = (not self.data.canUse) and (not isSelect)
    if self.data.isOpen then
        GameObjectHelper.FastSetActive(self.btnDisableGo, self.canUse or false)
        GameObjectHelper.FastSetActive(self.btnUpGo, not isSelect)
        GameObjectHelper.FastSetActive(self.btnDownGo, isSelect)
    else
        GameObjectHelper.FastSetActive(self.btnDisableGo, true)
        GameObjectHelper.FastSetActive(self.btnDownGo, false)
        GameObjectHelper.FastSetActive(self.btnUpGo, false)
    end
end

return PlayerRecycleLabelItemView
