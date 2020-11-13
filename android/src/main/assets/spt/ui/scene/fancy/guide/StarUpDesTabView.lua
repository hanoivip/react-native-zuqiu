local LuaButton = require("ui.control.button.LuaButton")

local StarUpDesTabView = class(LuaButton, "StarUpDesTabView")

function StarUpDesTabView:ctor()
    StarUpDesTabView.super.ctor(self)
--------Start_Auto_Generate--------
    self.tabName1Txt = self.___ex.tabName1Txt
    self.tabName2Txt = self.___ex.tabName2Txt
--------End_Auto_Generate----------
end

function StarUpDesTabView:InitView(quality)
    local name = lang.transstr("itemList_quality")
    if quality == 1 then
        name = "A" .. name
    elseif quality == 2 then
        name = "S" .. name
    elseif quality == 3 then
        name = "SS" .. name
    end
    self.tabName1Txt.text = tostring(name)
    self.tabName2Txt.text = tostring(name)
end

return StarUpDesTabView
