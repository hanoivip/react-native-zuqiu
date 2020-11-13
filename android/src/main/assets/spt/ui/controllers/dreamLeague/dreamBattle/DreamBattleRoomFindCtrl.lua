local BaseCtrl = require("ui.controllers.BaseCtrl")
local DreamBattleRoomFindCtrl = class(BaseCtrl)

DreamBattleRoomFindCtrl.dialogStatus = {
    touchClose = false,
    withShadow = true,
    unblockRaycast = false,
}

DreamBattleRoomFindCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/DreamLeague/DreamBattle/DreamBattleRoomFind.prefab"

function DreamBattleRoomFindCtrl:AheadRequest()

end

function DreamBattleRoomFindCtrl:Init(dreamBattleMainModel)
    self.dreamBattleMainModel = dreamBattleMainModel
end

function DreamBattleRoomFindCtrl:Refresh()
    DreamBattleRoomFindCtrl.super.Refresh(self)
    self:InitView()
end

function DreamBattleRoomFindCtrl:GetStatusData()
    return self.dreamBattleMainModel
end

function DreamBattleRoomFindCtrl:InitView()
    self.view.onConfirmBtnClick = function () self:OnConfrimBtnClick() end
    self.view:InitView()
end

function DreamBattleRoomFindCtrl:OnConfrimBtnClick()
    clr.coroutine(function ()
        local roomNum = self.view.roomNum.text
        local roomId = self.view.findroomNum
        if roomId and next(roomId) then
            for k, v in pairs(roomId) do
                if v then
                    roomId = k
                end
            end
        else
            roomId = nil
        end

        local response = req.dreamLeagueRoomList(tonumber(roomId), roomNum)
        if api.success(response) then
            self.dreamBattleMainModel:SetRoomData(response.val.roomList)
            self.view:Close()
        end
    end)
end

return DreamBattleRoomFindCtrl