local BaseCtrl = require("ui.controllers.BaseCtrl")
local HeroHallImproveModel = require("ui.models.heroHall.improve.HeroHallImproveModel")

local HeroHallImproveCtrl = class(BaseCtrl, "HeroHallImproveCtrl")

HeroHallImproveCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HeroHall/Improve/Prefabs/HeroHallImprove.prefab"

HeroHallImproveCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function HeroHallImproveCtrl:ctor()
    HeroHallImproveCtrl.super.ctor(self)
end

function HeroHallImproveCtrl:Init(improveList)
end

function HeroHallImproveCtrl:Refresh(improveList)
    HeroHallImproveCtrl.super.Refresh(self)
    self.model = HeroHallImproveModel.new()
    self.model:InitWithProtocol(improveList)
    self.view:InitView(self.model)
end

return HeroHallImproveCtrl