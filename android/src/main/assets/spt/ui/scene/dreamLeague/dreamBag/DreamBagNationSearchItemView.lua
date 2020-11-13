local LuaButton = require("ui.control.button.LuaButton")

local DreamBagNationSearchItemView = class(LuaButton)

function DreamBagNationSearchItemView:ctor()
    self.super.ctor(self)
    self.title = self.___ex.title
    self.selectTitle = self.___ex.selectTitle
end

function DreamBagNationSearchItemView:InitView(data)
    local textTitle = lang.trans("first_letter_team", data.firstLetter)
    self.title.text = textTitle
    self.selectTitle.text =  textTitle
end

return DreamBagNationSearchItemView
