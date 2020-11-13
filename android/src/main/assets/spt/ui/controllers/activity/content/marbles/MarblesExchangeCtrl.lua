local EventSystem = require("EventSystem")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MarblesExchangeModel = require("ui.models.activity.marbles.MarblesExchangeModel")
local BaseCtrl = require("ui.controllers.BaseCtrl")

local MarblesExchangeCtrl = class(BaseCtrl)

MarblesExchangeCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/Marbles/MarblesExchangeBoard.prefab"

function MarblesExchangeCtrl:AheadRequest(marblesModel)
    local periodId = marblesModel:GetPeriodId()
    local response = req.marblesGetExchangeInfo(periodId)
    if api.success(response) then
        local data =response.val
        self.model = MarblesExchangeModel.new(marblesModel)
        self.model:InitWithProtocol(data)
    end
end

function MarblesExchangeCtrl:Init()
    self.view.getExchangeReward = function(exchangeId) self:OnGetExchangeReward(exchangeId) end
    self.view:InitView(self.model)
end

function MarblesExchangeCtrl:OnGetExchangeReward(exchangeId)
    self.view:coroutine(function()
        local periodId = self.model:GetPeriodId()
        local response = req.marblesExchange(periodId, exchangeId)
        if api.success(response) then
            local val = response.val
            CongratulationsPageCtrl.new(val.contents)
            EventSystem.SendEvent("Marbles_ItemsChanged", val.items)
            self.model:RefreshData(val)
            self.view:RefreshContent()
        end
    end)
end

function MarblesExchangeCtrl:OnChargeRefresh()
    self.view:Close()
end

return MarblesExchangeCtrl
