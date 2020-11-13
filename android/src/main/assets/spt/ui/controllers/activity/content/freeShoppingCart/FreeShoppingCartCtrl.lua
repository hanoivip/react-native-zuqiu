local EventSystem = require("EventSystem")
local SimpleIntroduceModel = require("ui.models.common.SimpleIntroduceModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local FreeShoppingCartCtrl = class(ActivityContentBaseCtrl)

function FreeShoppingCartCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self:RegBtnEvent()
    self.view:InitView(self.activityModel)
end

-- 按钮事件注册
function FreeShoppingCartCtrl:RegBtnEvent()
    self.view.onGetDayReward = function() self:GetDayRewardClick() end
    self.view.onGetFreeReward = function() self:OnGetFreeRewardClick() end
end

-- 领取每日的免费奖励
function FreeShoppingCartCtrl:GetDayRewardClick()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    local periodId = self.activityModel:GetPeriodId()
    self.view:coroutine(function()
        local response = req.freeShoppingCartReceiveFree(periodId)
        if api.success(response) then
            local data = response.val
            self.activityModel:SetReceiveDayRewardInfo(data)
            CongratulationsPageCtrl.new(data.contents)
            self.view:InitFreeRewardArea()
        end
    end)
end

-- 选择每日的奖励
function FreeShoppingCartCtrl:OnChooseReward(rewardId)
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    local periodId = self.activityModel:GetPeriodId()
    self.view:coroutine(function()
        local response = req.freeShoppingCartChoose(periodId, rewardId)
        if api.success(response) then
            local data = response.val
            self.activityModel:SetChooseRewardInfo(data)
            self.view:PlayAnim()
            self.view:InitDayChooseArea()
        end
    end)
end

-- 领取最终的奖励
function FreeShoppingCartCtrl:OnGetFreeRewardClick()
    local isTimeInActivity = self.activityModel:IsTimeInActivity()
    if not isTimeInActivity then
        return
    end
    local receive = self.activityModel:GetReceive()
    if receive then
        DialogManager.ShowToastByLang("have_received")
        return
    end
    local isChooseReward = self.activityModel:IsChooseReward()
    if not isChooseReward then
        DialogManager.ShowToastByLang("free_shopping_none_reward")
        return
    end
    local periodId = self.activityModel:GetPeriodId()
    self.view:coroutine(function()
        local response = req.freeShoppingCartReceive(periodId)
        if api.success(response) then
            local data = response.val
            self.activityModel:SetFreeRewardInfo(data)
            CongratulationsPageCtrl.new(data.contents)
            self.view:InitDayChooseArea()
        end
    end)
end

function FreeShoppingCartCtrl:RunOutOfTime()
    self.activityModel:SetRunOutOfTime()
end

function FreeShoppingCartCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("FreeShoppingCart_ChooseReward", self, self.OnChooseReward)

end

function FreeShoppingCartCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("FreeShoppingCart_ChooseReward", self, self.OnChooseReward)
end

return FreeShoppingCartCtrl
