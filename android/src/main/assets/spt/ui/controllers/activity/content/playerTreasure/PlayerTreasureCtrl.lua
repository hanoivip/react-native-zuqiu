local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Timer = require('ui.common.Timer')
local EventSystems = UnityEngine.EventSystems
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystem = require("EventSystem")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local PlayerTreasureTaskModel = require("ui.models.activity.playerTreasure.PlayerTreasureTaskModel")

local PlayerTreasureCtrl = class(ActivityContentBaseCtrl)

local OPEN_TIME = 1.5   -- 打开时间
local REFRESH_TIME = 1  -- 关闭时间
local WAIT_TIME = 0.5  -- 等待时间
local REFRESH_KEY = "dayTipsRefresh"  -- 每日提示刷新的关键字
local REDEEM_KEY = "dayTipsRedeem"  -- 每日提示开箱的关键字

function PlayerTreasureCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.view.clickbuyKey = function() self:OnBuyKeyClick(false) end
    self.view.clickHelp = function() self:OnHelpClick() end
    self.view.clickDetail = function() self:OnDetailClick() end
    self.view.clickRefreshNext = function() self:OnRefreshNexClick() end
    self.view.clickOpenTreasureTask = function() self:OnOpenTreasureTaskClick() end
    self.view.clickOpenAllBox = function() self:OnOpenAllBoxClick() end
    self.view.clickBoxCallBack = function(boxIndex) self:OnBoxClick(boxIndex) end
    self.view.resetCousume = function (func) self:ResetCousume(func) end
    self.currentEventSystem = EventSystems.EventSystem.current
end

function PlayerTreasureCtrl:InitView(isRefresh)
    if self.view then
        self.view:InitView(self.activityModel, isRefresh)
    end
end

function PlayerTreasureCtrl:OnBuyKeyClick(showTitle)
    res.PushDialog("ui.controllers.activity.content.playerTreasure.PlayerTreasureBuyKeyCtrl", self.activityModel, showTitle)
end

function PlayerTreasureCtrl:OnHelpClick()
    local msg = lang.trans("player_treasure_tips")
    local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureRuleBoard.prefab", "camera", true, true)
    dialogcomp.contentcomp:InitText(msg)
end

function PlayerTreasureCtrl:OnDetailClick()
    local treasureBonus = self.activityModel:GetAllTreasureBonus()
    res.PushDialog("ui.controllers.activity.content.playerTreasure.PlayerTreasureDetailCtrl", treasureBonus)
end

function PlayerTreasureCtrl:OnOpenTreasureTaskClick()
    self.view:coroutine(function()
        local period = self.activityModel:GetPeriod()
        local response = req.activityGetPlayerTreasureTaskInfo(period)
        if api.success(response) then
            local data = response.val
            data.period = period
            local playerTreasureTaskModel = PlayerTreasureTaskModel.new(data)
            res.PushDialog("ui.controllers.activity.content.playerTreasure.PlayerTreasureTaskCtrl", playerTreasureTaskModel)
        end
    end)
end

function PlayerTreasureCtrl:OnRefreshNexClick()
    local refreshPrice = self.activityModel:GetRefreshPrice()
    local content = lang.trans("time_limit_refresh_tips", refreshPrice)
    local confirmFunc = function()
        CostDiamondHelper.CostDiamond(refreshPrice, self.view, function() self:RefreshTreasure() end)
    end
    local state, cancleFunc, toggleSelectFunc = self:CheckTodaysTips(REFRESH_KEY)
    if not state then
        confirmFunc()
        return
    end
    self:ShowToggleBox(content, confirmFunc, cancleFunc, toggleSelectFunc)
end

function PlayerTreasureCtrl:RefreshTreasure()
    self.view:coroutine(function()
        local period = self.activityModel:GetPeriod()
        local dayTips = self.tipsState and self.tipsState[REFRESH_KEY]
        local response = req.activityRefreshPlayerTreasure(period, dayTips)
        if api.success(response) then
            self.currentEventSystem.enabled = false
            local data = response.val
            if type(data.cost) == "table" then
                local playerInfoModel = PlayerInfoModel.new()
                playerInfoModel:CostDetail(data.cost)
            end
            self.activityModel:ResetAvtivityData(data)
            self:InitView(true)
            EventSystem.SendEvent("TreasureItemHideItem")
            for i,v in ipairs(self.view.boxViewList) do
                v:RefreshBox()
            end
            unity.waitForNextEndOfFrame()
            unity.waitForNextEndOfFrame()
            EventSystem.SendEvent("TreasureItemSetAnimatorState", true)
            self.view.rewardScroll.verticalNormalizedPosition = 1
            coroutine.yield(WaitForSeconds(OPEN_TIME))
        end
        self.currentEventSystem.enabled = true
    end)
end

function PlayerTreasureCtrl:OnOpenAllBoxClick()
    local allNeedIndexs = self.activityModel:GetOpenAllIndex()
    local nowKeysCount = self.activityModel:GetKeysCount()
    local needKeyCount = #allNeedIndexs
    if nowKeysCount >= needKeyCount then
        local content = lang.trans("player_treasure_all_tips", needKeyCount, needKeyCount)
        local confirmFunc = function()
            self:OpenBox(allNeedIndexs)
        end
        local state, cancleFunc, toggleSelectFunc = self:CheckTodaysTips(REDEEM_KEY)
        if not state then
            confirmFunc()
            return
        end
        self:ShowToggleBox(content, confirmFunc, cancleFunc, toggleSelectFunc)
    else
        self:OnBuyKeyClick(true)
    end
end

function PlayerTreasureCtrl:OnBoxClick(boxIndex)
    if self.view.isActivityEnd then
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
    end
    local boxState = self.activityModel:GetBoxState(boxIndex)
    if boxState then
        DialogManager.ShowToast(lang.trans("settings_hasopen"))
    else
        local nowKeysCount = self.activityModel:GetKeysCount()
        if nowKeysCount >= 1 then
            local content = lang.trans("player_treasure_open_one")
            local confirmFunc = function()
                local openIndexs = {}
                table.insert(openIndexs, boxIndex)
                self:OpenBox(openIndexs)
            end
            local state, cancleFunc, toggleSelectFunc = self:CheckTodaysTips(REDEEM_KEY)
            if not state then
                confirmFunc()
                return
            end
            self:ShowToggleBox(content, confirmFunc, cancleFunc, toggleSelectFunc)
        else
            self:OnBuyKeyClick(true)
        end
    end
end

function PlayerTreasureCtrl:OpenBox(openIndexs)
    self.view:coroutine(function()
        local period = self.activityModel:GetPeriod()
        local dayTips = self.tipsState and self.tipsState[REDEEM_KEY]
        local response = req.activityRedeemPlayerTreasure(period, openIndexs, dayTips)
        if api.success(response) then
            self.currentEventSystem.enabled = false
            local data = response.val
            local newTreasureRedeemed = data.treasureRedeemed
            local reward = {}
            self.isNeedRefresh = false
            if data.status then
                data.treasureRedeemed = {}
                self.isNeedRefresh = true
            end
            self.activityModel:ResetAvtivityData(data)
            for i,v in ipairs(openIndexs) do
                self.view.boxViewList[v]:OpenBox()
            end
            coroutine.yield(WaitForSeconds(OPEN_TIME))
            self.rewardIndex = 1
            self.bonus = data.bonus
            self:ShowRewardOneByOne()
            coroutine.yield(WaitForSeconds(REFRESH_TIME))
        end
        self.currentEventSystem.enabled = true
    end)
end

function PlayerTreasureCtrl:DoIfActivityEnd()
    self:RefreshContent(false)
    self.OnBtnPlusSymbol = function()
        DialogManager.ShowToast(lang.trans("visit_endInfo"))
    end
end

function PlayerTreasureCtrl:CheckActivityEnd()
    if not self.isActivityActive then return end
    
    local deltaTimeValue = cache.getServerDeltaTimeValue()
    local serverTimeNow = tonumber(os.time()) + tonumber(deltaTimeValue)
    local beforeEndInterval = tonumber(self.pasterSplitModel:GetActivityEndTime()) - serverTimeNow
    if beforeEndInterval <= 0 then
        self.isActivityActive = false
        self:InitActTimeTip()
        return
    end

    if self.countDownTimer ~= nil then self.countDownTimer:Destroy() end
    self.countDownTimer = Timer.new(beforeEndInterval, function(time)
        if time <= 0 then
            self.isActivityActive = false
            self:InitActTimeTip()
        end
    end)
end

function PlayerTreasureCtrl:ShowRewardOneByOne()
    if self.rewardIndex and self.bonus[self.rewardIndex] then
        local contents = self.bonus[self.rewardIndex]
        CongratulationsPageCtrl.new(contents)
    end
end

function PlayerTreasureCtrl:OnCongratulationsPageClosed()
    self.rewardIndex = tonumber(self.rewardIndex) + 1
    if self.rewardIndex and self.bonus and self.bonus[self.rewardIndex] then
        self:ShowRewardOneByOne()
    else
        self.view:coroutine(function()
            self.currentEventSystem.enabled = false
            self:InitView(self.isNeedRefresh)
            if self.isNeedRefresh and self.view.boxViewList then
                EventSystem.SendEvent("TreasureItemHideItem")
                coroutine.yield(WaitForSeconds(WAIT_TIME))
                self.view.rewardScroll.verticalNormalizedPosition = 1
                for i,v in ipairs(self.view.boxViewList) do
                    v:RefreshBox()
                end
                EventSystem.SendEvent("TreasureItemSetAnimatorState", true)
                self.isNeedRefresh = false
            end
            self.bonus = nil
            self.rewardIndex = 0
            coroutine.yield(WaitForSeconds(REFRESH_TIME))
            self.currentEventSystem.enabled = true
        end)
    end
end

-- 根据每个弹窗的key来返回是否弹出今天的弹窗
-- tipsKey 弹窗的key
-- state 今天是否弹窗
-- cancleFunc 取消的回调
-- toggleSelectFunc  选中和取消选中的回调
function PlayerTreasureCtrl:CheckTodaysTips(tipsKey)
    local state = self.activityModel:GetDayTipsState(tipsKey)
    if not self.tipsState then
        self.tipsState = {}
    end
    self.tipsState[tipsKey] = state
    local toggleSelectFunc = function(seleceState)
        self.tipsState[tipsKey] = not seleceState
    end
    local cancleFunc = function()
        self.tipsState[tipsKey] = false
    end
    return state, cancleFunc, toggleSelectFunc
end

function PlayerTreasureCtrl:OnChargeRefresh()
    self:ResetCousume(function() self:InitView() end)
end

function PlayerTreasureCtrl:OnEnterScene()
    EventSystem.AddEvent("CongratulationsPageClosed", self, self.OnCongratulationsPageClosed)
    EventSystem.AddEvent("Charge_Success", self, self.OnChargeRefresh)
    if self.view.isActivityEnd then
        DialogManager.ShowToast(lang.trans("time_limit_growthPlan_desc5"))
    end
    self:InitView()
    self.view:OnEnterScene()
end

function PlayerTreasureCtrl:OnExitScene()
    EventSystem.RemoveEvent("CongratulationsPageClosed", self, self.OnCongratulationsPageClosed)
    EventSystem.RemoveEvent("Charge_Success", self, self.OnChargeRefresh)
    self.view:OnExitScene()
end

function PlayerTreasureCtrl:ShowToggleBox(content, confirmFunc, cancleFunc, toggleSelectFunc)
    local toggleBoxPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/PlayerTreasure/PlayerTreasureToggleBox.prefab"
    local dialog, dialogcomp = res.ShowDialog(toggleBoxPath, "camera", false, true)
    local toggleView = dialogcomp.contentcomp
    toggleView:InitView()
    toggleView:ShowToggleBox(content, confirmFunc, cancleFunc, toggleSelectFunc)
end

return PlayerTreasureCtrl
