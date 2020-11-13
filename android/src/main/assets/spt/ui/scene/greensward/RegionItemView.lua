local AdventureRegion = require("data.AdventureRegion")
local RegionColorConfig = require("ui.scene.greensward.RegionColorConfig")
local RegionItemView = class(unity.base)

function RegionItemView:ctor()
--------Start_Auto_Generate--------
    self.regionImg = self.___ex.regionImg
    self.regionTxt = self.___ex.regionTxt
--------End_Auto_Generate----------
    self.regionGradient = self.___ex.regionGradient
end

function RegionItemView:InitView(region, parentRect)
    local region = tostring(region)
    local regionName = AdventureRegion[region].regionName
    self.regionTxt.text = regionName
    local imgPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Common/Region_" .. region .. ".png"
    self.regionImg.overrideSprite = res.LoadRes(imgPath)
    res.ClearChildren(parentRect)
    self.transform:SetParent(parentRect, false)
    RegionColorConfig.SetGradientColor(self.regionGradient, region)
end

return RegionItemView
