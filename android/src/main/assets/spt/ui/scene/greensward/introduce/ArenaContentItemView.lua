local ArenaContentItemView = class(unity.base)

function ArenaContentItemView:ctor()
--------Start_Auto_Generate--------
    self.arenaContentItemGo = self.___ex.arenaContentItemGo
    self.arenaTxt = self.___ex.arenaTxt
    self.minNumTxt = self.___ex.minNumTxt
    self.maxNumTxt = self.___ex.maxNumTxt
--------End_Auto_Generate----------
end

function ArenaContentItemView:InitView(regionData)
    self.arenaTxt.text = regionData.regionName
    self.minNumTxt.text = tostring(regionData.powerLow)
    self.maxNumTxt.text = tostring(regionData.powerHigh)
end

return ArenaContentItemView
