local TreasureMapModel = require("ui.models.greensward.prop.TreasureMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

-- 藏宝图道具，1类型面板ctrl，整个地图
local MapAppointDialogCtrl = class(BaseCtrl, "MapAppointDialogCtrl")

MapAppointDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/MapAppointDialog.prefab"

function MapAppointDialogCtrl:AheadRequest(greenswardBuildModel, greenswardItemModel)
    self.buildModel = greenswardBuildModel
    self.greenswardItemModel = greenswardItemModel
    self.id = self.greenswardItemModel:GetId()
    if self.view then
        self.view:ShowDisplayArea(false)
    end

    local response = req.greenswardAdventureTreasureMap(self.id)
    if api.success(response) then
        local data = response.val
        if not self.treasureMapModel then
            self.treasureMapModel = TreasureMapModel.new()
            self.treasureMapModel:SetItemModel(self.greenswardItemModel)
            self.treasureMapModel:InitWithProtocol(data)
        end
        self.view:ShowDisplayArea(true)
    end
end

function MapAppointDialogCtrl:Init(greenswardBuildModel, greenswardItemModel)
    self.view.onBtnRewardPreview = function() self:OnBtnRewardPreview() end
    self.view:InitView(self.buildModel, nil, self.treasureMapModel)
end

-- 点击宝藏预览
function MapAppointDialogCtrl:OnBtnRewardPreview()
    res.PushDialog("ui.controllers.greensward.prop.TreasurePreviewCtrl", self.buildModel, self.greenswardItemModel)
end

return MapAppointDialogCtrl
