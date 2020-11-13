local GameObjectHelper = require("ui.common.GameObjectHelper")
local LuaButton = require("ui.control.button.LuaButton")
local CarnivaTabView = class(LuaButton)

function CarnivaTabView:ctor()
    self.super.ctor(self)
    self.normalObj = self.___ex.normalObj
    self.selectObj = self.___ex.selectObj
    self.normalText = self.___ex.normalText
    self.selectText = self.___ex.selectText
    self.redPoint = self.___ex.redPoint
end

function CarnivaTabView:InitView(data)
    self.data = data
    self:BuildPage()
end

function CarnivaTabView:BuildPage()
    if self.data ~= nil then
        self.normalText.text = self.data.name
        self.selectText.text = self.data.name
        GameObjectHelper.FastSetActive(self.redPoint, self.data.redPointCounter > 0)
    end
end

function CarnivaTabView:ChangeButtonState(isSelect)
    GameObjectHelper.FastSetActive(self.selectObj, isSelect)
    GameObjectHelper.FastSetActive(self.normalObj, not isSelect)
end

return CarnivaTabView