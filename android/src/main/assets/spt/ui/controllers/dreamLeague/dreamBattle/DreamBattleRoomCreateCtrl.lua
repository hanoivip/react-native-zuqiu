local DreamBattleRoomCreateModel = require("ui.models.dreamLeague.dreamBattle.DreamBattleRoomCreateModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamBattleRoomCreateCtrl = class(BaseCtrl)

DreamBattleRoomCreateCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamBattleRoomCreateCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBattle/DreamBattleRoomCreate.prefab"

function DreamBattleRoomCreateCtrl:AheadRequest()
    local response = req.dreamLeagueRoomNew()
    if api.success(response) then
        local data = response.val
        self.dreamBattleRoomCreateModel = DreamBattleRoomCreateModel.new()
        self.dreamBattleRoomCreateModel:InitWithProtocol(data)
    end
end

function DreamBattleRoomCreateCtrl:Init()

end

function DreamBattleRoomCreateCtrl:Refresh()
    DreamBattleRoomCreateCtrl.super.Refresh(self)
    self:InitView()
end

function DreamBattleRoomCreateCtrl:InitView()
    self.view.onCreateBtnClick = function () self:OnCreateBtnClick() end
    self.view.onTipBtnClick = function () self:OnTipBtnClick() end
    self.view:InitView(self.dreamBattleRoomCreateModel)
end

function DreamBattleRoomCreateCtrl:OnTipBtnClick()
    res.PushDialog("ui.controllers.dreamLeague.tipButton.DreamLeagueRoomCtrl")
end

function DreamBattleRoomCreateCtrl:OnCreateBtnClick()
    local roomId = self.view.roomTypeDropdown.captionText.text
    local matchId = self.view.gameDropdown.captionText.text

    local roomList = self.dreamBattleRoomCreateModel:GetRoomList()
    roomId = roomList[roomId]

    local matchInfoList = self.dreamBattleRoomCreateModel:GetTodayMatchTxtList()
    matchId = matchInfoList[matchId]

    local nationList = self.dreamBattleRoomCreateModel:GetNationListByMatchId(matchId)

    local usedDcids = self.dreamBattleRoomCreateModel:GetUsedDcids()

    res.PushDialog("ui.controllers.dreamLeague.dreamBattle.DreamBattleRoomJoinCtrl", nationList, matchId, roomId, usedDcids)
    self.view:Close()
end

return DreamBattleRoomCreateCtrl