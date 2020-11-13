local BaseCtrl = require("ui.controllers.BaseCtrl")
local MusicManager = require("ui.control.manager.MusicManager")

local GachaAnimationCtrl = class(BaseCtrl)

GachaAnimationCtrl.viewPath = "Assets/CapstonesRes/Game/MatchScenes/Gacha/Gacha.unity"

function GachaAnimationCtrl:Refresh(contents)
    GachaAnimationCtrl.super.Refresh(self)
    self.contents = contents
    self.view:InitView(contents, function ()
        res.PopSceneWithoutCurrent()
        MusicManager.play()
    end)
end

return GachaAnimationCtrl
