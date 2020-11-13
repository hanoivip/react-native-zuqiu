local LuaButton = require("ui.control.button.LuaButton")

local CompleteTabItemView = class(LuaButton, "CompleteTabItemView")

function CompleteTabItemView:ctor()
    CompleteTabItemView.super.ctor(self)
    --------Start_Auto_Generate--------
    self.tabName1Txt = self.___ex.tabName1Txt
    self.tabName2Txt = self.___ex.tabName2Txt
--------End_Auto_Generate----------
end

function CompleteTabItemView:InitView(regionData, tabBtnGroupSpt, clickCallBack)
    local regionID = regionData.regionID
    self.tabName1Txt.text = regionData.regionName
    self.tabName2Txt.text = regionData.regionName
    tabBtnGroupSpt.menu[regionID] = self
    tabBtnGroupSpt:BindMenuItem(regionID, function() clickCallBack(regionID) end)
end

return CompleteTabItemView
