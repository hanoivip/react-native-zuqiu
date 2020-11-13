local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local EventSystems = UnityEngine.EventSystems
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local CostDiamondHelper = require("ui.common.CostDiamondHelper")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")

local TeamInvestCtrl = class(ActivityContentBaseCtrl)

function TeamInvestCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent("CapsUnityLuaBehav")
    self.playerInfoModel = PlayerInfoModel.new()
    self.currentEventSystem = EventSystems.EventSystem.current
    self.view.onRollClick = function() self:GetInvest() end
    self.view:InitView(self.activityModel)
end

function TeamInvestCtrl:OnRefresh()
    self.view:InitView(self.activityModel)
end

function TeamInvestCtrl:GetInvest()
    local playerVIP = self.playerInfoModel:GetVipLevel()
    local needVIP = self.activityModel:GetNeedVIPLevel()
    local isSlotFull = self.activityModel:IsSlotFull()
    local costDiamond = self.activityModel:GetConsumeDiamond()
    local remainTime = self.activityModel:GetRemainTime()

    if tonumber(playerVIP) < tonumber(needVIP) then
        DialogManager.ShowToastByLang("team_invest_vip")
        return
    end

    if isSlotFull then
        DialogManager.ShowToastByLang("team_invest_end")
        return
    end

    if remainTime <= 1 then
        DialogManager.ShowToastByLang("time_limit_growthPlan_desc5")
        return
    end

    CostDiamondHelper.CostDiamond(costDiamond, nil, function()
        self.view:PlayAnimRoll()
        self:OnRedeem()
    end)
end

function TeamInvestCtrl:OnRedeem()
    local costDiamond = self.activityModel:GetConsumeDiamond()
    self.view:coroutine(function()
        local period = self.activityModel:GetPeriod()
        local response = req.redeemTeamInvest(period)
        if api.success(response) then
            self.view:StartRolling()
            self.currentEventSystem.enabled = false
            local data = response.val
            coroutine.yield(WaitForSeconds(self.view.ROLL_TIME))
            self.activityModel:RefreshRedeemData(data)
            data.contents.d = data.contents.d + costDiamond
            local dStr = self.activityModel:ChangeInt2Str(data.contents.d)
            self.playerInfoModel.data.d = self.playerInfoModel.data.d - costDiamond
            self.view:StopRolling(dStr, data.contents)
        else
            self.currentEventSystem.enabled = true
        end
        self.view.rolling = false
    end)
end

function TeamInvestCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function TeamInvestCtrl:OnExitScene()
    self.view:OnExitScene()
end

return TeamInvestCtrl
