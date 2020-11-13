local BaseCtrl = require("ui.controllers.BaseCtrl")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local TreasureDialogCtrl = class(BaseCtrl, "TreasureDialogCtrl")

TreasureDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/TreasureDialog.prefab"

function TreasureDialogCtrl:AheadRequest(eventModel)
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local response = req.greenswardAdventureViewCell(row, col)
    if api.success(response) then
        local data = response.val
        eventModel:InitWithProtocolReward(data)
    end
end

function TreasureDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view.onStartClick = function() self:StartClick() end
end

function TreasureDialogCtrl:Refresh(eventModel)
    TreasureDialogCtrl.super.Refresh(self)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
end


function TreasureDialogCtrl:StartClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row = self.eventModel:GetRow()
            local col = self.eventModel:GetCol()
            local response = req.greenswardAdventureTrigger(row, col)
            if api.success(response) then
                local data = response.val
                local base = data.base or {}
                local ret = data.ret or {}
                local map = ret.map or {}
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshEventData(map)
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
                CongratulationsPageCtrl.new(ret.cellResult.contents)
                self.view.closeDialog()
            end
        end)
    end
end

return TreasureDialogCtrl
