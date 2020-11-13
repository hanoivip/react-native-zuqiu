local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CurrencyType = require("ui.models.itemList.CurrencyType")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local TimeLimitPowerShootCtrl = class(ActivityContentBaseCtrl)

function TimeLimitPowerShootCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view.powerShootResetCousume = function(func) self:ResetCousume(func) end
    self.view.onShoot = function(sptData) self:OnShootClick(sptData) end
    self.view.runOutOfTime = function() self:RunOutOfTime() end
    self.view.startShootClick = function() self:OnStartShootClick() end
    self.view.onRefresh = function() self:OnRefreshShootClick() end
    self.view:InitView(self.activityModel)
    self.playerInfoModel = PlayerInfoModel.new()
    self.currentEventSystem = EventSystems.EventSystem.current
end

function TimeLimitPowerShootCtrl:OnRefresh()
    self.view:InitView(self.activityModel)
end

function TimeLimitPowerShootCtrl:OnShootClick(sptData)
    if self.activityModel:IsTimeInActivity() then
        local price = self.activityModel:GetCountPrice()
        local title = lang.trans("tips")
        local content = price .. lang.transstr("diamond")
        content = lang.transstr("recycle_tips", content, lang.transstr("training_shoot"))
        DialogManager.ShowConfirmPop(title, content, function()
            CostDiamondHelper.CostCurrency(price, nil, function() self:Buy(sptData) end, CurrencyType.Diamond)
        end)
    else
        DialogManager.ShowToastByLang("visit_endInfo")
    end
end

function TimeLimitPowerShootCtrl:OnStartShootClick()
    local subID = self.activityModel:GetSubID()
    self.view:coroutine(function()
        local response = req.powerShootStartShoot(subID)
        if api.success(response) then
            local data = response.val
            self.activityModel:RefreshDataList(data)
            self.view:ShootStartAnim()
        end
    end)
end

function TimeLimitPowerShootCtrl:OnRefreshShootClick()
    local price = self.activityModel:GetRefreshPrice()
    local title = lang.trans("tips")
    local content = price .. lang.transstr("diamond")
    content = lang.transstr("recycle_tips", content, lang.transstr("friends_add_refresh"))
    DialogManager.ShowConfirmPop(title, content, function()
        CostDiamondHelper.CostCurrency(price, nil, function() self:RefreshShoot() end, CurrencyType.Diamond)
    end)
end

function TimeLimitPowerShootCtrl:RefreshShoot()
    local subID = self.activityModel:GetSubID()
    self.view:coroutine(function()
        local response = req.powerShootRefresh(subID)
        if api.success(response) then
            local data = response.val
            self.activityModel:RefreshDataList(data)
            self.playerInfoModel:CostDetail(data.cost)
            self.view:ShootRefreshAnim()
            self:ResetCousume(function() self.view:RefreshContent() end)
        end
    end)
end

function TimeLimitPowerShootCtrl:Buy(spt)
    local subID = self.activityModel:GetSubID()
    self.view:coroutine(function()
        local response = req.powerShootShooting(subID, spt.pos)
        if api.success(response) then
            local data = response.val
            self.currentEventSystem.enabled = false
            self.activityModel:RefreshDataList(data)
            local reward = self.activityModel:GetContentData(spt.pos)
            spt:RefreshItemContent(reward.contents)
            self.view:ShootAnim(spt, data.contents)
            self.playerInfoModel:CostDetail(data.cost)
        end
    end)
end

-- 抽满Max_Count次自动刷新
function TimeLimitPowerShootCtrl:AutoRefreshShoot()
    local shootTimes = self.activityModel:GetBuyCount()
    if shootTimes >= self.activityModel.Max_Count then
        self:RefreshShoot()
    end
end

function TimeLimitPowerShootCtrl:RunOutOfTime()
    EventSystem.SendEvent("TimeLimitChainBox.RunOutOfTime")
    self.activityModel:SetRunOutOfTime()
end

function TimeLimitPowerShootCtrl:OnEnterScene()
    self.view:OnEnterScene()
    EventSystem.AddEvent("CongratulationsPageClosed", self, self.AutoRefreshShoot)
end

function TimeLimitPowerShootCtrl:OnExitScene()
    self.view:OnExitScene()
    EventSystem.RemoveEvent("CongratulationsPageClosed", self, self.AutoRefreshShoot)
end

return TimeLimitPowerShootCtrl
