local BaseCtrl = require("ui.controllers.BaseCtrl")
local GreenswardItemMapModel = require("ui.models.greensward.item.GreenswardItemMapModel")

local MysticHintRcvDialogCtrl = class(BaseCtrl, "MysticHintRcvDialogCtrl")

MysticHintRcvDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Prop/MysticHintRcvDialog.prefab"

MysticHintRcvDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MysticHintRcvDialogCtrl:ctor(greenswardBuildModel, contents)
    MysticHintRcvDialogCtrl.super.ctor(self)
end

function MysticHintRcvDialogCtrl:Init(greenswardBuildModel, contents)
    self.buildModel = greenswardBuildModel
    self.contents = contents
    self.view:InitView(greenswardBuildModel, contents)
    if not table.isEmpty(self.contents) then
        GreenswardItemMapModel.new():UpdateItemsFromRewards(self.contents)
    end
end

function MysticHintRcvDialogCtrl:Refresh(greenswardBuildModel, contents)
    MysticHintRcvDialogCtrl.super.Refresh(self)
    self.view:RefreshView()
end

return MysticHintRcvDialogCtrl
