local GameHub = clr.GameHub
local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local DeadBallTimeConfig = require("coregame.actionlayer.DeadBallTimeConfig")
local EnumType = require("coregame.EnumType")
local ScreenEffectManager = require("coregame.ScreenEffectManager")
local MatchEventType = EnumType.MatchEventType
local MatchBreakReason = EnumType.MatchBreakReason
local ShootResult = EnumType.ShootResult
local ActionType = EnumType.ActionType
local MatchStage = EnumType.MatchStage
local FindCharacterType = ActionLayerConfig.FindCharacterType
local CharacterType = DeadBallTimeConfig.CharacterType
local SceneType = DeadBallTimeConfig.SceneType

local DeadBallTimeManager = class()

local function selectActionById(actionTable, id)
    local length = #actionTable
    if length > 0 then
        return actionTable[id % length + 1]
    end
end

function DeadBallTimeManager:Start()
    ___deadBallTimeManager = self
    self.playerTransforms = nil
    self.playerPositions = {}
    self.shooter = nil
    self.shooterPos = nil
    self.celebrateCorner = {}
    self.ballHandler = nil
    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.curMatchFrame = {}
    self.preMatchEvent = nil
    self.playerScore = 0
    self.opponentScore = 0
    self.matchStage = MatchStage.None
    self.inShooting = false
    self.downPlayer = {}
    self.upPlayer = {}
    self.equalizePlayersHeight = nil
    self:InitPlayerTransforms()
    self.inDeadBallTime = nil
    self.currentScene = nil
    self.internalScenes = {}
    if self.matchInfoModel:IsDemoMatch() then
        ___demoManager:ToNextScene()
    end
    self.notStartFromBeginning = self.matchInfoModel:NotStartFromBeginnig()
    self.inPenaltyShootOut = nil
    self.penaltyShootOutKickTimes = 0
 end

function DeadBallTimeManager:Destroy()
    self.playerTransforms = nil
    self.playerPositions = nil
    self.shooter = nil
    self.shooterPos = nil
    self.celebrateCorner = nil
    self.ballHandler = nil
    self.matchInfoModel = nil
    self.curMatchFrame = nil
    self.preMatchEvent = nil
    self.downPlayer = nil
    self.upPlayer = nil
    self.equalizePlayersHeight = nil
    self.inDeadBallTime = nil
    self.currentScene = nil
    self.internalScenes = nil
    self.notStartFromBeginning = nil
    self.inPenaltyShootOut = nil
end

function DeadBallTimeManager:InitPlayerTransforms()
    local tmp = GameHub.GetInstance():GetPlayerTransforms()
    self.playerTransforms = {}
    for i = 0, 21 do
        self.playerTransforms[i] = tmp[i]
    end
end

function DeadBallTimeManager:GetPlayerPositionById(id)
    if id >= 0 and id <= 21 then
        return self.playerPositions[id]
    end
end

function DeadBallTimeManager:RefreshPlayerPositions()
    for i = 0, 21 do
        self.playerPositions[i] = self.playerTransforms[i].position
    end
end

function DeadBallTimeManager:PeekPositionsOnNormalPlayOn()
    for i = 0, 21 do
        self.playerPositions[i] = GameHubWrap.PeekResetPositionOnNormalPlayOn(i)
    end
end

function DeadBallTimeManager:ChooseCelebrateCorner()
    if self.shooterPos.z >= 0 then
        self.celebrateCorner.x = 25
        self.celebrateCorner.z = 49
    else
        self.celebrateCorner.x = -25
        self.celebrateCorner.z = -49
    end
end

function DeadBallTimeManager:UpdateMatchEvent(matchFrame, preMatchEvent)
    self.curMatchFrame = matchFrame
    self.preMatchEvent = preMatchEvent
    local matchInfo = matchFrame.matchInfo
    self.playerScore = matchInfo.playerScore
    self.opponentScore = matchInfo.opponentScore
    self.matchStage = matchInfo.stage
end

function DeadBallTimeManager:OnNormalPlayOn(matchFrame, previousEventType)
    ___matchUI:updateClock(matchFrame, previousEventType)

    if self.matchInfoModel:IsDemoMatch() then
        self:UpdateMatchEvent(matchFrame, previousEventType)
        GameHubWrap.HandleMatchEvent(self.curMatchFrame, self.preMatchEvent)
        return
    end

    self:PeekPositionsOnNormalPlayOn()
    local doFreeze = nil
    if matchFrame.matchInfo.isDeployed then
        ___matchUI:onDeployed()
        local ret = self:CheckSubstitutionList(matchFrame)
        if ret then --如果发生换人，则调用MatchUI里的换人函数
            ___matchUI:onSubstitute(ret.upListAthleteId, ret.downListAthleteId)

            if not TimeLineWrap.IsInFastForward() then
                if previousEventType ~= MatchEventType.NontimedKickOff then--如果换人发生在非半场时间，则播放换人动画
                    self:ChooseSubstitutionPlayers(ret)
                    if self.upPlayer then
                        doFreeze = true
                        self:OnSubstitution()
                    end
                end
            end
        end
    end

    self:UpdateMatchEvent(matchFrame, previousEventType)
    if doFreeze ~= true then --如果不播放换人动画，则调用更新网格和球衣
        ___matchUI:updateMeshAndKit(self.curMatchFrame.matchInfo.toAthleteId)
    end
    if not TimeLineWrap.IsInFastForward() then
        if previousEventType == MatchEventType.CenterDirectFreeKick then
            doFreeze = true
            self:OnPlayerDirectFreeKick()
        elseif previousEventType == MatchEventType.CornerKick then
            doFreeze = true
            self:OnPlayerCornerKick()
        elseif previousEventType == MatchEventType.PenaltyKick then
            doFreeze = true
            self:OnPlayerPenaltyShoot()
        elseif previousEventType == MatchEventType.PenaltyShootOutKick then
            if not self.inPenaltyShootOut then
                doFreeze = true
                self:OnPenaltyShootOut()
            elseif self:TryOnPenaltyShootOutKick() then
                doFreeze = true
            end
        end
    end

    if doFreeze then
        TimeLineWrap.TLFreeze()
    else
        GameHubWrap.HandleMatchEvent(self.curMatchFrame, self.preMatchEvent)
    end
end

function DeadBallTimeManager:OnMatchEvent(matchFrame, previousEventType)
    ___matchUI:onMatchEvent(matchFrame)

    if self.matchInfoModel:IsDemoMatch() and ___demoManager then
        ___demoManager:OnMatchEvent(matchFrame)
        return
    end

    local eventType = matchFrame.matchEvent
    if eventType ~= MatchEventType.NormalPlayOn then--TODO 播放过场LOGO
        if PlaybackCenterWrap.InRecordMode() == true then
            ___playbackManager:StopRecording(matchFrame, self.inShooting, self.shooter)
        end
        self:UpdateMatchEvent(matchFrame, previousEventType)
        self:RefreshPlayerPositions()
        if eventType == MatchEventType.NontimedKickOff then
            if self.notStartFromBeginning then
                ___matchUI:onStartTime()
                self.notStartFromBeginning = nil
                return
            end
            if self.matchStage == MatchStage.FirstHalf then
                self:PeekPositionsOnNormalPlayOn()
                self:OnMatchStart()
            elseif self.matchStage ~= MatchStage.None then
                if TimeLineWrap.IsInFastForward() then
                    ___cameraCtrlCore:setLookAtSpectatorCamera()
                    self:OnNontimedKickOffAfterGameStart()
                else
                    self:AddExitOnRefWhistle()
                    self:OnHalfTimeExit()
                end
            end
            TimeLineWrap.TLFreeze()
        elseif eventType == MatchEventType.GameOver then
            if TimeLineWrap.IsInFastForward() or self.matchInfoModel:IsEndByCondition() then
                TimeLineWrap.StopFastForward()
                ___cameraCtrlCore:setLookAtSpectatorCamera()
                self:OnGameOverUI()
            else
                if not self.inPenaltyShootOut then
                    self:AddExitOnRefWhistle()
                end
                self:OnGameOver()
            end
        elseif eventType == MatchEventType.PenaltyShootOutKick then
            self.penaltyShootOutKickTimes = self.penaltyShootOutKickTimes + 1
            if not self.inPenaltyShootOut then
                if TimeLineWrap.IsInFastForward() then
                    ___cameraCtrlCore:setLookAtSpectatorCamera()
                    ___matchUI:onPenaltyShootOut()
                else
                    self:AddExitOnRefWhistle()
                    self:BeforePenaltyShootOut()
                end
                TimeLineWrap.TLFreeze()
            else
                if not TimeLineWrap.IsInFastForward() and PlaybackCenterWrap.IsPlaybackEnabled() == true then
                    ___playbackManager:StartPlayback()
                else
                    TimeLineWrap.TLFreeze(0.1)
                end
            end
        else
            if not TimeLineWrap.IsInFastForward() then
                if eventType == MatchEventType.IndirectFreeKick then
                    if matchFrame.matchInfo.breakReason == MatchBreakReason.Offside then
                        self:OnOffside()
                        TimeLineWrap.TLFreeze()
                    elseif matchFrame.matchInfo.breakReason == MatchBreakReason.Foul then
                        self:OnFoul()
                        TimeLineWrap.TLFreeze()
                    end
                elseif eventType == MatchEventType.Substitution then
                    TimeLineWrap.TLFreeze(1)
                elseif eventType == MatchEventType.ThrowIn then
                    self:OnThrowIn()
                    TimeLineWrap.TLFreeze()
                elseif eventType == MatchEventType.CenterDirectFreeKick
                    or eventType == MatchEventType.PenaltyKick
                    or eventType == MatchEventType.WingDirectFreeKick then
                    self:OnFoul()
                    TimeLineWrap.TLFreeze()
                elseif eventType == MatchEventType.TimedKickOff then
                    if self.inShooting then --goal cause by shoot, not own goal
                        if self.shooter < 11 then
                            self:OnPlayerGoal()
                        else
                            self:OnOpponentGoal()
                        end
                        TimeLineWrap.TLFreeze()
                    else--own goal
                        self:OnOwnGoal()
                        TimeLineWrap.TLFreeze()
                    end
                elseif eventType == MatchEventType.GoalKick then
                    if self.inShooting then
                        if self.shooter < 11 then
                            if self.goalProbability > 0.3 then
                                self:OnPlayerShootFailed()
                            else
                                TimeLineWrap.TLFreeze(0.2)
                            end
                        else
                            self:OnOpponentShootMiss()
                        end
                        TimeLineWrap.TLFreeze()
                    else
                        TimeLineWrap.TLFreeze(0.2)
                    end
                elseif eventType == MatchEventType.CornerKick then
                    if self.inShooting then
                        if self.shooter < 11 then
                            if self.goalProbability > 0.3 then
                                self:OnPlayerShootFailed()
                            else
                                TimeLineWrap.TLFreeze(0.2)
                            end
                        else
                            self:OnOpponentShootBounced()
                        end
                        TimeLineWrap.TLFreeze()
                    else
                        TimeLineWrap.TLFreeze(0.2)
                    end
                end
            end
        end
    else
        self.inShooting = false
        self.hasSaveCatch = false
        if self.equalizePlayersHeight == true then
            self:RestorePlayersOriginalHeight()
        end
        if PlaybackCenterWrap.IsPlaybackEnabled() == true then
            ___playbackManager:StartRecording(matchFrame.time, 5, previousEventType)
        end
        if previousEventType == MatchEventType.PenaltyShootOutKick and not self.inPenaltyShootOut then
            self.inPenaltyShootOut = true
        end
    end
end

function DeadBallTimeManager:OnWithBallActionStart(id, action)
    self.ballHandler = id
    local actionType = action.athleteAction.athleteActionType
    if actionType == ActionType.Shoot then
        self.inShooting = true
        if self.hasSaveCatch then
            self.shootCauseEvent = MatchEventType.Invalid
        else
            self.shootCauseEvent = self.preMatchEvent
        end
        self.shooter = id
        self.shooterPos = self.playerTransforms[id].position
    elseif actionType == ActionType.Dribble
        or actionType == ActionType.Pass
        or actionType == ActionType.Catch then
        self.inShooting = false
    elseif actionType == ActionType.Save then
        if action.athleteAction.saveAction.shootResult == ShootResult.Catched then
            self.hasSaveCatch = true
        end
    end
    if self.matchInfoModel:IsDemoMatch() then
        ___demoManager:OnWithBallActionStart(id, action)
    end
end

function DeadBallTimeManager:OnPostShoot(postShootAction)
    self.goalProbability = postShootAction.goalProbability
end

function DeadBallTimeManager:OnDeadBallTimeEnd()
    self.internalScenes = {}
    self.currentScene = nil
    self.inDeadBallTime = false
    -- 死球场景结束, 恢复正常情况的屏幕特效
    ___matchUI.screenEffectManager:ApplyEffect("Default")
    if self.matchInfoModel:IsDemoMatch() then
        ___demoManager:OnDeadBallTimeEnd()
    else
        local matchEvent = self.curMatchFrame.matchEvent
        if matchEvent == MatchEventType.NormalPlayOn then
            TimeLineWrap.TLUnfreeze()
            GameHubWrap.HandleMatchEvent(self.curMatchFrame, self.preMatchEvent)
            return
        elseif matchEvent == MatchEventType.NontimedKickOff then
            ___cameraCtrlCore:setKickOffCamera()
            ___matchUI:onStartTime()
            if self.matchStage == MatchStage.FirstHalf then
            elseif self.matchStage ~= MatchStage.None then
                self:OnNontimedKickOffAfterGameStart()
                return
            end
        elseif matchEvent == MatchEventType.GameOver then
            ___cameraCtrlCore:setKickOffCamera()
            self:OnGameOverUI()
            return
        elseif matchEvent == MatchEventType.TimedKickOff then
            if self.shooter < 11 then
                ___matchUI:onStopGoalAnimation()
            end
            TimeLineWrap.TLUnfreeze()
            if self.inShooting == true and PlaybackCenterWrap.IsPlaybackEnabled() == true then
                ___playbackManager:StartPlayback()
            end
            return
        elseif matchEvent == MatchEventType.IndirectFreeKick then
            ___cameraCtrlCore:setIndirectFreeKickCamera()
        elseif matchEvent == MatchEventType.PenaltyShootOutKick and not self.inPenaltyShootOut then
            ___cameraCtrlCore:setLookAtSpectatorCamera()
            ___matchUI:onPenaltyShootOut()
            return
        end
        TimeLineWrap.TLUnfreeze()
    end
end

function DeadBallTimeManager:OnNontimedKickOffAfterGameStart()
    if self.matchStage == MatchStage.SecondHalf or self.matchStage == MatchStage.SecondOverTime then
        ___matchUI:onHalfTime()
    elseif self.matchStage == MatchStage.FirstOverTime then
        ___matchUI:onOverTime()
    end
end

function DeadBallTimeManager:OnGameOverUI()
    ___matchUI:onGameOver(self.curMatchFrame.matchStatesJson)
    TimeWrap.SetTimeScale(1)
end

function DeadBallTimeManager:OnOneDeadBallTimeSceneStart()
    ___matchUI.screenEffectManager:RenderNextEffect()
    if #self.internalScenes > 0 then
        self.currentScene = self.internalScenes[1]
    else
        self.currentScene = nil
    end
end

function DeadBallTimeManager:OnOneDeadBallTimeSceneEnd()
    if self.currentScene then
        if self.currentScene.sceneType == SceneType.SubstitutionUp then --换人动画播放完毕更新球员mesh和球衣
            ___matchUI:updateMeshAndKit(self.curMatchFrame.matchInfo.toAthleteId)
        end
        table.remove(self.internalScenes, 1)
    end
end

function DeadBallTimeManager:TryToSkipDeadBallTimeScene(delay)
    if self.inDeadBallTime == true and self.currentScene and self.currentScene.allowSkip == true then
        delay = delay or 0.5
        DeadBallTimeManagerWrap.RestoreNormalMatchInSeconds(delay)
        ___matchUI.screenEffectManager:ClearEffect()
        --TODO 播放过场LOGO
        self.inDeadBallTime = false
    end
end

function DeadBallTimeManager:EnqueueInternalScene(sceneType, ids, allowSkip)
    local internalScene = {}
    internalScene.sceneType = sceneType
    internalScene.ids = ids
    internalScene.allowSkip = allowSkip
    table.insert(self.internalScenes, internalScene)
end

function DeadBallTimeManager:ChooseExitAction(id)
    if self.exitActionsReady == false then
        if self.curMatchFrame.matchEvent == MatchEventType.GameOver then
            if self.playerScore == self.opponentScore then
                self.exitActionsDraw = ActionLayerUtils.CopyAndShuffle(DeadBallTimeConfig.ExitActionDraw)
            else
                self.exitActionsWin = ActionLayerUtils.CopyAndShuffle(DeadBallTimeConfig.ExitActionWin)
                self.exitActionsLose = ActionLayerUtils.CopyAndShuffle(DeadBallTimeConfig.ExitActionLose)
            end
        else
            self.exitActions = ActionLayerUtils.CopyAndShuffle(DeadBallTimeConfig.ExitAction)
        end
        self.exitActionsReady = true
    end
    if self.curMatchFrame.matchEvent == MatchEventType.GameOver then
        if self.playerScore == self.opponentScore then
            return self.exitActionsDraw[math.fmod(id, #self.exitActionsDraw) + 1]
        else
            if (id < 11 and self.playerScore > self.opponentScore)
                or (id >= 11 and self.playerScore < self.opponentScore) then
                return self.exitActionsWin[math.fmod(id, #self.exitActionsWin) + 1]
            else
                return self.exitActionsLose[math.fmod(id, #self.exitActionsLose) + 1]
            end
        end
    else
        return self.exitActions[math.fmod(id, #self.exitActions) + 1]
    end
end

function DeadBallTimeManager:AddExitOnRefWhistle()
    self.inDeadBallTime = true
    ___matchUI.screenEffectManager:AppendEffect("Default")
    local scene = {}
    scene.scenePosition = { x = 0, y = 0 }
    scene.sceneRotation = 0
    scene.characterActions = {}

    self.exitActionsReady = false
    for i = 0, 21 do
        local charAct = {}
        charAct.id = i
        charAct.action = self:ChooseExitAction(i)
        charAct.position = { x = self.playerPositions[i].x, y = self.playerPositions[i].z }
        if self.curMatchFrame.matchEvent == MatchEventType.GameOver or self.curMatchFrame.matchEvent == MatchEventType.PenaltyShootOutKick then
            charAct.rotation = GameHubWrap.GetPlayerRotationAngle(i)
        else
            charAct.rotation = Vector2Lua.SAngle(Vector2Lua(0, 1), Vector2Lua(ActionLayerConfig.ExitCorner.x - charAct.position.x, ActionLayerConfig.ExitCorner.y - charAct.position.y))
        end
        charAct.isSupportRole = false
        charAct.leftFootIK = nil
        charAct.rightFootIK = nil
        table.insert(scene.characterActions, charAct)
    end

    scene.cameraActions = nil
    scene.ballAction = nil
    scene.cardAction = nil
    scene.flagAction = nil
    scene.boardAction = nil
    self:EnqueueInternalScene(SceneType.Invalid, nil, false)
    DeadBallTimeManagerWrap.AddScene(scene, 0)
end

-- 所有死球场景的入口
function DeadBallTimeManager:AddDeadBallTimeScene(config, scenePositionX, scenePositionY, ids, allowSkip, delay, applyActionToRest, isTest)
    self.inDeadBallTime = true
    -- 设置屏幕特效
    ___matchUI.screenEffectManager:AppendEffect("DeadBall", ids)

    isTest = isTest or false
    if not isTest then
        ___matchUI:onDeadBallTime()
    end

    local scene = {}

    scene.scenePosition = { x = scenePositionX, y = scenePositionY }
    if config.Type == SceneType.SetBallFreeKick then
        scene.sceneRotation = self:CalculateSceneRotation_DirectFreeKick(scenePositionX, scenePositionY)
    else
        if scenePositionY  >= 0 then
            if scenePositionX >= 0 then
                scene.sceneRotation = config.Rotations[1]
            else
                scene.sceneRotation = config.Rotations[2]
            end
        else
            if scenePositionX <= 0 then
                scene.sceneRotation = config.Rotations[3]
            else
                scene.sceneRotation = config.Rotations[4]
            end
        end
    end

    local isGoal = false
    local rivalGK = nil
    if config.Type == SceneType.Goal
        or config.Type == SceneType.GoalPickupBall
        or config.Type == SceneType.GoalStep2 then
        isGoal = true
        rivalGK = 11
    elseif config.Type == SceneType.OpponentGoal then
        isGoal = true
        rivalGK = 0
    end


    if #config.CharacterActions > 0 then
        local interactIds = {}
        scene.characterActions = {}
        local scenePosition = { x = scenePositionX, z = scenePositionY }
        for i = 1, #config.CharacterActions do
            local charAct = {
                id = ids[i],
                action = config.CharacterActions[i].action,
                position = config.CharacterActions[i].position,
                rotation = 180,
                isSupportRole = false,
                leftFootIK = config.CharacterActions[i].leftFootIK,
                rightFootIK = config.CharacterActions[i].rightFootIK
            }
            table.insert(scene.characterActions, charAct)
            if config.CharacterActions[i].interact == true then
                table.insert(interactIds, ids[i] + 1)
            end
        end
        if #interactIds > 0 then
            self:EqualizePlayersHeight(interactIds)
        end

        if applyActionToRest == true then
            local occupied = {}
            for i = 0, 21 do
                occupied[i] = false
            end
            for i = 1, #ids do
                occupied[ids[i]] = true
            end
            for i = 0, 21 do
                if occupied[i] == false and ActionLayerUtils.Vector3SqrDistanceOnXZ(scenePosition, self.playerPositions[i]) > 225 then
                    local playerAction = nil
                    local playerRotation = nil
                    if isGoal then
                        if ActionLayerUtils.IsRival(ids[1], i) then
                            playerAction = selectActionById(DeadBallTimeConfig.LoseGoalAction, i)
                            if i == rivalGK then
                                playerRotation = GameHubWrap.GetPlayerRotationAngle(i)
                            else
                                playerRotation = Vector2Lua.SAngle(Vector2Lua(0, 1), 
                                    Vector2Lua(self.playerPositions[rivalGK].x - self.playerPositions[i].x, 
                                        self.playerPositions[rivalGK].z - self.playerPositions[i].z))
                            end
                        else
                            playerAction = selectActionById(DeadBallTimeConfig.GoalAction, i)
                            playerRotation = Vector2Lua.SAngle(Vector2Lua(0, 1), 
                                    Vector2Lua(scenePositionX - self.playerPositions[i].x, 
                                        scenePositionY - self.playerPositions[i].z))
                        end
                    else
                        playerAction = selectActionById(DeadBallTimeConfig.StandAction, i)
                        if config.Type == SceneType.WaitKickOff
                            or config.Type == SceneType.PenaltyShootOutWait
                            or config.Type == SceneType.PenaltyShootOutWait_Opponent
                            or config.Type == SceneType.SetBallPenalty
                            or config.Type == SceneType.SetBallPenalty_Oppoennt then
                            playerRotation = Vector2Lua.SAngle(Vector2Lua(0, 1), 
                                    Vector2Lua(scenePositionX - self.playerPositions[i].x, 
                                        scenePositionY - self.playerPositions[i].z))
                        else
                            playerRotation = GameHubWrap.GetPlayerRotationAngle(i)
                        end
                    end

                    local charAct = {
                        id = i,
                        action = playerAction,
                        position = { x = self.playerPositions[i].x, y = self.playerPositions[i].z },
                        rotation = playerRotation,
                        isSupportRole = true,
                        leftFootIK = nil,
                        rightFootIK = nil
                    }
                    table.insert(scene.characterActions, charAct)
                end
            end
        end
    else
        scene.characterActions = nil
    end

    scene.cameraActions = {}
    for i = 1, #config.CameraActions do
        table.insert(scene.cameraActions, config.CameraActions[i])
    end

    scene.ballAction = config.BallAction
    scene.cardAction = config.CardAction
    scene.flagAction = config.FlagAction
    scene.boardAction = config.BoardAction
    self:EnqueueInternalScene(config.Type, ids, allowSkip)
    DeadBallTimeManagerWrap.AddScene(scene, delay)
    return
end

function DeadBallTimeManager:GetOnFieldIdByAthleteId(athleteId)
    for i = 1, #self.curMatchFrame.matchInfo.toAthleteId do
        if athleteId == self.curMatchFrame.matchInfo.toAthleteId[i] then
            return i - 1
        end
    end
    return 0
end

function DeadBallTimeManager:GetCharacterIdsByConfig(config, param)
    local heroId = param.heroId
    local occupied = {}
    for i = 0, 21 do
        if heroId and i == heroId then
            occupied[i] = true
        else
            occupied[i] = false
        end
    end

    local anyCount = 0
    local playerNoneGKCount = 0
    local opponentNoneGKCount = 0
    local playerCount = 0
    local opponentCount = 0
    local playerCaptain = nil
    local opponentCaptain = nil
    for i = 1, #config.CharacterActions do
        if config.CharacterActions[i].characterType == CharacterType.PlayerCaptain then
            playerCaptain = self:GetOnFieldIdByAthleteId(self.matchInfoModel:GetPlayerCaptain())
            occupied[playerCaptain] = true
        elseif config.CharacterActions[i].characterType == CharacterType.OpponentCaptain then
            opponentCaptain = self:GetOnFieldIdByAthleteId(self.matchInfoModel:GetOpponentCaptain())
            occupied[opponentCaptain] = true
        elseif config.CharacterActions[i].characterType == CharacterType.PlayerNoneGK then
            playerNoneGKCount = playerNoneGKCount + 1
        elseif config.CharacterActions[i].characterType == CharacterType.OpponentNoneGK then
            opponentNoneGKCount = opponentNoneGKCount + 1
        elseif config.CharacterActions[i].characterType == CharacterType.Player then
            playerCount = playerCount + 1
        elseif config.CharacterActions[i].characterType == CharacterType.Opponent then
            opponentCount = opponentCount + 1
        elseif config.CharacterActions[i].characterType == CharacterType.Any then
            anyCount = anyCount + 1
        elseif config.CharacterActions[i].characterType == CharacterType.PlayerGoalkeeper then
            occupied[0] = true
        elseif config.CharacterActions[i].characterType == CharacterType.OpponentGoalkeeper then
            occupied[11] = true
        elseif config.CharacterActions[i].characterType == CharacterType.Upper then
            occupied[self.upPlayer.onfieldId] = true
        elseif config.CharacterActions[i].characterType == CharacterType.Downer then
            occupied[self.downPlayer.onfieldId] = true
        end
    end

    local playerNoneGKs = self:FindCharacters(param, playerNoneGKCount, 1, 10, occupied)
    local opponentNoneGKs = self:FindCharacters(param, opponentNoneGKCount, 12, 21, occupied)
    local players = self:FindCharacters(param, playerCount, 0, 10, occupied)
    local opponents = self:FindCharacters(param, opponentCount, 11, 21, occupied)
    local anys = self:FindCharacters(param, anyCount, 0, 21, occupied)

    local playerNoneGKIdx = 1
    local opponentNoneGKIdx = 1
    local playerIdx = 1
    local opponentIdx = 1
    local anyIdx = 1

    local ret = {}
    for i = 1, #config.CharacterActions do
        if config.CharacterActions[i].characterType == CharacterType.Hero then
            ret[i] = heroId
        elseif config.CharacterActions[i].characterType == CharacterType.PlayerCaptain then
            ret[i] = playerCaptain
        elseif config.CharacterActions[i].characterType == CharacterType.OpponentCaptain then
            ret[i] = opponentCaptain
        elseif config.CharacterActions[i].characterType == CharacterType.PlayerNoneGK then
            ret[i] = playerNoneGKs[playerNoneGKIdx]
            playerNoneGKIdx = playerNoneGKIdx + 1
        elseif config.CharacterActions[i].characterType == CharacterType.OpponentNoneGK then
            ret[i] = opponentNoneGKs[opponentNoneGKIdx]
            opponentNoneGKIdx = opponentNoneGKIdx + 1
        elseif config.CharacterActions[i].characterType == CharacterType.Player then
            ret[i] = players[playerIdx]
            playerIdx = playerIdx + 1
        elseif config.CharacterActions[i].characterType == CharacterType.Opponent then
            ret[i] = opponents[opponentIdx]
            opponentIdx = opponentIdx + 1
        elseif config.CharacterActions[i].characterType == CharacterType.Any then
            ret[i] = anys[anyIdx]
            anyIdx = anyIdx + 1
        elseif config.CharacterActions[i].characterType == CharacterType.PlayerGoalkeeper then
            ret[i] = 0
        elseif config.CharacterActions[i].characterType == CharacterType.OpponentGoalkeeper then
            ret[i] = 11
        elseif config.CharacterActions[i].characterType == CharacterType.Referee then
            ret[i] = DeadBallTimeConfig.RefereeId
        elseif config.CharacterActions[i].characterType == CharacterType.AssistantReferee then
            ret[i] = DeadBallTimeConfig.AssistantRefereeId
        elseif config.CharacterActions[i].characterType == CharacterType.FourthOfficial then
            ret[i] = DeadBallTimeConfig.FourthOfficialId
        elseif config.CharacterActions[i].characterType == CharacterType.Upper then
            ret[i] = self.upPlayer.onfieldId
        elseif config.CharacterActions[i].characterType == CharacterType.Downer then
            ret[i] = self.downPlayer.onfieldId
        end
    end
    return ret
end

function DeadBallTimeManager:FindCharacters(param, count, startIdx, endIdx, occupied)
    local ret = {}
    if count > 0 then
        local findType = param.findType or FindCharacterType.Random
        if findType == FindCharacterType.Random then
            ret = self:FindRandom(count, startIdx, endIdx, occupied)
        elseif findType == FindCharacterType.ClosestToHero then--hereId as target id
            local heroId = param.heroId
            ret = self:FindClosest(heroId, count, startIdx, endIdx, occupied)
        elseif findType == FindCharacterType.ClosestToPosition then
            local position = param.position
            ret = self:FindClosestToPosition(position, count, startIdx, endIdx, occupied)
        end
    end
    return ret
end

function DeadBallTimeManager.IsUnoccupiedEnough(count, startIdx, endIdx, occupied)
    local freeCount = 0
    for i = startIdx, endIdx do
        if not occupied[i] then
            freeCount = freeCount + 1
            if freeCount >= count then
                return true
            end
        end
    end
    print("There's no enough unoccupied characters left!")
    return false
end

function DeadBallTimeManager:FindRandom(count, startIdx, endIdx, occupied)
    local ret = {}
    if DeadBallTimeManager.IsUnoccupiedEnough(count, startIdx, endIdx, occupied) then
        local range = endIdx - startIdx + 1
        local idx = math.random(startIdx, endIdx)
        for i = 1, count do
            while occupied[idx]
            do
                idx = (idx - startIdx + 1) % range + startIdx
            end
            ret[i] = idx
            occupied[idx] = true
        end
    end
    return ret
end

function DeadBallTimeManager:FindClosest(targetId, count, startIdx, endIdx, occupied)
    local ret = {}
    local position = self.playerPositions[targetId]
    local ids = self:FindClosestToPosition(position, count, startIdx, endIdx, occupied)
    table.imerge(ret, ids)
    return ret
end

function DeadBallTimeManager:FindClosestToPosition(position, count, startIdx, endIdx, occupied)
    local ret = {}
    if DeadBallTimeManager.IsUnoccupiedEnough(count, startIdx, endIdx, occupied) then
        local disTable = {}
        local cmpTable = {}
        local idx = 1
        for i = startIdx, endIdx do
            if not occupied[i] then
                disTable[i] = ActionLayerUtils.Vector3SqrDistanceOnXZ(position, self.playerPositions[i])
                cmpTable[idx] = i
                idx = idx + 1
            end
        end

        for i = 1, count do
            for j = i + 1, #cmpTable do
                if disTable[cmpTable[j]] < disTable[cmpTable[i]] then
                    local temp = cmpTable[i]
                    cmpTable[i] = cmpTable[j]
                    cmpTable[j] = temp
                end
            end
            ret[i] = cmpTable[i]
        end
    end
    return ret
end

function DeadBallTimeManager:OnOpponentShootBounced()--对方进球被扑出，玩家门将振臂庆祝动画
    local gk = ActionLayerUtils.GetOppositeGoalKeeperFieldId(self.shooter)
    local gkPos = self.playerPositions[gk]
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.GoodDefense)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = gk })
    self:AddDeadBallTimeScene(config, 0,  math.sign(gkPos.z) * math.min(math.abs(gkPos.z), 51), ids, true, ActionLayerConfig.ShootCelebrateDelay, true)
end

function DeadBallTimeManager:OnOpponentShootMiss()
    local gk = ActionLayerUtils.GetOppositeGoalKeeperFieldId(self.shooter)
    local gkPos = self.playerPositions[gk]
    local config = nil
    if self.shootCauseEvent == MatchEventType.PenaltyKick or self.shootCauseEvent == MatchEventType.CenterDirectFreeKick then
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.GoodDefense)
    else
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.Complain)
    end
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = gk })
    self:AddDeadBallTimeScene(config, 0, math.sign(gkPos.z) * math.min(math.abs(gkPos.z), 51), ids, true, ActionLayerConfig.ShootCelebrateDelay, true)
end

function DeadBallTimeManager:OnOpponentGoal()--对方进球，对方庆祝，玩家门将与队友互相抱怨
    self:ChooseCelebrateCorner()
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OpponentGoal)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = self.shooter })
    self:AddDeadBallTimeScene(config, self.celebrateCorner.x, self.celebrateCorner.z, ids, true, ActionLayerConfig.ShootCelebrateDelay, true)

    local gk = ActionLayerUtils.GetOppositeGoalKeeperFieldId(self.shooter)
    local gkPos = self.playerPositions[gk]
    config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.Complain)
    ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = gk })
    self:AddDeadBallTimeScene(config, 0, math.sign(gkPos.z) * math.min(math.abs(gkPos.z), 51), ids, true, ActionLayerConfig.ShootCelebrateDelay, true)
end

function DeadBallTimeManager:OnPlayerGoal()--玩家进球，庆祝进球动画。高级：仍旧落后则播放从门里捞球的动画
    if self.playerScore < self.opponentScore then
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.GoalPickupBall)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = self.shooter })
        self:AddDeadBallTimeScene(config, 0, 52 * math.sign(self.shooterPos.z), ids, true, ActionLayerConfig.ShootCelebrateDelay, true)
    else
        self:ChooseCelebrateCorner()
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.Goal)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = self.shooter })
        self:AddDeadBallTimeScene(config, self.celebrateCorner.x, self.celebrateCorner.z, ids, true, ActionLayerConfig.ShootCelebrateDelay, true)

        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.GoalStep2)
        ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = self.shooter })
        self:AddDeadBallTimeScene(config, self.celebrateCorner.x, self.celebrateCorner.z, ids, true, ActionLayerConfig.ShootCelebrateDelay, true)
    end
end

function DeadBallTimeManager:OnPlayerShootFailed()--玩家射门被扑出or射偏，射门球员懊悔
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.MissShoot)
    self:AddDeadBallTimeScene(config, self.shooterPos.x, self.shooterPos.z, { self.shooter }, true, ActionLayerConfig.ShootCelebrateDelay, true)
end

function DeadBallTimeManager:OnOwnGoal() --乌龙球，借用跟错失进球一样的懊悔动作
    local playerPos = self.playerPositions[self.ballHandler]
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.MissShoot)
    self:AddDeadBallTimeScene(config, playerPos.x, playerPos.z, { self.ballHandler }, true, ActionLayerConfig.ShootCelebrateDelay, true)
end

function DeadBallTimeManager:OnFoul()--犯规球员向裁判申辩
    local foulId = self.curMatchFrame.matchInfo.foulAthlete
    local playerPos = self.playerPositions[foulId]
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.ArgueWithRef)
    self:AddDeadBallTimeScene(config, playerPos.x, playerPos.z, { foulId }, true, 0, true)
end

function DeadBallTimeManager:OnOffside()--越位，根据远近选择裁判举旗动作
    local offsiderId = self.curMatchFrame.matchInfo.foulAthlete
    local playerPos = self.playerPositions[offsiderId]
    local config = nil
    if playerPos.z > 0 then
        if playerPos.x > 20 then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefOffsideNear)
        elseif playerPos.x < -20 then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefOffsideFar)
        else
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefOffsideMiddle)
        end
    else
        if playerPos.x > 20 then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefOffsideFar)
        elseif playerPos.x < -20 then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefOffsideNear)
        else
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefOffsideMiddle)
        end
    end
    local ids = { DeadBallTimeConfig.AssistantRefereeId }
    self:AddDeadBallTimeScene(config, ActionLayerConfig.SideLinePosX * math.sign(playerPos.z), playerPos.z, ids, true, 0, true)
end

function DeadBallTimeManager:OnBook()--裁判出牌
    local ballPos = BallActionExecutorWrap.GetBallPosition()
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefBook)
    self:AddDeadBallTimeScene(config, ballPos.x, ballPos.z, { DeadBallTimeConfig.RefereeId }, true, 0, true)
end

function DeadBallTimeManager:OnMatchStartStep1()--group enter
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.GroupEnter)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
    self:AddDeadBallTimeScene(config, -32, -52, ids, true, 0, false)
end

function DeadBallTimeManager:OnMatchStartStep2()--solo enter, opponent
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.SoloEnter)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
    self:AddDeadBallTimeScene(config, -25, -38, ids, true, 0, false)
end

function DeadBallTimeManager:OnMatchStartStep3()--captain shake hands
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.HandShake)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
    self:AddDeadBallTimeScene(config, -15, 0, ids, true, 0, false)
end

function DeadBallTimeManager:OnMatchStartStep4()--referee prepare kick off
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.RefKickOff)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToPosition, position = { x = 0, z = 0 } })
    self:AddDeadBallTimeScene(config, 0, 0, ids, true, 0, false)
end

function DeadBallTimeManager:OnMatchStartStep5()--player wait kick off
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.WaitKickOff)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToPosition, position = { x = 0, z = 0 } })
    self:AddDeadBallTimeScene(config, 0, 0, ids, true, 0, true)
end

function DeadBallTimeManager:OnMatchStart()--开场，包括球员入场，队长握手，裁判摆球，踩球等待开球的动画
    self:OnMatchStartStep1()
    self:OnMatchStartStep2()
    self:OnMatchStartStep3()
    self:OnMatchStartStep4()
    self:OnMatchStartStep5()
end

function DeadBallTimeManager:OnHalfTimeExit() -- 半场的时候退场
    if self.playerScore >= self.opponentScore then
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.HalfExitDraw)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -20, -35, ids, true, 0, false)
    else
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.HalfExitLose)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -28, -44, ids, true, 0, false)
    end
end

function DeadBallTimeManager:OnGameOver()
    if self.inPenaltyShootOut then
        self:OnPenaltyShootOutEnds()
    end
    if self.playerScore > self.opponentScore then -- win
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitWin)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, 10, -15, ids, true, 0, false)

        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitWinStep2)
        ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -8, -44, ids, true, 0, false)

        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitWinStep3)
        ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -8, -44, ids, true, 0, false)
    elseif self.playerScore == self.opponentScore then -- draw
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitDraw)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -20, -35, ids, true, 0, false)

        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitDrawStep2)
        ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -28, -44, ids, true, 0, false)
    else -- lose
        local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitLose)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -20, -25, ids, true, 0, false)

        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.OverExitLoseStep2)
        ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, -20, -25, ids, true, 0, false)
    end
end

function DeadBallTimeManager:BeforePenaltyShootOut()
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutStretch)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
    self:AddDeadBallTimeScene(config, -25, 0, ids, true, 0, false)
end

function DeadBallTimeManager:OnPenaltyShootOut()
    local kicker = GameHubWrap.PeekBallHandlerOnNormalPlayOn()
    local ballPos = GameHubWrap.PeekBallResetPositionOnNormalPlayOn(kicker)
    local config
    if kicker > 10 then
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutUp_Opponent)
    else
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutUp)
    end
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random, heroId = kicker })
    local z = ActionLayerConfig.PenaltySpotZ * math.sign(ballPos.z)
    self:AddDeadBallTimeScene(config, 0, z, ids, true, 0, false)

    if kicker > 10 then
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutWait_Opponent)
    else
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutWait)
    end
    ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random, heroId = kicker })
    self:AddDeadBallTimeScene(config, 0, z, ids, true, 0, true)
end

--当下一个罚球决定胜负时，播放过场动画
function DeadBallTimeManager:TryOnPenaltyShootOutKick()
    local matchInfo = self.curMatchFrame.matchInfo
    local kicker = GameHubWrap.PeekBallHandlerOnNormalPlayOn()
    local isKickerPlayer = kicker <= 10
    local isLateKicker = self.penaltyShootOutKickTimes % 2 < 1
    if matchInfo.penaltyShootOutRound > 5 then --5轮以上后罚方每次罚球都至关重要
        if isLateKicker then
            self:OnPenaltyShootOutKick(kicker)
            return true
        end
    elseif matchInfo.penaltyShootOutRound > 2 then--2轮之内不可能出现临界情况
        local isPlayerEarlyKicker = (not isLateKicker and isKickerPlayer) or (isLateKicker and not isKickerPlayer)
        local scoreDif = matchInfo.playerShootOutScore - matchInfo.opponentShootOutScore
        if isPlayerEarlyKicker then -- 我方先罚
            scoreDif = matchInfo.playerShootOutScore - matchInfo.opponentShootOutScore
        else
            scoreDif = matchInfo.opponentShootOutScore - matchInfo.playerShootOutScore
        end
        local earlyKickerLeftTimes = 5 - math.floor(self.penaltyShootOutKickTimes / 2)
        local lateKickerLeftTimes = 6 - matchInfo.penaltyShootOutRound
        if not isLateKicker then
            if scoreDif + 1 > lateKickerLeftTimes or scoreDif + earlyKickerLeftTimes == 0 then
                self:OnPenaltyShootOutKick(kicker)
                return true
            end
        else
            if scoreDif - 1 + earlyKickerLeftTimes < 0 or scoreDif == lateKickerLeftTimes then
                self:OnPenaltyShootOutKick(kicker)
                return true
            end
        end
    end
    return false
end

function DeadBallTimeManager:OnPenaltyShootOutKick(kicker)
    local ballPos = GameHubWrap.PeekBallResetPositionOnNormalPlayOn(kicker)
    local z = ActionLayerConfig.PenaltySpotZ * math.sign(ballPos.z)

    local config
    if kicker > 10 then
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutWait_Opponent)
    else
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PenaltyShootOutWait)
    end
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random, heroId = kicker })
    self:AddDeadBallTimeScene(config, 0, z, ids, true, 0, true)
end

function DeadBallTimeManager:OnPlayerPenaltyShoot()--玩家踢点球前，播放球员等待罚点球的动画
    local kicker = GameHubWrap.PeekBallHandlerOnNormalPlayOn()
    local kickerPos = self.playerPositions[kicker]
    local sign = math.sign(kickerPos.z)

    local config = nil
    if kicker <= 10 then
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.SetBallPenalty)
    else
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.SetBallPenalty_Oppoennt)
    end
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random, heroId = kicker })

    self:AddDeadBallTimeScene(config, 0, ActionLayerConfig.PenaltySpotZ * sign, ids, true, 0, true)
end

function DeadBallTimeManager:OnPenaltyShootOutEnds()
    local config
    if self.playerScore > self.opponentScore then -- win
        if self.shooter > 10 then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PSO_PlayerWin_OpponentKick)
        else
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PSO_PlayerWin_PlayerKick)
        end
    else -- lose
        if self.shooter > 10 then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PSO_OpponentWin_OpponentKick)
        else
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PSO_OpponentWin_PlayerKick)
        end
    end
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random, heroId = self.shooter })
    self:AddDeadBallTimeScene(config, 0, 0, ids, true, 0, true)

    if self.playerScore > self.opponentScore then
        config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.ChampionCheer)
        local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.Random })
        self:AddDeadBallTimeScene(config, 0, 20, ids, true, 0, false)
    end
end

function DeadBallTimeManager:OnPlayerDirectFreeKick()
    local kicker = GameHubWrap.PeekBallHandlerOnNormalPlayOn()
    local ballPos = GameHubWrap.PeekBallResetPositionOnNormalPlayOn(kicker)
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.SetBallFreeKick)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = kicker })
    self:AddDeadBallTimeScene(config, ballPos.x, ballPos.z, ids, true, 0, true)
end

function DeadBallTimeManager:CalculateSceneRotation_DirectFreeKick(scenePositionX, scenePositionY)
    local gateY = math.sign(scenePositionY) * ActionLayerConfig.GoalPositionZ
    return Vector2Lua.SAngle(Vector2Lua(0, 1), Vector2Lua(-scenePositionX, gateY - scenePositionY)) + 180
end

function DeadBallTimeManager:OnPlayerCornerKick()
    local kicker = GameHubWrap.PeekBallHandlerOnNormalPlayOn()
    local kickerPos = self.playerPositions[kicker]

    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.SetBallCornerKick)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToHero, heroId = kicker })
    local x = ActionLayerConfig.CornerKickBallPosX * math.sign(kickerPos.x)
    local z = ActionLayerConfig.CornerKickBallPosZ * math.sign(kickerPos.z)
    self:AddDeadBallTimeScene(config, x, z, ids, true, 0, true)
end

function DeadBallTimeManager:OnThrowIn()
    local ballPos = BallActionExecutorWrap.GetBallPosition()
    local thrower = nil
    if self.ballHandler < 11 then
        thrower = self:FindClosestToPosition(ballPos, 1, 11, 21, {})[1]
    else
        thrower = self:FindClosestToPosition(ballPos, 1, 0, 10, {})[1]
    end
    local config = nil
    if thrower < 11 then
        if self.playerScore < self.opponentScore then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PickThrowInBall_Hurry)
        else
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PickThrowInBall)
        end
    else
        if self.playerScore > self.opponentScore then
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PickThrowInBall_Hurry)
        else
            config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.PickThrowInBall)
        end
    end
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToPosition, position = ballPos, heroId = thrower })
    local x = ActionLayerConfig.ThrowInResetPosX * math.sign(ballPos.x)
    local z = ballPos.z
    self:AddDeadBallTimeScene(config, x, z, ids, true, 0, true)
end

--发生换人时，需要更换球员的Mesh和Kit
function DeadBallTimeManager:OnSubstitution()--换人，播放球员下场和上场的动画，后期增加第四官员举牌的动画
    ___matchUI:updateSingleMeshAndKit(self.upPlayer.onfieldId + 1, self.upPlayer.athleteId) --给上场球员换脸
    ___matchUI:updateSingleMeshAndKit(self.downPlayer.onfieldId + 1, self.downPlayer.athleteId) --给下场球员换脸
    local config = ActionLayerUtils.RandomChooseOneFromTable(DeadBallTimeConfig.Scenes.SubstitutionUp)
    local ids = self:GetCharacterIdsByConfig(config, { findType = FindCharacterType.ClosestToPosition, position = { x = -ActionLayerConfig.SideLinePosX, z = 0 } })
    self:AddDeadBallTimeScene(config, -ActionLayerConfig.SideLinePosX, 0, ids, true, 0, true)
end

--如果换上的名单中有门将，则不播放换人动画，因为衣服会出错（非常DT的历史原因）
function DeadBallTimeManager:ChooseSubstitutionPlayers(changeList)
    for i = 1, #changeList.upListOnfieldId do
        if changeList.upListOnfieldId[i] == 1 then
            self.downPlayer = nil
            self.upPlayer = nil
            return
        end
    end

    self.upPlayer = { athleteId = changeList.upListAthleteId[1], onfieldId = changeList.upListOnfieldId[1] - 1 }
    self.downPlayer = { }
    self.downPlayer.athleteId = changeList.downListAthleteId[1]

    if self.upPlayer.onfieldId == DeadBallTimeConfig.SubstitutionDownPlayerId then
        self.downPlayer.onfieldId = self.upPlayer.onfieldId - 1
    else
        self.downPlayer.onfieldId = DeadBallTimeConfig.SubstitutionDownPlayerId
    end
end

function DeadBallTimeManager:CheckSubstitutionList(newMatchFrame)
    local currentList = newMatchFrame.matchInfo.toAthleteId
    local previousList = self.curMatchFrame.matchInfo.toAthleteId

    local upTable = {}
    local downTable = {}

    local index = 1
    for i = 1, #previousList do
        if previousList[i] ~= currentList[i] then
            upTable[index] = { athleteId = currentList[i], onfieldId = i }
            downTable[index] = { athleteId = previousList[i], onfieldId = i }
            index = index + 1
        end
    end

    if #upTable == 0 then
        return nil
    end

    local newUpListAthleteId = {}
    local newDownListAthleteId = {}
    local newUpListOnfieldId = {}
    local newDownListOnfieldId = {}

    index = 1
    for i = 1, #upTable do
        local isNeeded = true
        for j = 1, #downTable do
            if i ~= j and upTable[i] == downTable[j] then
                isNeeded = nil
                break
            end
        end
        if isNeeded then
            newUpListAthleteId[index] = upTable[i].athleteId
            newUpListOnfieldId[index] = upTable[i].onfieldId
            index = index + 1
        end
    end

    index = 1
    for i = 1, #downTable do
        local isNeeded = true
        for j = 1, #upTable do
            if i ~= j and downTable[i] == upTable[j] then
                isNeeded = nil
                break
            end
        end
        if isNeeded then
            newDownListAthleteId[index] = downTable[i].athleteId
            newDownListOnfieldId[index] = downTable[i].onfieldId
            index = index + 1
        end
    end

    if #newUpListAthleteId == 0 then
        return nil
    else
        return {
            upListAthleteId = newUpListAthleteId,
            downListAthleteId = newDownListAthleteId,
            upListOnfieldId = newUpListOnfieldId,
            downListOnfieldId = newDownListOnfieldId
        }
    end
end

function DeadBallTimeManager:EqualizePlayersHeight(ids)
    self.equalizePlayersHeight = true
    ___matchUI:equalizePlayersHeight(ids)
end

function DeadBallTimeManager:RestorePlayersOriginalHeight()
    self.equalizePlayersHeight = false
    ___matchUI:restorePlayersOriginalHeight()
end

function DeadBallTimeManager:SetSkipMatchOpening()
    self.notStartFromBeginning = true
end

function DeadBallTimeManager:StartPlaybackMatchHighlights()
    self:TryToSkipDeadBallTimeScene(0)
end

--用于测试死球场景
function DeadBallTimeManager:TestDeadBallTimeScene(sceneType, index, positionX, positionZ)
    local config = nil
    local ids = nil
    local occupied = {}
    if index == 0 then
        for i = 1, #DeadBallTimeConfig.Scenes[sceneType] do
            for i = 0, 21 do
                occupied[i] = false
            end
            config = DeadBallTimeConfig.Scenes[sceneType][i]
            ids = self:FindRandom(#config.CharacterActions, 0, 21, occupied)
            self:AddDeadBallTimeScene(config, positionX, positionZ, ids, false, 0, false, true)
        end
    else
        for i = 0, 21 do
            occupied[i] = false
        end
        config = DeadBallTimeConfig.Scenes[sceneType][index]
        ids = self:FindRandom(#config.CharacterActions, 0, 21, occupied)
        self:AddDeadBallTimeScene(config, positionX, positionZ, ids, false, 0, false, true)
    end
end

return DeadBallTimeManager