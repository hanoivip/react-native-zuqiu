local BaseCtrl = require("ui.controllers.BaseCtrl")
local HeroHallRuleModel = require("ui.models.heroHall.rule.HeroHallRuleModel")

local HeroHallRuleCtrl = class(BaseCtrl, "HeroHallRuleCtrl")

HeroHallRuleCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/HeroHall/Rule/Prefabs/HeroHallRule.prefab"

HeroHallRuleCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function HeroHallRuleCtrl:ctor()
    HeroHallRuleCtrl.super.ctor(self)
end

function HeroHallRuleCtrl:Init()
end

function HeroHallRuleCtrl:Refresh()
    HeroHallRuleCtrl.super.Refresh(self)
    self.model = HeroHallRuleModel.new()
    self.view:InitView(self.model)
end

return HeroHallRuleCtrl