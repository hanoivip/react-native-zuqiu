local BaseCtrl = require("ui.controllers.BaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local GreenswardMoraleDialogCtrl = class(BaseCtrl, "GreenswardMoraleDialogCtrl")

GreenswardMoraleDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Main/BuyMorale.prefab"

GreenswardMoraleDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardMoraleDialogCtrl:Init(buildModel)
    self.buildModel = buildModel
    self.view:InitView(buildModel)
    self.view.onMoraleBuyClick = function() self:MoraleBuyClick() end
    self.view.onVipClick = function(lvl) self:VipClick(lvl) end
    self.view.onCancelClick = function() self:CancelClick() end
end

function GreenswardMoraleDialogCtrl:VipClick(lvl)
    res.PushDialog("ui.controllers.charge.ChargeAndVIPCtrl","vip", lvl + 1)
    self.view:Close()
end

function GreenswardMoraleDialogCtrl:CancelClick()
    self.view:Close()
end

function GreenswardMoraleDialogCtrl:MoraleBuyClick()
    local adventureBaseData = self.buildModel:GetAdventureBaseData()
    local moraleBuyNum = self.buildModel:GetMoraleBuyNum()
    local costDiamond = adventureBaseData.purchaseMoralePrice[moraleBuyNum + 1]
    CostDiamondHelper.CostDiamond(costDiamond, self.view, function()
        self:BuyMorale()
    end)
end

function GreenswardMoraleDialogCtrl:BuyMorale()
    self.view:coroutine(function()
        local response = req.greenswardAdventureMoraleBuy()
        if api.success(response) then
            local data = response.val
            self.buildModel:SetMoraleBuyNum(data.buyMorale)
            local content = data.contents or {}
            if next(content) then
                CongratulationsPageCtrl.new(content)
                self.buildModel:AddMoraleNum(content.morale)
            end
            self.view:InitView(self.buildModel)
            self.buildModel:RefreshEventInfo()
            local cost = data.cost
            if cost then
                local playerInfoModel = self.buildModel:GetPlayerInfo()
                playerInfoModel:CostDetail(cost)
            end
        end
    end)
end

return GreenswardMoraleDialogCtrl