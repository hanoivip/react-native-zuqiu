local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ArenaStoreModel = require("ui.models.arena.store.ArenaStoreModel")
local ItemsMapModel = require("ui.models.ItemsMapModel")
local OptionRewardCtrl = class(BaseCtrl, "OptionRewardCtrl")

OptionRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/ItemList/OptionReward.prefab"

OptionRewardCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function OptionRewardCtrl:Refresh(itemModel, num)
    self.itemModel = itemModel
    self.view:InitView(itemModel, num)
end

function OptionRewardCtrl:GetStatusData()
    return self.itemModel
end

return OptionRewardCtrl