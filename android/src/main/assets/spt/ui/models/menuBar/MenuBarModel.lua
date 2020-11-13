local EventSystem = require ("EventSystem")
local BaseMenuBarModel = require("ui.models.menuBar.BaseMenuBarModel")
local MenuBarModel = class(BaseMenuBarModel)

local resetState = false
function MenuBarModel:ctor(data)
    MenuBarModel.super.ctor(self)
    self.resetState = resetState
end

function MenuBarModel:Init(data)
    if not data then
        data = cache.getMenuBarData()
    end
    self.data = data
end

function MenuBarModel:InitWithProtocol(menuState)
    local data = {}
    data.menuState = menuState or BaseMenuBarModel.MenuState.Open
    cache.setMenuBarData(data)
    self:Init(data)
end

return MenuBarModel
