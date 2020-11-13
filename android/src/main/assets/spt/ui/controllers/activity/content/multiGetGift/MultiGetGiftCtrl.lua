local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local MultiGetGiftCtrl = class(ActivityContentBaseCtrl)

function MultiGetGiftCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self:RegBtnEvent()
    self.view:InitView(self.activityModel)
end

-- 按钮事件注册
function MultiGetGiftCtrl:RegBtnEvent()
    self.view.getAllReward = function() self:GetAllRewardClick() end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
end

-- 选择每日的奖励
function MultiGetGiftCtrl:GetAllRewardClick()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    local giftRedPoint = self.activityModel:GetGiftRedPoint()
    if not giftRedPoint then
        DialogManager.ShowToastByLang("peak_not_recv_gift")
        return
    end
    local periodId = self.activityModel:GetPeriodId()
    self.view:coroutine(function()
        local response = req.multiGetGiftReceiveAllGift(periodId)
        if api.success(response) then
            local data = response.val
            local rewards = data.contents
            rewards[CurrencyType.DayGiftCoin] = data.coin
            CongratulationsPageCtrl.new(data.contents)
            self.activityModel:RefreshAllRewardData(data)
            self.view:InitDayGiftArea()
        end
    end)
end

function MultiGetGiftCtrl:RunOutOfTime()
    self.activityModel:SetRunOutOfTime()
end

function MultiGetGiftCtrl:OnEnterScene()
    self.view:OnEnterScene()
    --EventSystem.AddEvent("FreeShoppingCart_ChooseReward", self, self.OnChooseReward)

end

function MultiGetGiftCtrl:OnExitScene()
    self.view:OnExitScene()
    --EventSystem.RemoveEvent("FreeShoppingCart_ChooseReward", self, self.OnChooseReward)
end

return MultiGetGiftCtrl
