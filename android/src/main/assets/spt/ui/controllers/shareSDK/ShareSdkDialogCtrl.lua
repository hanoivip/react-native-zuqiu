local DialogManager = require("ui.control.manager.DialogManager")
local ShareSdkDialogCtrl = class()

function ShareSdkDialogCtrl:ctor(title, text, imagePath)
    self.title = title
    self.text = text
    self.imagePath = imagePath
    self:Init()
end

function ShareSdkDialogCtrl:Init()
    self:OpenShareDialog()
end

function ShareSdkDialogCtrl:OpenShareDialog()
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/ShareSDK/ShareScreenshot.prefab", "camera", true, true)
    self.view = dialogcomp.contentcomp
    self.view:InitView(self.title, self.text, self.imagePath)
end

return ShareSdkDialogCtrl