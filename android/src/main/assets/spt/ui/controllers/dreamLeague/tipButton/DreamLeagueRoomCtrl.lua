local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamLeagueRoomCtrl = class(BaseCtrl)

DreamLeagueRoomCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamLeagueRoom/DreamLeagueRoom.prefab"

DreamLeagueRoomCtrl.dialogStatus = {
    touchClose = false,
    withShadow = false,
    unblockRaycast = false,
}

function DreamLeagueRoomCtrl:Refresh(channel, callback)
    self.view.closeCallback = callback
    self.view:Init()
end

function DreamLeagueRoomCtrl:OnExitScene()
    self.view:OnExitScene()
end

return DreamLeagueRoomCtrl