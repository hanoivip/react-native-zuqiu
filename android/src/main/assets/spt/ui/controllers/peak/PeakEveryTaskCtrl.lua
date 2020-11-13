local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local MatchLoader = require("coregame.MatchLoader")
local PlayerDetailCtrl = require("ui.controllers.playerDetail.PeakPlayerDetailCtrl")
local BaseCtrl = require("ui.controllers.BaseCtrl")
local PeakEveryTaskModel = require("ui.models.peak.PeakEveryTaskModel")

local PeakEveryTaskCtrl = class(BaseCtrl)

PeakEveryTaskCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/Peak/PeakEveryTask.prefab"

PeakEveryTaskCtrl.dialogStatus = {
    touchClose = true,
    withShadow = true,
    unblockRaycast = false,
}

function PeakEveryTaskCtrl:AheadRequest()
    local response = req.peakDailyTaskInfo()
    if api.success(response) then
        local data = response.val
        self.peakEveryTaskModel = PeakEveryTaskModel.new()
        self.peakEveryTaskModel:InitWithProtocol(data)
    end
end

function PeakEveryTaskCtrl:Init()
    self.view:InitView(self.peakEveryTaskModel)

    self.view:RegOnMenuGroup("all", function ()
        self:SwitchMenu("all")
    end)
    self.view:RegOnMenuGroup("challenge", function ()
        self:SwitchMenu("challenge")
    end)
    self.view:RegOnMenuGroup("win", function ()
        self:SwitchMenu("win")
    end)
end

function PeakEveryTaskCtrl:Refresh()
    PeakEveryTaskCtrl.super.Refresh(self)
    self:SwitchMenu("all")
end

function PeakEveryTaskCtrl:SwitchMenu(tag)
    if tag == "all" then
        self.view:InitAllTaskView()
    elseif tag == "challenge" then
        self.view:InitChallengeTaskView()
    elseif tag == "win" then
        self.view:InitWinTaskView()
    end
end

function PeakEveryTaskCtrl:RefreshView()
    local response = req.peakDailyTaskInfo()
    if api.success(response) then
        local data = response.val
        self.peakEveryTaskModel:InitWithProtocol(data)
        self:SwitchMenu(self.peakEveryTaskModel:GetTag())
    end
end

function PeakEveryTaskCtrl:OnEnterScene()
    EventSystem.AddEvent("Refresh_Peak_Every_Task", self, self.RefreshView)
end

function PeakEveryTaskCtrl:OnExitScene()
    EventSystem.RemoveEvent("Refresh_Peak_Every_Task", self, self.RefreshView)
end


return PeakEveryTaskCtrl