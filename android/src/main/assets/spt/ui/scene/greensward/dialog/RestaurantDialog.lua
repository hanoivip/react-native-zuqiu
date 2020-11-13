local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local RestaurantDialog = class(unity.base)

function RestaurantDialog:ctor()
--------Start_Auto_Generate--------
    self.titleTxt = self.___ex.titleTxt
    self.startBtn = self.___ex.startBtn
    self.effectAreaTrans = self.___ex.effectAreaTrans
--------End_Auto_Generate----------
    self.currencyItemPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Turntable/RewardCurrencyItem.prefab"
end

function RestaurantDialog:start()
	DialogAnimation.Appear(self.transform)
    self.startBtn:regOnButtonClick(function()
        self:OnStartClick()
    end)
end

function RestaurantDialog:Close()
    DialogAnimation.Disappear(self.transform, nil, self.closeDialog)
end

function RestaurantDialog:OnStartClick()
    if self.onStartClick then
        self.onStartClick()
    end
end

function RestaurantDialog:InitView(eventModel)
    self.eventModel = eventModel
    self.titleTxt.text = eventModel:GetEventName()
    local effectDisplay = eventModel:GetRestaurantEffectDisplay()
    for i, v in ipairs(effectDisplay) do
        local obj, spt = res.Instantiate(self.currencyItemPath)
        obj.transform:SetParent(self.effectAreaTrans, false)
        spt:InitView(v.contents, v.state)
    end

end

return RestaurantDialog
