local UnityEngine = clr.UnityEngine
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DropdownView = class(unity.base)

function DropdownView:ctor()
    self.letter = self.___ex.letter
    self.sign = self.___ex.sign
    self.btnLetter = self.___ex.btnLetter
    self.btnLetter:regOnButtonClick(function()
        self:OnDropdownSelect()
    end)
end

function DropdownView:OnDropdownSelect()
    if self.onDropdownSelect then 
        self:ShowBoxState(true)
        self.onDropdownSelect(self.key)
    end
end

function DropdownView:InitView(key, desc, dropdownKey)
    self.key = key
    self.letter.text = tostring(desc)
    local hasSelect = tobool(key == dropdownKey)
    self:ShowBoxState(hasSelect)
end

function DropdownView:ShowBoxState(hasSelect)
    self.letter.color = hasSelect and Color(0.98, 0.92, 0.275, 1) or Color.white
    GameObjectHelper.FastSetActive(self.sign, hasSelect)
end

return DropdownView