local UnityEngine = clr.UnityEngine
local WaitForSeconds = UnityEngine.WaitForSeconds
local ActivityContentBaseCtrl = require("ui.controllers.activity.content.ActivityContentBaseCtrl")
local ActivityListModel = require("ui.models.activity.ActivityListModel")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local MatchConstants = require("ui.scene.match.MatchConstants")
local ActivityRes = require("ui.scene.activity.ActivityRes")

local WorldBossActivityCtrl = class(ActivityContentBaseCtrl)

function WorldBossActivityCtrl:InitWithProtocol()
    self.view = self.contentPrefab:GetComponent(clr.CapsUnityLuaBehav)

    self.view.resetCousume = function (func) self:ResetCousume(func) end

    self.view.onJoinMatchClick = function (index) self:OnJoinMatchClick(index) end
    self.view.onGrab = function (reqCallBack, reqCallBackFail) self:OnGrab(reqCallBack, reqCallBackFail) end
    clr.coroutine(function()
        local response = req.activityWorldBossNPCInfo()
        if api.success(response) then
            self.activityModel:InitNPCData(response.val)
            self:MyAheadRequest()
        end
    end)
end

function WorldBossActivityCtrl:CheckHaveMatchResult()
    local matchResultData = clone(cache.getMatchResult())
    --比赛的奖励是否已结算过
    if matchResultData and matchResultData.matchType == MatchConstants.MatchType.WORLDBOSS then
        cache.setMatchResult(nil)
        if matchResultData.settlement.gift and next(matchResultData.settlement.gift) then
            CongratulationsPageCtrl.new(matchResultData.settlement.gift)
        end
    end
end

function WorldBossActivityCtrl:RefreshData()
    self:MyAheadRequest()
end

function WorldBossActivityCtrl:MyAheadRequest()
    clr.coroutine(function()
        local response = req.activityWorldBossInfo()
        if api.success(response) then
            self.activityModel:InitResponseData(response.val)
            --更一下数据
            self.view:InitView(self.activityModel)

            self.view:OnEnterScene()
        end
    end)
end

function WorldBossActivityCtrl:OnJoinMatchClick(index)
    res.PushDialog("ui.controllers.activity.content.worldBossActivity.WorldBossChallengeCtrl", self.activityModel:GetTeamData()[tonumber(index)], self.activityModel)
end

function WorldBossActivityCtrl:OnGrab(reqCallBack, reqCallBackFail)
    clr.coroutine(function()
        local response = req.activityWorldBossGrab()
        if api.success(response) then
            reqCallBack()
            clr.coroutine(function ()
                coroutine.yield(WaitForSeconds(0.1))
                CongratulationsPageCtrl.new(response.val.contents)
            end)
            local contents = response.val.contents
            if contents.d and tonumber(contents.d) > 0 then
                self:OpenGrabDesc(tonumber(contents.d))
            end
            self:RefreshData()
        else
            reqCallBackFail()
        end
    end)
end

local GrabResultResPath = "Assets/CapstonesRes/Game/UI/Scene/Activties/WorldBossActivity/WorldBossGrabResultBroad.prefab"
function WorldBossActivityCtrl:OpenGrabDesc(resultNum)
    local dialog, dialogcomp = res.ShowDialog(GrabResultResPath, "camera", false, true)
    self.dialogcomp = dialogcomp
    self.resultView = self.dialogcomp.contentcomp
    self.resultView:InitView(self.activityModel:GetGrabResultData(resultNum))
end

function WorldBossActivityCtrl:GoToMatch()
    self.view:OnExitScene()
end

function WorldBossActivityCtrl:OnEnterScene()
    EventSystem.AddEvent("WorldBossActivityCtrlRefreshData", self, self.RefreshData)
    EventSystem.AddEvent("WorldBossActivityGoToMatch", self, self.GoToMatch)
    self:CheckHaveMatchResult()
    self.view:OnEnterScene()
end

function WorldBossActivityCtrl:OnExitScene()
    EventSystem.RemoveEvent("WorldBossActivityCtrlRefreshData", self, self.RefreshData)
    EventSystem.RemoveEvent("WorldBossActivityGoToMatch", self, self.GoToMatch)
    self.view:OnExitScene()
end

return WorldBossActivityCtrl

