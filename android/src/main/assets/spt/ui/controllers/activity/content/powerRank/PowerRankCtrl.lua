local Timer = require('ui.common.Timer')
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local DialogManager = require("ui.control.manager.DialogManager")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")

local PowerRankCtrl = class(ActivityContentBaseCtrl)

function PowerRankCtrl:BindBtns()
    self.view.clickHelp = function() self:OnHelpClick() end
    self.view.clickReward = function() self:OnClickReward() end
    self.view.clickRefresh = function() self:OnClickRefresh() end
    self.view.refreshContent = function() self:RefreshContent() end
end

function PowerRankCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self:BindBtns()
end

function PowerRankCtrl:OnHelpClick()
    local msg = {lang.transstr("power_rank_tips")}
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Activties/Explore/ExploreRuleBoard.prefab", "camera", false, true)
    dialogcomp.contentcomp:InitText(msg)
end

function PowerRankCtrl:OnClickReward()
    self.view:coroutine(function()
        local response = req.activityReceiveOpenServerPowerRank()
        if api.success(response) then
            local data = response.val
            self.activityModel:SetGainState(false)
            CongratulationsPageCtrl.new(data)
            self.view:InitView(self.activityModel)
        end
    end)
end

function PowerRankCtrl:OnClickRefresh()
    if tonumber(cache.powerLeftTime) >= 0.5 then
        DialogManager.ShowToast(lang.trans("activity_power_timer", math.ceil(cache.powerLeftTime)))
        return
    end
    clr.coroutine(function()
        local response = req.activityRefreshOpenServerPowerRank()
        if api.success(response) then
            local data = response.val
            self.activityModel:SetRankData(data)
            self.view:RefreshContent(self.activityModel)
            self:DestroyTimer()
            self.residualTimer = Timer.new(30, function(time)
                cache.powerLeftTime = time
            end)
        end
    end)
end

function PowerRankCtrl:OnEnterScene()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)
    self.view:coroutine(function()
        self.view:ShowDisplayArea(false)
        local response = req.activityGetOpenServerPowerRank()
        if api.success(response) then
            local data = response.val
            self.activityModel:SetRankData(data)
            self.view:ShowDisplayArea(true)
            self.view:InitView(self.activityModel)
        end
    end)
end

function PowerRankCtrl:RefreshContent()
    self.view:coroutine(function()
        self.view:ShowDisplayArea(false)
        local response = req.activityGetOpenServerPowerRank()
        if api.success(response) then
            local data = response.val
            self.activityModel:SetRankData(data)
            self.view:ShowDisplayArea(true)
            self.view:InitView(self.activityModel)
        end
    end)
end

function PowerRankCtrl:DestroyTimer()
    if self.residualTimer ~= nil then
        self.residualTimer:Destroy()
    end
end

return PowerRankCtrl
