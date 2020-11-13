local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamSelectPlayerCtrl = class(BaseCtrl)

DreamSelectPlayerCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamSelectionPlayer/DreamSelectPlayer.prefab"

DreamSelectPlayerCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

function DreamSelectPlayerCtrl:AheadRequest(roomId, pid)
    local response = req.dreamLeagueRoomPlayerCards(roomId, pid)
    if api.success(response) then
        self.dreamCardList = response.val.dreamCardList
    end
end

function DreamSelectPlayerCtrl:Init()
    DreamSelectPlayerCtrl.super.Init(self)
end

function DreamSelectPlayerCtrl:Refresh()
    self.view:InitView(self.dreamCardList)
end

return DreamSelectPlayerCtrl
