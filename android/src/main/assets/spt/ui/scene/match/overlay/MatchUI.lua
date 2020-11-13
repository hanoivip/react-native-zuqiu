local clrTable = clr.table
local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local Color = UnityEngine.Color

local String = clr.System.String
local DataProvider = clr.ActionLayer.DataProvider
local AthleteAction = clr.ActionLayer.AthleteAction
local GameHub = clr.GameHub
local ActionLayer = clr.ActionLayer
local ActionHashMap = ActionLayer.ActionHashMap
local ShootResult = ActionLayer.ShootResult

local FreezePopupsCtrl = require("ui.controllers.match.FreezePopupsCtrl")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local QuestInfoModel = require("ui.models.quest.QuestInfoModel")
local DemoMatchManager = require("coregame.DemoMatchManager")
local EnumType = require("coregame.EnumType")
local CustomEvent = require("ui.common.CustomEvent")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local LeagueInfoModel = require("ui.models.league.LeagueInfoModel")
local UISoundManager = require("ui.control.manager.UISoundManager")
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local RewardUpdateCacheModel = require("ui.models.common.RewardUpdateCacheModel")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ActionType = EnumType.ActionType
local MatchEventType = EnumType.MatchEventType
local ManualOperateType = EnumType.ManualOperateType

local MatchUI = class(unity.base)

function MatchUI:ctor()
    ___matchUI = self
    self.fightMenuManager = self.___ex.fightMenuManager

    self.leftScore = 0
    self.rightScore = 0
    self.playerStats = nil
    self.opponentStats = nil
    self.previousMatchEvent = nil
    self.ballOwnerId = nil

    self.playerManager = nil
    local playerManagerObject = GameObject.Find("/PlayerManager")
    if playerManagerObject then
        self.playerManager = res.GetLuaScript(playerManagerObject)
    end

    self.stadiumManager = nil
    local stadiumManagerObject = GameObject.Find("/StadiumManager")
    if stadiumManagerObject then
        self.stadiumManager = res.GetLuaScript(stadiumManagerObject)
    end

    self.screenEffectManager = nil
    local screenEffectManagerObject = GameObject.Find("/ScreenEffectManager")
    if screenEffectManagerObject then
        self.screenEffectManager = res.GetLuaScript(screenEffectManagerObject)
    end

    self.freezePopupsCtrl = FreezePopupsCtrl.new()

    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
    self.baseInfo = self.matchInfoModel:GetBaseInfo()

    self.inPenaltyShootOut = nil
end

function MatchUI:start()
    self:Init(self.playerTeamData.teamName, self.opponentTeamData.teamName)
    self.screenEffectManager:ApplyEffect("Default")
end

function MatchUI:FormatScore()
    return string.format("%d - %d", self.leftScore, self.rightScore)
end

function MatchUI:isPlayer(athleteId)
    if athleteId == nil then
        return false
    end
    if self.opponentTeamData then
        return athleteId < self.opponentTeamData.startId
    end
    return athleteId <= 11
end

function MatchUI:getAthlete(athleteId)
    if self.playerTeamData ~= nil and self.opponentTeamData ~= nil then
        local athlete = self:isPlayer(athleteId) and
        self.playerTeamData.athletes[athleteId] or
        self.opponentTeamData.athletes[athleteId - self.opponentTeamData.startId + 1]
        return athlete
    else
        -- Default value for debug
        return {
            name = athleteId > 11 and "opponent" .. athleteId - 11 or "player" .. athleteId,
            id = athleteId,
            number = athleteId,
            onfieldId = athleteId,
        }
    end
end

function MatchUI:getAthleteObject(onfieldId)
    local athleteObject = nil
    if onfieldId <= 10 then
        athleteObject = self.playerManager.players[onfieldId + 1].gameObject
    else
        athleteObject = self.playerManager.opponents[onfieldId - 10].gameObject
    end
    return athleteObject
end

function MatchUI:getTeam(athleteId)
    if self.playerTeamData ~= nil and self.opponentTeamData ~= nil then
        return athleteId < self.opponentTeamData.startId and self.playerTeamData or self.opponentTeamData
    end
    return {
        icon = "1000",
    }
end

function MatchUI:Init(leftTeam, rightTeam)
    self.fightMenuManager:InitialTeamName(leftTeam, rightTeam, self:FormatScore())
    self.fightMenuManager:InitialDisplayTime()
end

function MatchUI:onMatchStart()
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.SKIP_BUTTON, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.SKIP_BEGINNING, false)
end

local function isDeadBallEvent(matchEventType)
    return matchEventType ~= MatchEventType.NormalPlayOn
        and matchEventType ~= MatchEventType.PrepareToKickOff
        and matchEventType ~= MatchEventType.GameOver
end

function MatchUI:updateClock(frame, previousMatchEvent)
    self.fightMenuManager.displayTimeOffset = frame.matchInfo.displayTimeOffset
    self.fightMenuManager.stoppageTime = frame.matchInfo.stoppageTime
    if previousMatchEvent == MatchEventType.NontimedKickOff then
        self.fightMenuManager.isDisplayTimeStop = nil
    end
end

function MatchUI:updateMeshAndKit(toAthleteId)
    local updateMeshData = {}
    for i = 1, 11 do
        updateMeshData[i] = toAthleteId[i]
    end

    if self.playerManager then
        self.playerManager:updateMeshAndKit(updateMeshData)
    end
end

function MatchUI:updateSingleMeshAndKit(onfieldId, athleteId)
    self.playerManager:updateSingleMeshAndKit(onfieldId, athleteId)
end

function MatchUI:onMatchEvent(frame)
    self.fightMenuManager:EnableNoteButton()
    if frame.matchEvent == MatchEventType.NormalPlayOn then
        self.fightMenuManager:EnableAccelerateBtn()
    else
        self.fightMenuManager:DisableAccelerateBtn()
    end
    self.fightMenuManager:HideMatchAddTime()

    local stats = json.decode(frame.matchStatsJson)

    -- used for test scene, when MatchInfo == nil
    self.playerStats = stats.player
    self.opponentStats = stats.opponent
    self.hashKey = stats.hashKey or self.hashKey

    if self.playerTeamData ~= nil and self.opponentTeamData ~= nil then
        self.playerTeamData.stats = stats.player
        self.opponentTeamData.stats = stats.opponent
        self.matchInfoModel:UpdatePlayerStatisticsData(self.playerTeamData)
        self.matchInfoModel:UpdateOpponentStatisticsData(self.opponentTeamData)
    end

    --migrate from c#
    local matchInfo = frame.matchInfo

    if frame.time > 0.2 and isDeadBallEvent(frame.matchEvent) and not self.matchInfoModel:IsDemoMatch() then
        print("DataProvider continue on MatchEvent")
        DataProvider.Continue()
    end
    self:onScoreChangeMsg(matchInfo.playerScore, matchInfo.opponentScore)

    if self.matchInfoModel:IsDemoMatch() then
        self.fightMenuManager.matchStage = matchInfo.stage
        return
    else
        local matchEvent = frame.matchEvent
        if matchEvent == MatchEventType.NontimedKickOff then
            if self.halfTimeCount then
                self.halfTimeCount = self.halfTimeCount + 1
                if self.halfTimeCount % 2 == 1 then
                    if TimeLineWrap.IsInFastForward() then
                        self.isFastForwardBeforeHalfTime = true
                        self.timeScaleMultipleBeforeHalfTime = TimeLineWrap.GetTimeScaleMultiple()
                        TimeLineWrap.StartFastForward(1)
                    else
                        self.isFastForwardBeforeHalfTime = false
                    end
                end
            else
                self.halfTimeCount = 0
            end
        elseif matchEvent == MatchEventType.GameOver then
            self.fightMenuManager.isGameOver = true
            if self.inPenaltyShootOut then
                self.fightMenuManager:OnPenaltyShootOutKickResult(matchInfo)
            end
        elseif matchEvent == MatchEventType.CenterDirectFreeKick
            or matchEvent == MatchEventType.WingDirectFreeKick
            or matchEvent == MatchEventType.PenaltyKick then
            self:onFoul(GameHubWrap.GetAthleteId(matchInfo.foulAthlete), frame.time)
        elseif matchEvent == MatchEventType.IndirectFreeKick then
            self:onOffside(GameHubWrap.GetAthleteId(matchInfo.foulAthlete), frame.time)
        elseif matchEvent == MatchEventType.NormalPlayOn then
            self.fightMenuManager.matchStage = matchInfo.stage
        elseif matchEvent == MatchEventType.PenaltyShootOutKick then
            if not self.inPenaltyShootOut then
                self.inPenaltyShootOut = true
            else
                self:onPenaltyShootOutKick(matchInfo)
            end
        end
    end

    self:onPlayerNameChangeMsg(nil)
end

function MatchUI:onPlayerNameChangeMsg(onfieldId)
    if PlaybackCenterWrap.InPlaybackMode() == true then
        self.fightMenuManager:HighlightBallOwner(nil)
        return
    end

    local athleteId = onfieldId and GameHubWrap.GetAthleteId(onfieldId)
    if onfieldId == nil or athleteId == nil or athleteId <= 0 then
        self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
        self.ballOwnerId = nil
        self.fightMenuManager:HighlightBallOwner(nil)
    else
        self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, true)

        local athlete = self:getAthlete(athleteId)
        local isPlayer = self:isPlayer(athleteId)
        self.fightMenuManager:InitialPlayerName(athlete, isPlayer)
        self.ballOwnerId = athleteId

        self.fightMenuManager:HighlightBallOwner(onfieldId)
    end
end

function MatchUI:onScoreChangeMsg(playerScore, opponentScore)
    self.leftScore = playerScore
    self.rightScore = opponentScore
    self.fightMenuManager:InitialTeamName(nil, nil, self:FormatScore())
    if not self.inPenaltyShootOut then
        self.fightMenuManager:InitialScoreBarGoal(self:FormatScore())
    end
    EventSystem.SendEvent("OnMatchScoreChange", playerScore, opponentScore)
end

function MatchUI:onShootBallFlyEnd(shootResult)
    if self.matchInfoModel:IsDemoMatch() then
        ___demoManager:OnShootBallFlyEnd(shootResult)
    else
        if shootResult == tonumber(ShootResult.Goal) then
            local shooter = GameHubWrap.GetShooter()
            if not TimeLineWrap.IsInFastForward() and shooter < 11 and not self.inPenaltyShootOut then
                self:onPlayGoalAnimation()
            end
            local athleteId = GameHubWrap.GetAthleteId(shooter)
            local matchTime = TimeLineWrap.TLMatchTime()
            self:onGoal(athleteId, matchTime)
        end
    end
end

function MatchUI:onPlayGoalAnimation()
    self.fightMenuManager:PlayGoalAnimation()
end

function MatchUI:onStopGoalAnimation()
    self.fightMenuManager:StopGoalAnimation()
end

function MatchUI:onGoal(athleteId, time)
    local isPlayer = self:isPlayer(athleteId)
    if not self.inPenaltyShootOut then
        local athlete = self:getAthlete(athleteId)
        self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.SCORE_BAR_GOAL, true)
        self.fightMenuManager:InitialScoreInfo(isPlayer, athlete, self:FormatScore(), time, 0)
        self.fightMenuManager:MoveTeamScorePanel()
    end

    -- 是主场进球还是客场进球
    local goalSide = nil

    -- 玩家是主场或者中立场
    if self.baseInfo.home == 0 or self.baseInfo.home == 2 then
        goalSide = isPlayer and "home" or "away"
    else
        goalSide = isPlayer and "away" or "home"
    end

    self.stadiumManager:onGoal(goalSide)
end

function MatchUI:onFoul(athleteId, time)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.FOUL_PANEL, true)
    local athlete = self:getAthlete(athleteId)
    local isPlayer = self:isPlayer(athleteId)
    self.fightMenuManager:InitialFoulInfo(isPlayer, athlete.number, athlete.name, time, MatchConstants.FoulType.FOUL)
end

function MatchUI:onOffside(athleteId, time)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.FOUL_PANEL, true)
    local athlete = self:getAthlete(athleteId)
    local isPlayer = self:isPlayer(athleteId)
    self.fightMenuManager:InitialFoulInfo(isPlayer, athlete.number, athlete.name, time, MatchConstants.FoulType.OFFSIDE)
end

function MatchUI:onPenaltyShootOutStart()
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    self.fightMenuManager:OnPenaltyShootOutStart()
end

function MatchUI:onPenaltyShootOutKick(matchInfo)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    self.fightMenuManager:OnPenaltyShootOutKickResult(matchInfo)
end

function MatchUI:onDeployed()
    self.fightMenuManager:InitialDeployedInfo()
    EventSystem.SendEvent("FightMenuManager.UpdatePlayerState")
end

function MatchUI:onSubstitute(newUpList, newDownList)
    local data = { }
    for i, id in pairs(newUpList) do
        local upAthlete = self:getAthlete(id)
        local downAthlete = self:getAthlete(newDownList[i])
        local ret = {
            up =
            {
                number = upAthlete.number,
                name = upAthlete.name,
            },
            down =
            {
                number = downAthlete.number,
                name = downAthlete.name,
            },
        }
        table.insert(data, ret)
    end

    self.fightMenuManager:InitialSubstituteInfo(data)
    EventSystem.SendEvent("Match_Substitute")
end

local function compareResult(client, server)
    if client.player.score == server.player.score and
        client.opponent.score == server.opponent.score and
        client.player.passTimes == server.player.passTimes and
        client.opponent.passTimes == server.opponent.passTimes and
        client.player.possession == server.player.possession and
        client.opponent.possession == server.opponent.possession
    then
        print("Result is matched!")
    else
        print("Result is NOT matched! (Please ignore this if match skiped)")
    end
end

function MatchUI:disablePopPanel()
    Object.Destroy(GameObject.Find("/MatchBreak(Clone)"))

    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_GOAL_PANEL, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.FOUL_PANEL, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_SHOOT_PANEL, false)
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)
end

function MatchUI:onGameOver()
    MatchInfoModel.ClearInstance()
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    if self.matchInfoModel:IsReplay() then
        local cacheData = { }
        cacheData.matchInfoModel = self.matchInfoModel
        local result = self.matchInfoModel:GetResult()
        cacheData.playerStats = result and result.player or self.playerStats
        cacheData.opponentStats = result and result.opponent or self.opponentStats
        self.playerTeamData.stats = result.player
        self.opponentTeamData.stats = result.opponent
        self.matchInfoModel:UpdatePlayerStatisticsData(self.playerTeamData)
        self.matchInfoModel:UpdateOpponentStatisticsData(self.opponentTeamData)
        self.fightMenuManager:ShowMatchOverData(cacheData)

        -- 回放比分 报服务器日志 start
        local isSkipped = self.matchInfoModel:IsSkipMatch()
        local isGiveUp = self.matchInfoModel:IsGiveUpMatch()
        local matchData = self.matchInfoModel:GetData()
        local ReplayCheckHelper = require("coregame.ReplayCheckHelper")
        ReplayCheckHelper.SendReplayCheck(matchData, self.leftScore, self.rightScore, isSkipped, isGiveUp)
        -- 回放比分 报服务器日志 end

        cache.setMatchResult(cacheData)
    else
        self:requestGameOver()
    end
end

function MatchUI:requestGameOver()
    local playerStats = self.playerTeamData and self.playerTeamData.stats or self.playerStats
    local opponentStats = self.opponentTeamData and self.opponentTeamData.stats or self.opponentStats

    local operation = json.decode(DataProvider.operationJson) or {}

    local reqData = {
        ops = operation,
        statistics =
        {
            player = clone(playerStats),
            opponent = clone(opponentStats),
        },
        isSkipped = self.matchInfoModel:IsSkipMatch(),
        isGiveUp = self.matchInfoModel:IsGiveUpMatch(),
        hashKey = self.hashKey,
        version = require("emulator.version").version,
    }

    self.matchInfoModel:AddOperationData(operation)

    local request = self:coroutine(function()
        local resp = req.matchOver(reqData)
        if api.success(resp) then
            local data = resp.val
            data.hasSettle = false
            cache.setMatchResult(data)
            self.fightMenuManager:onRequestCompleted(data)

            local statistics = data.statistics
            compareResult(reqData.statistics, statistics)
            self.playerTeamData.stats = statistics.player
            self.opponentTeamData.stats = statistics.opponent
            self.matchInfoModel:UpdatePlayerStatisticsData(self.playerTeamData)
            self.matchInfoModel:UpdateOpponentStatisticsData(self.opponentTeamData)

            self:disablePopPanel()

            local cacheData = {}
            cacheData.matchInfoModel = self.matchInfoModel
            cacheData.playerStats = statistics.player
            cacheData.opponentStats = statistics.opponent
            self.fightMenuManager:ShowMatchOverData(cacheData)

            if type(data.sweepConsume) == "table" then
                local rewardUpdateCacheModel = RewardUpdateCacheModel.new()
                rewardUpdateCacheModel:UpdateCache(data.sweepConsume)
            end

            if data.matchType == MatchConstants.MatchType.QUEST then
                local questPageViewModel = QuestPageViewModel.new()
                local questInfoModel = QuestInfoModel.new()
                questPageViewModel:SetModel(questInfoModel)
                questPageViewModel:UpdateProtocolData(data.settlement.questInfo)
                local lastMatchStageId = questPageViewModel:GetMatchStageId()
                local playerTeamsModel = PlayerTeamsModel.new()
                local isPass = data.settlement.isPass
                luaevt.trig("HoolaiBISendCounterCoregame", 1, lastMatchStageId, isPass)
                CustomEvent.StoryMatchEnd(lastMatchStageId, isPass, playerTeamsModel:GetTotalPower())
            elseif data.matchType == MatchConstants.MatchType.LEAGUE then
                local playerTeamsModel = PlayerTeamsModel.new()
                local isMatchWin = data.settlement.winGoals > 0
                local leagueInfoModel = LeagueInfoModel.new()
                luaevt.trig("HoolaiBISendCounterCoregame", 2, leagueInfoModel:GetLeagueLevel(), isMatchWin)
                CustomEvent.LeagueMatchEnd(leagueInfoModel:GetLeagueLevel(), isMatchWin, playerTeamsModel:GetTotalPower())
            elseif data.matchType == MatchConstants.MatchType.LADDER then
                local isWin = tonumber(data.statistics.opponent.score) < tonumber(data.statistics.player.score)
                luaevt.trig("HoolaiBISendCounterCoregame", 3, "", isWin)
			elseif data.matchType == MatchConstants.MatchType.ADVENTURE then
				local greenswardMatchModel = require("ui.models.greensward.build.GreenswardMatchModel").new()
                local playerTeamData = self.matchInfoModel:GetPlayerTeamData()
                local opponentTeamData = self.matchInfoModel:GetOpponentTeamData()
                data.playerInfo = {}
                data.opponentInfo = {}
                data.playerInfo.logo = playerTeamData.logo
                data.playerInfo.teamName = playerTeamData.teamName
                data.opponentInfo.logo = opponentTeamData.logo
                data.opponentInfo.teamName = opponentTeamData.teamName
                greenswardMatchModel:InitProtocolData(data)
            else
                luaevt.trig("HoolaiBISendCounterCoregame", 4, "", true)
            end
        else
            self.fightMenuManager:ExitScene()
        end
    end)
end

function MatchUI:onStartTime()
    if self.matchInfoModel:IsDemoMatch() then
        self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)
    else
        self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, true)
    end
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, true)
end

function MatchUI:onHalfTime()
    self.fightMenuManager:RemoveAllLabel()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Overlay/HalfData.prefab", "overlay", false, true)
end

function MatchUI:onOverTime()
    self.fightMenuManager:RemoveAllLabel()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Overlay/HalfData.prefab", "overlay", false, true)
end

function MatchUI:onPenaltyShootOut()
    self.fightMenuManager:RemoveAllLabel()
    self.fightMenuManager:DisableNoteButton()
    res.ShowDialog("Assets/CapstonesRes/Game/UI/Match/Overlay/PenaltyShootOutList.prefab", "overlay", false, true)
end

function MatchUI:onGiveUpMatch()
    TimeWrap.SetTimeScale(0.000001)
    self:onGameOver()
end

function MatchUI:onSkipMatch()
    TimeWrap.SetTimeScale(0.000001)
    self:onGameOver()
end

function MatchUI:onShootStart(onfieldId, athleteId, action, athleteObject)
    self.fightMenuManager:DisableNoteButton()
    self.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_SHOOT_PANEL, true)
    local shootAction = action.athleteAction.shootAction
    local goalPercentage = math.round(shootAction.goalProbability * 100)
    local shootAbility = shootAction.shootAbility

    local athlete = self:getAthlete(athleteId)

    EventSystem.SendEvent("CommentaryManager.PlayShootAudio", athleteId, shootAction, action)
    EventSystem.SendEvent("CommentaryManager.PlayShootBeforeAudio", athleteId, shootAction, action)
    if self:isPlayer(athleteId) and not self.matchInfoModel:IsReplay() and not self.matchInfoModel:IsAuto() then
        self.fightMenuManager:InitialPlayerShootData(athlete, shootAbility, goalPercentage, 5, true)
    else
        self.fightMenuManager:InitialPlayerShootData(athlete, shootAbility, goalPercentage, 1, false)
    end
    self:onShootAction(athlete, shootAction, athleteObject)

    EmulatorInputWrap.SetIsTouchShoot(false)
    local gameHub = GameHub.GetInstance()
    GameHubWrap.SetShooter(onfieldId)
    if self.matchInfoModel:IsDemoMatch() and ___demoManager then
        if self:isPlayer(athleteId) then
            local goal = gameHub:GetGoalNear(Vector2(shootAction.targetPosition.x, shootAction.targetPosition.y))
            ___demoManager:OnShootStart(onfieldId, goal, action, athleteObject)
        else
            ___demoManager:OnOpponentShoot(onfieldId, action)
        end
    else
        if self:isPlayer(athleteId) and not self.matchInfoModel:IsReplay() then
            local goal = gameHub:GetGoalNear(Vector2(shootAction.targetPosition.x, shootAction.targetPosition.y))
            self:ActivateTouchShoot(goal, action)
        else
            print("DataProvider continue on ShootStart")
            DataProvider.Continue()
        end
    end
end

function MatchUI:ActivateTouchShoot(goal, action)
    GameHubWrap.SetFingerTestActive(true)
    self.screenEffectManager:ApplyEffect("Shoot")
    GameHub.GetInstance().fingerTest:OnTouchShootActivated(goal, action)
end

function MatchUI:onPostShoot(shootAction, postShootAction)
    if EmulatorInputWrap.GetIsTouchShoot() then
        local newProbability = postShootAction.goalProbability
        newProbability = math.clamp(newProbability, 0, 1)

        local newPercentage = math.round(newProbability * 100)
        local goalPercentageDelta = math.round(newProbability * 100) - math.round(shootAction.goalProbability * 100)

        -- Good, NoGood, Perfect, Missed
        local shootType = nil
        if goalPercentageDelta >= 10 then
            shootType = MatchConstants.ShootEvaluationType.PERFECT
        elseif goalPercentageDelta >= 0 then
            shootType = MatchConstants.ShootEvaluationType.GOOD
        elseif newPercentage > 0 then
            -- goalPercentageDelta < 0
            shootType = MatchConstants.ShootEvaluationType.NOT_GOOD
        else
            shootType = MatchConstants.ShootEvaluationType.MISS
        end

        self.fightMenuManager:InitialPlayerShootState(newPercentage, shootType)
    end
end

function MatchUI:onShootBallFlyStart(athleteId, athleteObject)
    self.fightMenuManager:EnableNoteButton()
end

function MatchUI:onPlayerActionStart(id, athleteId, athleteActionType, successProbability, action, actionName)
    if PlaybackCenterWrap.InPlaybackMode() == true then
        return
    end
    local athleteObject = nil
    if id <= 10 then
        athleteObject = self.playerManager.players[id + 1].gameObject
    else
        athleteObject = self.playerManager.opponents[id - 10].gameObject
    end

    --if action:hasAthleteAction() then
        self:onAthleteAction(athleteId, athleteActionType, athleteObject, successProbability, isSkillCast, actionName, action)
    --end
end

function MatchUI:onSkillCast(athleteId, skill, athleteObject)
    if athleteId == nil or skill == nil or skill.SkillId == nil then
        return
    end
    local skillId = skill.SkillId

    local athlete = self:getAthlete(athleteId)
    self.fightMenuManager:onSkillLabelDisplay(athlete, athleteObject, skill)
    local letterFirst = string.sub(tostring(skillId), 1, 1)
    if tostring(letterFirst) == "D" or tostring(letterFirst) == "E" or tostring(letterFirst) == "B" then
        if tostring(letterFirst) == "D" then
            EventSystem.SendEvent("CommentaryManager.PlayShootSkillAudio", skillId)
        end
        UISoundManager.play('Match/playerSkill', 0.5)
    end
    EventSystem.SendEvent("CommentaryManager.PlaySkillAudio", athleteId, skillId)

    -- 马尾统帅
    if skillId == "E04_A" then
        self.fightMenuManager:ShowSkillPlayerEffect(skillId, athleteObject)
    end

    local legendSkillIdsWithBallEffect = {
        -- 旋风冲击
        "D05_A",
        -- 金狼直传
        "C01_A",
        -- 曼妙弧线
        "C03_A",
        -- 巴西火炮
        "D07_B",
        -- 飞火流星
        "D06_A",
        -- 风驰电掣
        "B01_A",
    }

    if string.match(skillId, "_A_1") then
        skillId = string.sub(skillId, 1, 5)
    end
    if table.isArrayInclude(legendSkillIdsWithBallEffect, skillId) then
        local ballObj = self.fightMenuManager.___ex.fingerTest.ball.gameObject
        self.fightMenuManager:ShowSkillBallEffect(skillId, ballObj, 2)
    end
end

function MatchUI:onAthleteAction(athleteId, athleteActionType, athleteObject, successProbability, isSkillCast, actionName, action)
    local athlete = self:getAthlete(athleteId)

    --[[
    -- (For debug) 输出当前动作名
    self.fightMenuManager:DisplayLabel(athlete, athleteObject, actionName, 3, 2)
    --]]

    if athleteActionType == ActionType.Catch
       or athleteActionType == ActionType.Save
    then
        self:onDisplayName(athlete, athleteObject)
    elseif athleteActionType == ActionType.Pass then
        self:onPassAction(athlete, successProbability, athleteObject)
    elseif athleteActionType == ActionType.Dribble then
        self:onDribbleAction(athlete, successProbability, athleteObject)
    elseif athleteActionType == ActionType.Move
        or athleteActionType == ActionType.Shoot
    then
        self:onDisplayName(athlete, athleteObject)
    end

    if athleteActionType == ActionType.Pass and action.athleteAction.passAction.isShowingBallEffect then
        self.fightMenuManager.ballEffectObject:SetActive(true)
    elseif action.isWithBallAction and self.fightMenuManager.ballEffectObject.active then
        self:coroutine(function ()
            coroutine.yield(UnityEngine.WaitForSeconds(action.firstBallOffset.deltaTime))
            self.fightMenuManager.ballEffectObject:SetActive(false)
        end)
    end
end

function MatchUI:onDeadBallTime()
    self.fightMenuManager:RemoveAllLabel()
end

local actionTextColor = Color(.352, .882, 1)

function MatchUI:onDisplayName(athlete, athleteObject)
    if not ___deadBallTimeManager.inDeadBallTime then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, athlete.name, nil, 2)
    end
end

function MatchUI:onPassAction(athlete, successProbability, athleteObject)
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_passRate", math.round(successProbability * 100)), 2, nil, 0.3, actionTextColor)
    else
        self:onDisplayName(athlete, athleteObject)
    end
end

function MatchUI:onDribbleAction(athlete, successProbability, athleteObject)
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_dribbleRate", math.round(successProbability * 100)), 2, nil, nil, actionTextColor)
    else
        self:onDisplayName(athlete, athleteObject)
    end
end

function MatchUI:onPrepareInterceptAction(athlete, successProbability, athleteObject)
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_interceptRate", math.round(successProbability * 100)), 2, nil, 0.3, actionTextColor)
    end
end

function MatchUI:onPrepareStealAction(athlete, successProbability, athleteObject)
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_stealRate", math.round(successProbability * 100)), 2, nil, nil, actionTextColor)
    end
end

function MatchUI:onInfluenceAction(athlete, successProbability, athleteObject)
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_influenceRate", math.round(successProbability * 100)), 2, 3, nil, actionTextColor)
    end
end

function MatchUI:onSaveAction(athlete, successProbability, athleteObject)
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_saveRate", math.round(successProbability * 100)), 2, 3, 0.3, actionTextColor)
    end
end

function MatchUI:onShootAction(athlete, shootAction, athleteObject)
    local successProbability = shootAction.goalProbability
    if 0 < successProbability and successProbability < 1 then
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, lang.trans("match_shootRate", math.round(successProbability * 100)), 2, nil, 0.3, actionTextColor)
    end
end

function MatchUI:onCoachSkillCast(playerCoachSkillId, opponentCoachSkillId)
end

function MatchUI:onAthleteEffect(effect)
    local onfieldId = effect.Id
    local athleteId = GameHubWrap.GetAthleteId(onfieldId)

    local athleteObject = self:getAthleteObject(onfieldId)

    local athlete = self:getAthlete(athleteId)
    local interceptRate = effect.InterceptRate
    local stealRate = effect.StealRate
    local influenceRate = effect.InfluenceRate
    local saveRate = effect.SaveRate
    self:onPrepareInterceptAction(athlete, interceptRate, athleteObject)
    self:onPrepareStealAction(athlete, stealRate, athleteObject)
    self:onInfluenceAction(athlete, influenceRate, athleteObject)
    self:onSaveAction(athlete, saveRate, athleteObject)
end

function MatchUI:onAthleteSkill(skill)
    local onfieldId = skill.OnfieldId
    local athleteId = GameHubWrap.GetAthleteId(onfieldId)

    local athleteObject = self:getAthleteObject(onfieldId)

    self:onSkillCast(athleteId, skill, athleteObject)
end

function MatchUI:onAthleteBuff(buff)
    self.fightMenuManager:onAthleteBuff(buff)
    self:updateMarkedSkillSet(buff)
end

--更新受buff影响的技能信息
function MatchUI:updateMarkedSkillSet(buff)
    if buff.MarkedSkillId ~= "" then
        local athleteData = self:getAthlete(buff.AthleteId)

        if buff.State == 0 then
            athleteData.markedSkillSet[buff.MarkedSkillId] = true
        else
            athleteData.markedSkillSet[buff.MarkedSkillId] = false
        end
    end
end

function MatchUI:onManualOperateStart(onfieldId, athleteId, action, manualOperateAthleteObject)
    local athlete = self:getAthlete(athleteId)
    local isPlayer = self:isPlayer(athleteId)
    -- 是否自动操作
    if self.matchInfoModel:IsAuto() or self.matchInfoModel:IsReplay() then
        isPlayer = false
    end
    if isPlayer then
        self.fightMenuManager:InitAthleteManualOperateEffect(athlete, action.athleteAction.manualOperateAction, manualOperateAthleteObject, onfieldId)
        EmulatorInputWrap.SetManualOperateType(ManualOperateType.Invalid)
        GameHubWrap.SetFingerTestActive(true)
    else
        EmulatorInputWrap.SetManualOperateType(ManualOperateType.Auto)
        GameHubWrap.CleanManualOperate()
        print("DataProvider continue on ManualOperateStart")
        DataProvider.Continue()
    end
end

function MatchUI:onManualOperateDisableUnselectedButtons()
    self.fightMenuManager:OnDisableUnselectedButtons()
end

function MatchUI:onManualOperateEnd()
    self.fightMenuManager:OnClearAthleteManualOperateEffect()
end

function MatchUI:onShowMatchTips()
    self.freezePopupsCtrl:ShowPop()
end

function MatchUI:onHideMatchTips()
    self.freezePopupsCtrl:HidePop()
end

function MatchUI:onTouchShootActivated(callback)
    self.fightMenuManager:OnTouchShootActivated(callback)
end

function MatchUI:onTouchShootDeactivated()
    self.screenEffectManager:ApplyEffect("Default")
    self.fightMenuManager:OnTouchShootDeactivated()
end

function MatchUI:onManualOperateActivated()
    self.fightMenuManager:OnManualOperateActivated()
end

function MatchUI:onManualOperateDeactivated()
    self.screenEffectManager:ApplyEffect("Default")
    self.fightMenuManager:OnManualOperateDeactivated()
end

function MatchUI:onDisablePreMatch()
    self.fightMenuManager:DisablePreMatch()
end

function MatchUI:onEnablePreMatch()
    self.fightMenuManager:EnablePreMatch()
end

--ids: onfieldId array
function MatchUI:equalizePlayersHeight(ids)
    self.playerManager:EqualizePlayersHeight(ids)
end

function MatchUI:restorePlayersOriginalHeight()
    self.playerManager:RestorePlayersOriginalHeight()
end

function MatchUI:onBallHitGoalNet()
    self.stadiumManager:enableGoalNet()
end

function MatchUI:disableGoalNet()
    self.stadiumManager:disableGoalNet()
end

function MatchUI:onDebugInfo(debugInfo)
    if debugInfo.drawText then
        local athleteId = GameHubWrap.GetAthleteId(debugInfo.onfieldId)
        local athlete = self:getAthlete(athleteId)
        local athleteObject = self:getAthleteObject(debugInfo.onfieldId)
        self.fightMenuManager:DisplayLabel(athlete, athleteObject, debugInfo.drawText, 100, 2)
    end
end

function MatchUI:setStatePanelVisible(visible)
    self.fightMenuManager:setStatePanelVisible(visible)
end

function MatchUI:recoverTimeScale()
    self.fightMenuManager:RecoverTimeScale()
end

function MatchUI:startPlaybackMatchHighlights()
    self.fightMenuManager:StartPlaybackMatchHighlights()
end

function MatchUI:onPlaybackMatchHighlightsEnd()
    self.fightMenuManager:OnPlaybackMatchHighlightsEnd()
end

return MatchUI
