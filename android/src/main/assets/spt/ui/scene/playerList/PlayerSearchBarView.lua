local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local PlayerSearchBarView = class(LuaButton)

function PlayerSearchBarView:ctor()
    PlayerSearchBarView.super.ctor(self)
    self.down = self.___ex.down
    self.up = self.___ex.up
    self.beSelected = self.___ex.beSelected
    self.text = self.___ex.text
    self.isMultiSelect = false
end

function PlayerSearchBarView:start()
    self:regOnButtonClick(function()
        self:OnBtnSelect()
    end)
end

function PlayerSearchBarView:InitView(desc, isMultiSelect)
    self.isMultiSelect = isMultiSelect
    self.text.text = desc
end

local function SetState(selectMap, isSelect)
    for k, v in pairs(selectMap) do
        GameObjectHelper.FastSetActive(v, isSelect)
    end
end

function PlayerSearchBarView:ChangeState(isSelect)
    if not self.isMultiSelect then 
        self:onPointEventHandle(not isSelect)
    end
    GameObjectHelper.FastSetActive(self.beSelected, isSelect)
    SetState(self.up, not isSelect)
end

function PlayerSearchBarView:OnBtnSelect()
    if self.clickSearch then 
        self.clickSearch()
    end
end

return PlayerSearchBarView