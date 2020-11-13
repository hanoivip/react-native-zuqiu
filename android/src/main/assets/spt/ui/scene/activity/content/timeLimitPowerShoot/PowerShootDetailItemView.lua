local GameObjectHelper = require("ui.common.GameObjectHelper")
local PowerShootDetailItemView = class()

function PowerShootDetailItemView:ctor()
    self.titleTxt = self.___ex.titleTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
end

function PowerShootDetailItemView:InitView(treasureTypeContents)
    treasurePath = "Assets/CapstonesRes/Game/UI/Scene/Activties/TimeLimitPowerShoot/PowerShootRewardItem.prefab"
    res.ClearChildren(self.itemAreaTrans)
    for i,v in ipairs(treasureTypeContents) do
        local treasureObj, treasureSpt = res.Instantiate(treasurePath)
        local treasureType = v.quality or ""
        treasureObj.transform:SetParent(self.itemAreaTrans, false)
        treasureSpt:InitView(v)
        self.titleTxt.text = lang.trans("player_shoot_type" .. treasureType)
    end
end

return PowerShootDetailItemView
