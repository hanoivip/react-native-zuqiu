local BaseCtrl = require("ui.controllers.BaseCtrl")
local TreasurePreviewModel = require("ui.models.greensward.prop.TreasurePreviewModel")

local TreasurePreviewCtrl = class(BaseCtrl, "TreasurePreviewCtrl")

TreasurePreviewCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/TreasurePreview.prefab"

TreasurePreviewCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function TreasurePreviewCtrl:AheadRequest(greenswardBuildModel, greenswardItemModel)
    local response = req.greenswardAdventureTreasurePreview()
    if api.success(response) then
        if not self.model then
            self.model = TreasurePreviewModel.new()
        end
        self.model:InitWithProtocol(response.val or {})
        self.model:SetBuildModel(greenswardBuildModel)
        self.model:SetItemModel(greenswardItemModel)
        self.view:ShowDisplayArea(true)
    end
end

function TreasurePreviewCtrl:ctor(greenswardBuildModel, greenswardItemModel)
    self.buildModel = greenswardBuildModel
    TreasurePreviewCtrl.super.ctor(self)
end

function TreasurePreviewCtrl:Init(greenswardBuildModel, greenswardItemModel)
    self.view:InitView(self.model)
end

function TreasurePreviewCtrl:Refresh(greenswardBuildModel, greenswardItemModel)
    TreasurePreviewCtrl.super.Refresh(self)
    self.view:RefreshView()
end

return TreasurePreviewCtrl
