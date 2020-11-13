local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardStarLibModel = require("ui.models.greensward.star.GreenswardStarLibModel")

local GreenswardStarLibCtrl = class(BaseCtrl, "GreenswardStarLibCtrl")

GreenswardStarLibCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Star/GreenswardStarLib.prefab"

GreenswardStarLibCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function GreenswardStarLibCtrl:ctor()
    GreenswardStarLibCtrl.super.ctor(self)
end

function GreenswardStarLibCtrl:Init()
    self.model = GreenswardStarLibModel.new()
    self.view:InitView(self.model)
end

function GreenswardStarLibCtrl:Refresh()
    GreenswardStarLibCtrl.super.Refresh(self)
    self.view:RefreshView()
end

return GreenswardStarLibCtrl
