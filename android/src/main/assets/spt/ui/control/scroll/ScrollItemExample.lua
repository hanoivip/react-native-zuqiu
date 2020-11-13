local LuaButton = require("ui.control.button.LuaButton")
local ScrollItem = class(LuaButton)

function ScrollItem:ctor()
    self.super.ctor(self)
    self.itemText = self.___ex.itemText
end

function ScrollItem:init(str)
    self.data = str
    self.itemText.text = tostring(str)
end

function ScrollItem:start()
    self:regOnButtonClick(function (eventData)
        dump(self:getIndex())
    end)
end

return ScrollItem
