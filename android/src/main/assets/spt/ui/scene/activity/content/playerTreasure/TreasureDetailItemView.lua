local GameObjectHelper = require("ui.common.GameObjectHelper")
local TreasureDetailItemView = class()

function TreasureDetailItemView:ctor()
    self.titleTxt = self.___ex.titleTxt
    self.itemAreaTrans = self.___ex.itemAreaTrans
end

function TreasureDetailItemView:InitView(treasureTypeContents)
    treasurePath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/TreasureRewardItem.prefab"
    res.ClearChildren(self.itemAreaTrans)
    for i,v in ipairs(treasureTypeContents) do
        local treasureObj, treasureSpt = res.Instantiate(treasurePath)
        local treasureType = v.treasureType
        treasureObj.transform:SetParent(self.itemAreaTrans, false)
        treasureSpt:InitView(v)
        self.titleTxt.text = lang.trans("player_treasure_type" .. treasureType)
    end
end

return TreasureDetailItemView