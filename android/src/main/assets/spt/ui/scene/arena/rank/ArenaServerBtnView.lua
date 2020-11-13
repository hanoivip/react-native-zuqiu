local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local ArenaServerBtnView = class(LuaButton)

function ArenaServerBtnView:ctor()
    ArenaServerBtnView.super.ctor(self)
    self.active = self.___ex.active
    self.normal = self.___ex.normal
end

function ArenaServerBtnView:start()
    self:regOnButtonClick(function()
        self:OnBtnSelect()
    end)
end

function ArenaServerBtnView:SetState(sign, isSelect)
    GameObjectHelper.FastSetActive(sign, isSelect)
end

function ArenaServerBtnView:ChangeState(isSelect)
    self:SetState(self.active, isSelect)
    self:SetState(sel.normal, not isSelect)
end

return ArenaServerBtnView