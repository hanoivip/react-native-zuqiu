local BaseCtrl = require("ui.controllers.BaseCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local HonorPalaceModel = require("ui.models.honorPalace.HonorPalaceModel")

local TrophyRoomCtrl = class(BaseCtrl)

function TrophyRoomCtrl:ctor(pos)
    local trophyRoomdlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/HonorPalace/TrophyRoom.prefab", "camera", false, true)
    self.trophyRoomView = dialogcomp.contentcomp
    cache.setHonorChangePos(pos)
end

function TrophyRoomCtrl:InitView(honorPalaceModel)
    self.honorPalaceModel = honorPalaceModel
    self.trophyShowList = honorPalaceModel:GetTrophyShowList()
    self.trophyRoomView:InitView(honorPalaceModel)
    self.playerInfoModel = PlayerInfoModel.new()
end

function TrophyRoomCtrl.UseTrophy(trophyID, posIndex, refreshCallback)
    clr.coroutine(function()
        local response = req.useHonor(trophyID, posIndex)
        if api.success(response) then
            local data = response.val
            cache.setHonorShowData(data)
            refreshCallback()
        end
    end)
end

return TrophyRoomCtrl