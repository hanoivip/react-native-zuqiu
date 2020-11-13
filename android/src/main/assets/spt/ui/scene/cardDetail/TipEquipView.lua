local UnityEngine = clr.UnityEngine
local RapidBlurEffect = clr.RapidBlurEffect
local Camera = UnityEngine.Camera
local GameObjectHelper = require("ui.common.GameObjectHelper")
local TipEquipView = class(unity.base)

function TipEquipView:ctor()
    self.areaHole = self.___ex.areaHole
    self.areaBorder = self.___ex.areaBorder
    self.btnClick = self.___ex.btnClick
    self.tips = self.___ex.tips
end

function TipEquipView:InitView(itemDetailModel)
    local sourceTable = itemDetailModel:GetEquipSource()
    local sourceNums = table.nums(sourceTable)
    GameObjectHelper.FastSetActive(self.areaHole, sourceNums > 0)
    GameObjectHelper.FastSetActive(self.areaBorder, sourceNums > 0)
    self.tips.text = lang.trans("tip_equip1")
end

function TipEquipView:start()
    local rapidBlurEffect = Camera.main.gameObject:GetComponent(RapidBlurEffect)
    if rapidBlurEffect then
        rapidBlurEffect.enabled = false
    end
    self.btnClick:regOnButtonClick( function()
        if type(self.closeDialog) == 'function' then
            self.closeDialog()
        end
    end)
end

return TipEquipView
