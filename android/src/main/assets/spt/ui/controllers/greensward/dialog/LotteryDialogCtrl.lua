local BaseCtrl = require("ui.controllers.BaseCtrl")
local LotteryDialogCtrl = class(BaseCtrl, "LotteryDialogCtrl")

LotteryDialogCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Dialog/Lottery/LotteryDialog.prefab"

function LotteryDialogCtrl:AheadRequest(eventModel)
    local row, col = eventModel:GetRow(), eventModel:GetCol()
    local response = req.greenswardAdventureOpenLottery(row, col)
    if api.success(response) then
        local data = response.val
        eventModel:InitWithProtocolLottery(data)
    end
end

function LotteryDialogCtrl:Init(eventModel)
    self.eventModel = eventModel
    self.view:InitView(eventModel)
    self.view.openClick = function() self:OnOpenClick() end
end

function LotteryDialogCtrl:OnOpenClick()
    local notEnough = self.eventModel:ConsumeNotEnough()
    if not notEnough then
        self.view:coroutine(function()
            local row, col = self.eventModel:GetRow(), self.eventModel:GetCol()
            local response = req.greenswardAdventureTrigger(row, col)
            if api.success(response) then
                local data = response.val
                --TODO cost
                local base = data.base or { }
                local map = data.ret and data.ret.map or { }
                local buildModel = self.eventModel:GetBuildModel()
                buildModel:RefreshEventData(map)
                buildModel:RefreshBaseInfo(base)
                self.eventModel:HandleEvent(data)
                self.eventModel:SetRewardData(data.ret)
                self.view:RefreshRewardArea()
            end
        end)
    end
end

return LotteryDialogCtrl
