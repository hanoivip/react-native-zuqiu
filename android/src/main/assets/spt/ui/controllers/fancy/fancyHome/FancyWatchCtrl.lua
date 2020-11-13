local BaseCtrl = require("ui.controllers.BaseCtrl")
local FancyWatchCtrl = class(BaseCtrl, "FancyWatchCtrl")
local GuideManager = require("ui.controllers.playerGuide.GuideManager")
FancyWatchCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Fancy/FancyHome/FancyWatch.prefab"

function FancyWatchCtrl:Refresh(fancyGroupModel)
    self.fancyGroupModel = fancyGroupModel
    self:InitView()
    GuideManager.Show(self)
end

function FancyWatchCtrl:InitView()
    self.view:InitView(self.fancyGroupModel)
end

return FancyWatchCtrl