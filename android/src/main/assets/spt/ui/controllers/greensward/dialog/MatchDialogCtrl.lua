local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local MatchDialogCtrl = class(BaseCtrl, "MatchDialogCtrl")

MatchDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/MatchDialog.prefab"

MatchDialogCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function MatchDialogCtrl:Init(matchModel, greenswardBuildModel)
    self.greenswardBuildModel = greenswardBuildModel
    self.matchModel = matchModel
    self.view.closeClick = function() self:Close() end
    self.view:InitView(matchModel, greenswardBuildModel)
	local itemContents = matchModel:GetItemContents()
	if itemContents then
		CongratulationsPageCtrl.new(itemContents)
	end
end

function MatchDialogCtrl:Close()
    local passContent = self.matchModel:GetPassContents()
    if passContent then
        res.PushDialog("ui.controllers.greensward.dialog.ChapterRewardCtrl", self.matchModel, self.greenswardBuildModel)
    else
        self.matchModel:ClearMatch()
    end
end

return MatchDialogCtrl