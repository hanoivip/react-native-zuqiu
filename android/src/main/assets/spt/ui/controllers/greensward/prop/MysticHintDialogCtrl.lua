local BaseCtrl = require("ui.controllers.BaseCtrl")
local MysticHintDialogModel = require("ui.models.greensward.prop.MysticHintDialogModel")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")

local MysticHintDialogCtrl = class(BaseCtrl, "MysticHintDialogCtrl")

MysticHintDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/MysticHintDialog.prefab"

MysticHintDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MysticHintDialogCtrl:AheadRequest(greenswardBuildModel, greenswardItemModel)
    self.buildModel = greenswardBuildModel
    self.itemModel = greenswardItemModel
    self.itemId = self.itemModel:GetId()
    if self.view then
        self.view:ShowDisplayArea(false)
    end

    local response = req.greenswardAdventureMysticHint(self.itemId)
    if api.success(response) then
        local data = response.val
        if not self.model then
            self.model = MysticHintDialogModel.new()
            self.model:SetItemModel(self.itemModel)
            self.model:InitWithProtocol(data)
        end
        self.view:ShowDisplayArea(true)
    end
end

function MysticHintDialogCtrl:ctor(greenswardBuildModel, greenswardItemModel)
    MysticHintDialogCtrl.super.ctor(self)
end

function MysticHintDialogCtrl:Init(greenswardBuildModel, greenswardItemModel)
    self.view.onBtnIntroClick = function() self:OnBtnIntroClick() end
    self.view:InitView(self.model)
end

function MysticHintDialogCtrl:Refresh(greenswardBuildModel, greenswardItemModel)
    MysticHintDialogCtrl.super.Refresh(self)
    self.view:RefreshView(self.model)
end

function MysticHintDialogCtrl:OnBtnIntroClick()
    local simpleIntroduceModel = SimpleIntroduceModel.new(15, "AdventureHint")
    res.PushDialog("ui.controllers.common.SimpleIntroduceCtrl", simpleIntroduceModel)
end

return MysticHintDialogCtrl
