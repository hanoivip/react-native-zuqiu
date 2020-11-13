local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local EventSystem = require("EventSystem")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local RewardDataCtrl = require("ui.controllers.common.RewardDataCtrl")
local TimeLimitStageShopTaskModel = require("ui.models.activity.timeLimitStageShop.TimeLimitStageShopTaskModel")

local TimeLimitStageShopCtrl = class(ActivityContentBaseCtrl)

function TimeLimitStageShopCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.view.runOutOfTime = function() self:RunOutOfTime() end
    self.view.onTaskClick = function() self:OnTaskClick() end
    self.view.onOpenOneBoxClick = function() self:OnOpenBoxClick(1) end
    self.view.onOpenFiveBoxClick = function() self:OnOpenBoxClick(5) end
    self.playerInfoModel = PlayerInfoModel.new()
    self.view:InitView(self.activityModel)
end

function TimeLimitStageShopCtrl:OnRefresh()
    self.view:OnRefresh(self.activityModel)
end

function TimeLimitStageShopCtrl:OnTaskClick()
    if self.activityModel:IsTimeInActivity() then
        self.view:coroutine(function()
            local response = req.activityStageShopGetTaskInfo()
            if api.success(response) then
                local data = response.val
                local taskModel = TimeLimitStageShopTaskModel.new()
                taskModel:InitWithProtocol(data)
                local ctrlPath = "ui.controllers.activity.content.timeLimitStageShop.TimeLimitStageShopTaskCtrl"
                res.PushDialog(ctrlPath, taskModel)
            end
        end)
    else
        DialogManager.ShowToastByLang("visit_endInfo")
    end
end

function TimeLimitStageShopCtrl:OnOpenBoxClick(count)
    if self.activityModel:IsTimeInActivity() then
        local maxBuyCount = self.activityModel:GetMaxBuyCount()
        local storeTicketCount = self.activityModel:GetStoreTicketCount()
        local ticketCnt = self.activityModel:GetTicketCnt()
        local countFix = count
        if count > 1 then
            countFix = maxBuyCount
        end
        local needTicket = countFix * storeTicketCount
        if ticketCnt < needTicket then
            local title = lang.trans("tips")
            local content = lang.trans("stage_shop_add_ticket")
            DialogManager.ShowConfirmPop(title, content, function() self:OnTaskClick() end)
            return
        end
        self:Buy(count)
    else
        DialogManager.ShowToastByLang("visit_endInfo")
    end
end

function TimeLimitStageShopCtrl:Buy(count)
    local storeType = self.activityModel:GetCurStoreType()
    self.view:coroutine(function()
        local response = req.activityStageShopBuyItem(storeType, count)
        if api.success(response) then
            local data = response.val
            self.view:AnimStart()
            coroutine.yield(WaitForSeconds(3))
            if data.contents then
                self.view:AnimReward(data.itemIds)
                local reward = RewardDataCtrl.CombineReward(data.contents)
                coroutine.yield(WaitForSeconds(1))
                CongratulationsPageCtrl.new(reward)
                self.view.currentEventSystem.enabled = true
                self.activityModel:InitStoreData(data.store)
                self:RefreshStageShopKey(data.ticketCnt)
                self.view:InitView(self.activityModel)
            end
        end
    end)
end

function TimeLimitStageShopCtrl:RefreshStageShopKey(keyCount)
    self.view:RefreshKey(keyCount)
    self.activityModel:RefreshKeyCount(keyCount)
end

function TimeLimitStageShopCtrl:RewardClosed()
    self.view:AnimEnd()
end

function TimeLimitStageShopCtrl:RunOutOfTime()
    self.activityModel:SetRunOutOfTime()
end

function TimeLimitStageShopCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("CongratulationsPageClosed", self, self.RewardClosed)
    EventSystem.AddEvent("RefreshStageShopKey", self, self.RefreshStageShopKey)
end

function TimeLimitStageShopCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("CongratulationsPageClosed", self, self.RewardClosed)
    EventSystem.RemoveEvent("RefreshStageShopKey", self, self.RefreshStageShopKey)
end

return TimeLimitStageShopCtrl