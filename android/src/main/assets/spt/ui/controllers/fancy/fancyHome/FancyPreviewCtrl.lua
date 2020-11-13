local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local FancyPreviewCtrl = class(BaseCtrl, "FancyPreviewCtrl")
FancyPreviewCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyHome/FancyPreview.prefab"

--_type  1是商店 2是卡組界面 3是背包界面
function FancyPreviewCtrl:Refresh(_type, card)
    self._type = _type
	self.card = card
    self:InitView()
end

function FancyPreviewCtrl:InitView()
    self.view:InitView(self._type, self.card)
end

return FancyPreviewCtrl