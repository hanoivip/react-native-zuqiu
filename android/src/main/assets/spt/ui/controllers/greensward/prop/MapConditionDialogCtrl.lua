local TreasureMapModel = require("ui.models.greensward.prop.TreasureMapModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

-- 藏宝图道具，2类型面板ctrl，几块
local MapConditionDialogCtrl = class(BaseCtrl, "MapConditionDialogCtrl")

MapConditionDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/MapConditionDialog.prefab"

function MapConditionDialogCtrl:AheadRequest(greenswardBuildModel, greenswardItemModel)
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

function MapConditionDialogCtrl:Init(greenswardBuildModel, greenswardItemModel)
    self.view.onBtnRewardPreview = function() self:OnBtnRewardPreview() end
    self.view:InitView(self.buildModel, nil, self.treasureMapModel)
end

-- 点击宝藏预览
function MapConditionDialogCtrl:OnBtnRewardPreview()
    res.PushDialog("ui.controllers.greensward.prop.TreasurePreviewCtrl", self.buildModel, self.greenswardItemModel)
end

return MapConditionDialogCtrl
