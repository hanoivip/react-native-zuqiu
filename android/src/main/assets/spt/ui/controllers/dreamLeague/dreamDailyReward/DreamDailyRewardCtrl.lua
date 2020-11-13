local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamDailyRewardModel = require("ui.models.dreamLeague.dreamDailyReward.DreamDailyRewardModel")

local DreamDailyRewardCtrl = class(BaseCtrl, "DreamDailyRewardCtrl")

DreamDailyRewardCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamDailyReward/DreamDailyReward.prefab"

function DreamDailyRewardCtrl:ctor()
    self.model = DreamDailyRewardModel.new()
end

function DreamDailyRewardCtrl:Init()
    self.view:InitView(self.model)
end


function DreamDailyRewardCtrl:Refresh()
    DreamDailyRewardCtrl.super.Refresh(self)
end

function DreamDailyRewardCtrl:GetStatusData()
end

return DreamDailyRewardCtrl