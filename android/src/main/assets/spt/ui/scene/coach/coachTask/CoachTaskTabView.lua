local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local CoachTaskTabView = class(LuaButton)

function CoachTaskTabView:ctor()
    CoachTaskTabView.super.ctor(self)
    self.down = self.___ex.down
    self.up = self.___ex.up
    self.beSelected = self.___ex.beSelected
    self.isMultiSelect = false
end

local function SetState(selectMap, isSelect)
    for k, v in pairs(selectMap) do
        GameObjectHelper.FastSetActive(v, isSelect)
    end
end

function CoachTaskTabView:ChangeState(isSelect)
    if not self.isMultiSelect then 
        self:onPointEventHandle(not isSelect)
    end
    GameObjectHelper.FastSetActive(self.beSelected, isSelect)
    SetState(self.up, not isSelect)
end

return CoachTaskTabView