local BaseCtrl = require("ui.controllers.BaseCtrl")
local FeatureDetailCtrl = class(BaseCtrl)
FeatureDetailCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/CardDetail/Prefabs/Feature/CoachFeatureDetail.prefab"
FeatureDetailCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function FeatureDetailCtrl:Init(model)
    self.model = model
end

function FeatureDetailCtrl:Refresh()
    FeatureDetailCtrl.super.Refresh(self)
    self:InitView()
end

function FeatureDetailCtrl:GetStatusData()
    return self.model
end

function FeatureDetailCtrl:InitView()
    self.view:InitView(self.model)
end

return FeatureDetailCtrl
