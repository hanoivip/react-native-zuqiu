local MatchLoader = require("coregame.MatchLoader")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local TurntableDialogCtrl = class(BaseCtrl, "LotteryDialogCtrl")

TurntableDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Turntable/TurntableDialog.prefab"


function TurntableDialogCtrl:AheadRequest(eventModel)
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local response = req.greenswardAdventureOpenWheel(row, col)
    if api.success(response) then
        local data = response.val
        eventModel:InitWithProtocolTurntable(data)
    end
end

function TurntableDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.onRollClick = function() self:RollClick() end
end

function TurntableDialogCtrl:RollClick()
    local remainCount = self.eventModel:GetRemainCount()
    if remainCount <= 0 then
        return
    end
    local hasRolling = self.eventModel:GetRollState()
    if hasRolling then
        return
    end
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
            local response = req.greenswardAdventureTrigger(row, col)
            if api.success(response) then
                local data = response.val
                local base = data.base or {}
                local ret = data.ret
                local map = data.ret and data.ret.map or {}
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshEventData(map)
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
                ret.pos = ret.pos + 1
                self.eventModel:RefreshWheelData(ret)
                self.view:OnRollAnim(ret)
            end
        end)
    end
end

function TurntableDialogCtrl:BuyOverClick()

end

return TurntableDialogCtrl