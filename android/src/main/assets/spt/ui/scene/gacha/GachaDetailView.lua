local DialogAnimation = require("ui.control.dialog.DialogAnimation")
local GachaDetailView = class(unity.base)
local UnityEngine = clr.UnityEngine

function GachaDetailView:ctor()
    self.scrollView = self.___ex.scrollView
    self.close = self.___ex.close
    self.helpButton = self.___ex.helpButton
    self.contentData = {}
end

function GachaDetailView:start()
    self.close:regOnButtonClick(function()
        self:Close()
    end)
    self.helpButton:regOnButtonClick(function()
        self:Help()
    end)
    DialogAnimation.Appear(self.transform, nil)
end

function GachaDetailView:Close()
    if type(self.closeDialog) == "function" then
        DialogAnimation.Disappear(self.transform, nil, function()
            self.closeDialog()
        end)
    end
end

function GachaDetailView:Help()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Store/GachaRule.prefab", "camera", true, true)
end

function GachaDetailView:InitView(gachaModel)
    self.gachaModel = gachaModel    
end

return GachaDetailView
