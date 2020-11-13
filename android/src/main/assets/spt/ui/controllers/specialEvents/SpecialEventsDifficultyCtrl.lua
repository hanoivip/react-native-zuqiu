local InfoBarCtrl = require("ui.controllers.common.InfoBarCtrl")
local MenuBarCtrl = require("ui.controllers.common.MenuBarCtrl")
local SpecialEventsMainModel = require("ui.models.specialEvents.SpecialEventsMainModel")
local MatchLoader = require("coregame.MatchLoader")
local CongratulationsPageCtrl = require("ui.controllers.congratulations.CongratulationsPageCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local SpecialEventsPlayerTeamsModel = require("ui.models.specialEvents.SpecialEventsPlayerTeamsModel")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local DialogManager = require("ui.control.manager.DialogManager")
local NewYearOutPutPosType = require("ui.scene.activity.content.worldBossActivity.NewYearOutPutPosType")
local NewYearCongratulationsPageCtrl = require("ui.controllers.activity.content.worldBossActivity.NewYearCongratulationsPageCtrl")

local BaseCtrl = require("ui.controllers.BaseCtrl")
local SpecialEventsDifficultyCtrl = class(BaseCtrl)

SpecialEventsDifficultyCtrl.viewPath = "Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/SpecialEventsDifficulty.prefab"

function SpecialEventsDifficultyCtrl:Init()
    self.view:RegOnInfoBarDynamicLoad(
        function(child)
            self.infoBarCtrl = InfoBarCtrl.new(child, self)
            self.infoBarCtrl:RegOnBtnBack(
                function()
                    res.PopScene()
                end
            )
        end
    )

    self.view.challengeButtonScript:regOnButtonClick(
        function()
            if self.view.challengeButton.interactable then
                self:OnChallengeButtonClick()
            end
        end
    )

    self.view.editButtonScript:regOnButtonClick(
        function()
            self:OnEditButtonClick()
        end
    )

    self.view.recordButtonScript:regOnButtonClick(
        function()
            self:OnRecordButtonClick()
        end
    )

    self.view.onMenuItemClick = function(value, index) self:OnMenuItemClick(value, index) end
end

function SpecialEventsDifficultyCtrl:IsHaveMatchResult()
    local matchResultData = clone(cache.getMatchResult())
    --比赛的奖励是否已结算过
    if matchResultData and matchResultData.matchType == MatchConstants.MatchType.SPECIFIC then
        matchResultData = matchResultData.settlement
        --肯定只有一条结果
        if next(matchResultData.list) then
            for k, value in pairs(matchResultData.list) do
                self.model[self.selectedMatchIndex].winTimes = math.min(value.winTimes or 0, self.model[self.selectedMatchIndex].cumulativePass)
            end
        end
        --更新挑战次数
        if next(matchResultData.typeList) then
            for ik, ivalue in pairs(matchResultData.typeList) do
                for jk, jvalue in pairs(self.model) do
                    self.model[jk].times = ivalue.times
                end
            end
        end
    end
end

function SpecialEventsDifficultyCtrl:Refresh(eventId, model, selectedMatchIndex, mainModel)
    SpecialEventsDifficultyCtrl.super.Refresh(self)
    self.eventId = eventId
    if model then
        self.model = model
    end
    if selectedMatchIndex then
        self.selectedMatchIndex = selectedMatchIndex
         --通过赛事结果更新UI
        self:IsHaveMatchResult()
    end

    if mainModel then
        self.mainModel = mainModel
    end
    self:OnMatchOver()
    self.view:InitView(self.eventId, self.model, self.selectedMatchIndex)
    self.view.tabScrollView:scrollToCellImmediate(self.selectedMatchIndex)
    -- init view before response of specificUpdateMatch
    self.view:InitMatchView(self.model[self.selectedMatchIndex], self.selectedMatchIndex, 0)
    --强行清缓存数据
    self.view.menuButtonGroup.currentMenuTag = nil
    self.view.menuButtonGroup:selectMenuItem(self.selectedMatchIndex)
    self:OnMenuItemClick(self.model[self.selectedMatchIndex], self.selectedMatchIndex)
end

function SpecialEventsDifficultyCtrl:AheadRequest(eventId)
    self.eventId = eventId
    if not self.debugMode then
        local model, timestamp = cache.getSpecialEvents()
        assert(model)
        self.mainModel = model
        self.model = model:GetDifficulty(eventId)
        self.selectedMatchIndex = model:GetNextMatchIndex(eventId)
    else
        local respone = req.specificIndex()
        if api.success(respone) then
            local data = respone.val
            local model = SpecialEventsMainModel.new()
            model:InitWithProtocol(data)
            self.mainModel = model
            self.model = model:GetDifficulty(eventId)
            self.selectedMatchIndex = model:GetNextMatchIndex(eventId)
        end
    end
end

function SpecialEventsDifficultyCtrl:GetStatusData()
    return self.eventId, self.model, self.selectedMatchIndex, self.mainModel
end

function SpecialEventsDifficultyCtrl:OnEnterScene()
    self.view:OnEnterScene()
end

function SpecialEventsDifficultyCtrl:OnExitScene()
    self.view:OnExitScene()
end

function SpecialEventsDifficultyCtrl:OnMenuItemClick(value, index)
    self.matchId = value.matchId
    self.selectedMatchIndex = index
    clr.coroutine(
        function()
            local response = req.specificUpdateMatch(value.matchId)
            if api.success(response) then
                self.view:InitMatchView(value, index, response.val.power)
            end
        end
    )
end

function SpecialEventsDifficultyCtrl:OnChallengeButtonClick()
    if self.view.challengeButtonScript.sweep then
        local resDlg, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/SpecialEvents/ChallengeAndWipe.prefab", "camera", false, true)
        dialogcomp.contentcomp:init(
            function()
                clr.coroutine(
                    function()
                        local response = req.specificSweep(self.matchId)
                        if api.success(response) then
                            self:CollectMatchReward(response.val)
                        end
                    end
                )
            end,
            function()
                clr.coroutine(
                    function()
                        local response = req.specificGetTeam(self.eventId)
                        if api.success(response) then
                            local data = response.val
                            local playerTeamsModel = SpecialEventsPlayerTeamsModel.new()
                            playerTeamsModel:InitWithProtocol(data, self.eventId)

                            response = req.specificMatch(self.matchId)
                            if api.success(response) then
                                MatchInfoModel.GetInstance():SetMatchTeamData(playerTeamsModel.data)
                                MatchInfoModel.GetInstance().specialEventsMatchId = self.matchId

                                MatchLoader.startMatch(response.val)
                            end
                        end
                    end
                )
            end,
            self.view.challengeButtonScript.isVIP
        )
    else
        clr.coroutine(
            function()
                local response = req.specificGetTeam(self.eventId)
                if api.success(response) then
                    local data = response.val
                    local playerTeamsModel = SpecialEventsPlayerTeamsModel.new()
                    playerTeamsModel:InitWithProtocol(data, self.eventId)

                    response = req.specificMatch(self.matchId)
                    if api.success(response) then
                        MatchInfoModel.GetInstance():SetMatchTeamData(playerTeamsModel.data)
                        MatchInfoModel.GetInstance().specialEventsMatchId = self.matchId

                        MatchLoader.startMatch(response.val)
                    end
                end
            end
        )
    end
end


function SpecialEventsDifficultyCtrl:OnEditButtonClick()
    res.PushScene("ui.controllers.specialEvents.SpecialEventsFormationCtrl", self.matchId)
end

function SpecialEventsDifficultyCtrl:OnMatchOver()
    local matchResultData = cache.getMatchResult()
    if matchResultData == nil then
        return
    end

    MatchInfoModel.GetInstance():SetMatchTeamData(nil)
    MatchInfoModel.GetInstance().specialEventsMatchId = nil

    if matchResultData.hasSettle == false and matchResultData.matchType == MatchConstants.MatchType.SPECIFIC then
        matchResultData.hasSettle = true
        self:CollectMatchReward(matchResultData.settlement)
    end
    cache.setMatchResult(nil)
end

function SpecialEventsDifficultyCtrl:CollectMatchReward(data)
    if not data then
        return
    end

    if data.contents then
        CongratulationsPageCtrl.new(data.contents)
    end
    
    NewYearCongratulationsPageCtrl.new(data, NewYearOutPutPosType.SPECIFIC)
    -- update sp
    local playerInfoModel = PlayerInfoModel.new()
    playerInfoModel:SetStrength(data.sp or 0)

    -- update model
    local model, timestamp = cache.getSpecialEvents()
    assert(model)
    model:UpdateModel(data)
    self.model = model:GetDifficulty(self.eventId)
    self.selectedMatchIndex = model:GetNextMatchIndex(self.eventId)
end

function SpecialEventsDifficultyCtrl:OnRecordButtonClick()
    if
        self.mainModel.data.video and self.mainModel.data.video[tostring(self.matchId)] and
            type(self.mainModel.data.video[tostring(self.matchId)].latest) == "table" and
            #self.mainModel.data.video[tostring(self.matchId)].latest > 0
     then
        res.PushDialog("ui.controllers.specialEvents.SpecialEventsRecordCtrl", self.matchId)
    else
        DialogManager.ShowToast(lang.trans("special_events_no_video"))
    end
end

return SpecialEventsDifficultyCtrl
