local OldPlayerContentBaseView = require("ui.scene.oldPlayer.OldPlayerContentBaseView")
local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local OldPlayerVerticalCommonView = class(OldPlayerContentBaseView)

function OldPlayerVerticalCommonView:ctor()
    OldPlayerVerticalCommonView.super.ctor(self)
end

function OldPlayerVerticalCommonView:InitView(contentData, ItemPath)
    self.ItemPath = ItemPath
    OldPlayerVerticalCommonView.super.InitView(self, contentData)
end

return OldPlayerVerticalCommonView
