local GameHub = clr.GameHub
local ActionLayer = clr.ActionLayer
local DataProvider = ActionLayer.DataProvider
local Action = ActionLayer.Action
local ShootResult = ActionLayer.ShootResult
local AthleteAction = ActionLayer.AthleteAction
local ActionType = AthleteAction.ActionType
local PostShoot = AthleteAction.PostShoot
local Save = AthleteAction.Save
local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Frame = ActionLayer.Frame
local BallOffset = ActionLayer.BallOffset
local Animator = UnityEngine.Animator
local WaitForSeconds = UnityEngine.WaitForSeconds

require("emulator.init")
local vector2 = require("emulator.libs.vector_lua")
local Animations = require("emulator.animations.Animations")
local Athlete = require("emulator.athlete.Athlete")
local AIUtils = require("emulator.AIUtils")
local MatchManager = require("coregame.MatchManager")
local ActionLayerUtils = require("coregame.actionlayer.ActionLayerUtils")
local EnumType = require("coregame.EnumType")
local MatchEventType = EnumType.MatchEventType
local ManualOperateType = EnumType.ManualOperateType
local AthleteActionType = EnumType.ActionType
local DeadBallTimeConfig = require("coregame.actionlayer.DeadBallTimeConfig")
local ActionLayerConfig = require("coregame.actionlayer.ActionLayerConfig")
local DemoMatchConfig = require("coregame.DemoMatchConfig")
local SceneType = DemoMatchConfig.SceneType
local DialogType = DemoMatchConfig.DialogType
local SceneId = DemoMatchConfig.SceneId
local DemoMatchScenes = DemoMatchConfig.Scenes
local MatchClips = DemoMatchConfig.MatchClips
local DeadBallScenes = DemoMatchConfig.DeadBallScenes
local MatchConstants = require("ui.scene.match.MatchConstants")
local CommonConstants = require("ui.common.CommonConstants")
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local CommentaryConstants = require("ui.scene.match.CommentaryConstants")
local AudienceAudioConstants = require("ui.scene.match.AudienceAudioConstants")
local AudioManager = require("unity.audio")

local DemoMatchManager = class(unity.base)

local RestoreNormalMatchDelay = 0.5
local HeroTwoOptionsDuration = 2

function DemoMatchManager:ctor()
    ___demoManager = self
    self.coachNarrate = self.___ex.coachNarrate
    self.coachShout = self.___ex.coachShout
    self.crBoard = self.___ex.crBoard
    self.fixTargetShoot = self.___ex.fixTargetShoot
    self.fixGoalShoot = self.___ex.fixGoalShoot
    self.freeShoot = self.___ex.freeShoot
    self.hero1Option = self.___ex.hero1Option
    self.blackScreen = self.___ex.blackScreen
    self.blackScreenAnimator = self.___ex.blackScreenAnimator
    self.note = self.___ex.note
    self.scoreBoard = self.___ex.scoreBoard
    self.fadeDialog = self.___ex.fadeDialog
    self.bgSea = self.___ex.bgSea
    self.bgSeaAnim = self.___ex.bgSeaAnim
    self.bgLockerRoom = self.___ex.bgLockerRoom
    self.bgLockerRoomAnim = self.___ex.bgLockerRoomAnim
    self.bgLoading = self.___ex.bgLoading
    self.bgLoadingAnim = self.___ex.bgLoadingAnim
    self.tip = self.___ex.tip
    self.sceneIdx = 0
    self.currentScene = nil
    self.shootResult = AIUtils.shootResult.shootWide
    self.goal = nil
    self.shootAction = nil
    self.deadBallSceneIdx = 0
    self.manualOperateIdx = 0
    -- bi打点记录当前英雄时刻的任务id
    self.heroTimeTimes = 18
    self.bgLoadingAnim:Play("Base Layer.MoveIn", 0)
    self.hasStarted = false
end

function DemoMatchManager:onDestroy()
    ___demoManager = nil
end

function DemoMatchManager:ToNextScene()
    self.sceneIdx = self.sceneIdx + 1
    if self.sceneIdx <= #DemoMatchScenes then
        self.currentScene = DemoMatchScenes[self.sceneIdx]
        self:OnSceneStarts()
    else
        self:EndDemoMatch()
    end
end

function DemoMatchManager:OnSceneStarts()
    if self.currentScene.sceneType == SceneType.MatchClip then
        self:OnMatchClipSceneStarts()
    elseif self.currentScene.sceneType == SceneType.DeadBall then
        self:OnDeadBallSceneStarts()
    elseif self.currentScene.sceneType == SceneType.BlackScreen then
        self:OnBlackScreenSceneStarts()
    end
end

function DemoMatchManager:OnMatchClipSceneStarts()
    DataProvider.Reset()
    if self.currentScene.sceneId == SceneId.CRCornerKick then
        self:SendBI("second_half", "16")
    end
    if self.currentScene.sceneId == SceneId.MessiFirst
        or self.currentScene.sceneId == SceneId.MessiSecond
        or self.currentScene.sceneId == SceneId.MessiThird
        or self.currentScene.sceneId == SceneId.CRCornerKick--下半场开始
        or self.currentScene.sceneId == SceneId.CRHero
        or self.currentScene.sceneId == SceneId.CRDiving then
        self:FlipLogo()
    elseif self.currentScene.sceneId == SceneId.CRPenalty then
        ___cameraCtrlCore:resetDefaultFov()
    end

    self.currentClip = MatchClips[self.currentScene.sceneId]
    DemoMatchUtilWrap.LoadUserGuideData(self.currentClip.loadDelay, self.currentClip.path, self.currentClip.loadStartTime, self.currentClip.inGameStartTime)
    if self.currentClip.audio then
        if self.currentClip.audioDelay > 0 then
            self:DelayCommentaryClip(self.currentClip.audioDelay, self.currentClip.audio)
        else
            CommentaryManager.GetInstance():PlayDemoMatchCommentary(self.currentClip.audio)
        end
    end

    ___matchUI.fightMenuManager.isDisplayTimeStop = nil
    ___matchUI.fightMenuManager.previousTime = self.currentClip.inGameStartTime
    ___matchUI.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)

    self.matchEventCount = 0

    if self.currentScene.sceneId == SceneId.CRHero then
        self.allowManualOperate = false
        self.allowedOperation = ManualOperateType.Invalid
    end
end

function DemoMatchManager:OnDeadBallSceneStarts()
    -- self:SendBI(1)
    ___matchUI.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    ___matchUI.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    TimeLineWrap.TLFreeze()
    if self.currentScene.sceneId == SceneId.HalfTimeExit then
        CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.HalfTimeWhistleAudio)
        self:FlipLogo()
    elseif self.currentScene.sceneId == SceneId.AfterPenalty1 then
        CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.GameOverWhistleAudio)
    end
    self.currentDBScenes = DeadBallScenes[self.currentScene.sceneId]
    for i = 1, #self.currentDBScenes do
        local db = self.currentDBScenes[i]
        ___deadBallTimeManager:AddDeadBallTimeScene(DeadBallTimeConfig.Scenes[db.type][db.idx], db.x, db.z, db.ids, db.allowSkip, db.delay, db.applyActionToRest)
        if db.audio then
            CommentaryManager.GetInstance():PlayDemoMatchCommentary(db.audio)
        end
    end
end

function DemoMatchManager:OnBlackScreenSceneStarts()
    ___matchUI.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    ___matchUI.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    TimeLineWrap.TLFreeze()
    self.dialogIdx = 0
    if self.currentScene.sceneId == SceneId.HalfTimeLockerRoom then
        self:FadeInLockerRoomBg()
    else
        self:FadeInBlackScreen()
    end

    if self.currentScene.sceneId == SceneId.GameOver then
        self:SendBI("samplematch_end", "22")
        EventSystem.SendEvent("AudienceAudioManager.FadeVolume")
    end
end

function DemoMatchManager:OnDeadBallTimeEnd()
    if self.currentScene.sceneType == SceneType.MatchClip then
        -- TODO
        if self.currentClip.playbackLength > 0 then
            self:StartPlayback()
        else
            self:ToNextScene()
        end
    elseif self.currentScene.sceneType == SceneType.DeadBall then
        TimeLineWrap.TLUnfreeze()
        self:ToNextScene()
    elseif self.currentScene.sceneType == SceneType.BlackScreen then
        -- TODO
    end
end

function DemoMatchManager:OnManualActionStarts(id, action)
    if self.currentScene.sceneId == SceneId.CRHero then
        self.manualOperateTimes = action.athleteAction.manualOperateAction.manualOperateTimes
        if self.manualOperateTimes == 2 then
            self:DelayShowDialog(0.5, 4)
        elseif self.manualOperateTimes == 3 then
            self:DelayShowDialog(0.5, 6)
        end
    end
end

function DemoMatchManager:OnManualOperateSplashEnd()
    self:ShowDialog(self.currentScene.dialogList[1])
end

function DemoMatchManager:ShowManualOperateButtonObjects()
    if self.heroTimeTimes and self.heroTimeTimes < 20 then
        self:SendBI("hero_time" .. tostring(self.heroTimeTimes) , tostring(self.heroTimeTimes))
        self.heroTimeTimes = self.heroTimeTimes + 1
    else
        self.heroTimeTimes = nil
    end
    ___matchUI.fightMenuManager.manualOperateScript:ShowManualOperateButtonObjects()
end

function DemoMatchManager:OnManualOperate(manualOperateType, id)
    if self.currentScene.sceneId == SceneId.CRHero then
        if manualOperateType == self.allowedOperation then
            self:DismissCurrentDialog()
            self.allowManualOperate = false
            self.allowedOperation = ManualOperateType.Invalid
        end
    end
end

function DemoMatchManager:IsOperationAllowed(manualOperateType)
    return self.allowManualOperate == true and self.allowedOperation == manualOperateType
end

function DemoMatchManager:RegManualOperateButton(obj, manualOperateType)
    if self.manualButtonPool == nil then
        self.manualButtonPool = {}
    end
    self.manualButtonPool[manualOperateType] = obj
end

function DemoMatchManager:OnWithBallActionStart(id, action)

end

function DemoMatchManager:OnShootStart(shooter, goal, action, athleteObject)
    self.goal = goal
    self.shootAction = action
    if self.currentScene.sceneId == SceneId.CRCornerKick then
        self:DelayShowDialog(0.7, 1)
    elseif self.currentScene.sceneId == SceneId.CRHero then
        self:DelayShowDialog(1, 8)
    elseif self.currentScene.sceneId == SceneId.CRPenalty then
        self:DelayShowDialog(0.8, 1)
    end
end

function DemoMatchManager:OnShootBallFlyEnd(shootResult)
    if self.currentScene.sceneId == SceneId.MessiFirst
        or self.currentScene.sceneId == SceneId.MessiSecond
        or self.currentScene.sceneId == SceneId.MessiThird
        or self.currentScene.sceneId == SceneId.CRCornerKick
        or self.currentScene.sceneId == SceneId.CRHero 
        or self.currentScene.sceneId == SceneId.CRPenalty then
        EventSystem.SendEvent("AudienceAudioManager.DemoMatchPlayAudio", {1})
    end
end

-- only used in match clip scenes
function DemoMatchManager:OnMatchEvent(matchFrame)
    self.matchEventCount = self.matchEventCount + 1
    if self.matchEventCount == 1 then
        if self.currentClip.playbackLength > 0 then
            ___playbackManager:StartRecording(self.currentClip.inGameStartTime, self.currentClip.playbackLength, self.currentClip.playbackStartEvent)
        end
    elseif self.matchEventCount == 2 then
        ___matchUI.fightMenuManager:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, true)

        local kicker = GameHubWrap.PeekBallHandlerOnNormalPlayOn()
        if self.currentScene.sceneId == SceneId.MessiThird then
            CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
            ___cameraCtrlCore:setDemoMatchCameraByMatchEvent(MatchEventType.CenterDirectFreeKick, kicker)
        elseif self.currentScene.sceneId == SceneId.CRCornerKick then
            CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
            ___cameraCtrlCore:setDemoMatchCameraByMatchEvent(MatchEventType.CornerKick, kicker)
        elseif self.currentScene.sceneId == SceneId.CRPenalty then
            CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
            EventSystem.SendEvent("AudienceAudioManager.DemoMatchPlayAudio", {7})
            ___cameraCtrlCore:setDemoMatchCameraByMatchEvent(MatchEventType.PenaltyKick, kicker)
        else
            ___cameraCtrlCore:setDemoMatchCameraByMatchEvent(MatchEventType.TimedKickOff, kicker)
            if self.currentScene.sceneId == SceneId.CRDiving then
                ___cameraCtrlCore:modifyDefaultFov(10)
            end
        end
    elseif self.matchEventCount == 3 then -- end of match clip
        if self.currentClip.playbackLength > 0 then
            ___playbackManager:StopRecording(matchFrame, false, 0)
        end
        if self.currentScene.sceneId == SceneId.MessiFirst
            or self.currentScene.sceneId == SceneId.MessiSecond
            or self.currentScene.sceneId == SceneId.MessiThird
            or self.currentScene.sceneId == SceneId.CRCornerKick
            or self.currentScene.sceneId == SceneId.CRHero then
            CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
            self.currentDBScenes = DeadBallScenes[self.currentScene.sceneId]
            local db = self.currentDBScenes[1]
            ___deadBallTimeManager:AddDeadBallTimeScene(DeadBallTimeConfig.Scenes[db.type][db.idx], db.x, db.z, db.ids, db.allowSkip, db.delay, db.applyActionToRest)
            ___matchUI.fightMenuManager.isDisplayTimeStop = true
        elseif self.currentScene.sceneId == SceneId.CRDiving then
            CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
            EventSystem.SendEvent("AudienceAudioManager.DemoMatchPlayAudio", {4})
            self:ToNextScene()
        elseif self.currentScene.sceneId == SceneId.CRPenalty then
            self:coroutine(function ()
                coroutine.yield(WaitForSeconds(0.5))
                self:StartPlayback()
                ___playbackManager:StartSlowMotion() --点球回放慢动作
            end)
            CommentaryManager.GetInstance():PlayDemoMatchCommentary("sm_comment_12")
        end
    end
end

function DemoMatchManager:OnPlaybackStarts()
end

function DemoMatchManager:OnPlaybackEnds()
    if self.inPlayback == true then
        self:ToNextScene()
        self.inPlayback = false
    end
end

function DemoMatchManager:GetStopPlaybackDelay()
    if self.currentScene.sceneId == SceneId.CRPenalty then
        return 0.2
    end
    return 0
end

--Only used in BlackScreen scene
function DemoMatchManager:ToNextDialogInBlackScreen()
    self.dialogIdx = self.dialogIdx + 1
    if self.dialogIdx <= #self.currentScene.dialogList then
        if self.currentScene.sceneId == SceneId.GameOver then
            if self.dialogIdx == 2 then
                self:DelayShowDialog(0.5, self.dialogIdx)
                return
            elseif self.dialogIdx == 3 then
                self:FadeInSeaBg()
                return
            elseif self.dialogIdx == 4 then
                self:FadeOutSeaBg()
                self:SendBI("talk_end", "24")
                return
            end
        end
        self:ShowDialog(self.currentScene.dialogList[self.dialogIdx])
    else
        if self.currentScene.sceneId == SceneId.HalfTimeLockerRoom then
            self:FadeOutLockerRoomBg()
        else
            self:FadeOutBlackScreen()
        end
    end
end

function DemoMatchManager:ShowDialog(dialog)
    if dialog.type == DialogType.CoachNarrate then
        self.coachNarrate:ShowDialog(dialog)
        self.currentDialog = self.coachNarrate
    elseif dialog.type == DialogType.CoachShout then
        self.coachShout:ShowDialog(dialog)
        self.currentDialog = self.coachShout
    elseif dialog.type == DialogType.CRBoard then
        self.crBoard:ShowDialog(dialog)
        self.currentDialog = self.crBoard
    elseif dialog.type == DialogType.ShootFixTargetPosition then
        self.fixTargetShoot:ShowDialog(dialog)
        self.currentDialog = self.fixTargetShoot
        if self.currentScene.sceneId == SceneId.CRCornerKick then
            self:SendBI("first_shoot", "17")
        elseif self.currentScene.sceneId == SceneId.CRHero then
            self:SendBI("second_shoot", "21")
        end
        ___matchUI:ActivateTouchShoot(self.goal, self.shootAction)
    elseif dialog.type == DialogType.ShootFixGoalGate then
        self.fixGoalShoot:ShowDialog(dialog.dialogId)
        self.currentDialog = self.fixGoalShoot
        ___matchUI:ActivateTouchShoot(self.goal, self.shootAction)
    elseif dialog.type == DialogType.ShootFree then
        self.freeShoot:ShowDialog(dialog)
        self.currentDialog = self.freeShoot
        ___matchUI:ActivateTouchShoot(self.goal, self.shootAction)
    elseif dialog.type == DialogType.Note then
        self.note:ShowDialog(dialog.dialogId, dialog.items)
        self.currentDialog = self.note
        if self.currentScene.sceneId == SceneId.Prematch then
            self:SendBI("start_samplematch", "14")
            CommentaryManager.GetInstance():PlayWhistleAudio(CommentaryConstants.KickOffWhistleAudio)
        elseif self.currentScene.sceneId == SceneId.HalfTimeLockerRoom then
            self:SendBI("half_time", "15")
        elseif self.currentScene.sceneId == SceneId.GameOver and dialog.dialogId == 2 then
            EventSystem.SendEvent("AudienceAudioManager.DestroyAllAudio")
            local bgPlayer = AudioManager.GetPlayer("commentary")
            bgPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/DemoMatch/beach_bg.mp3", 1)
            bgPlayer.loop = true
        end
    elseif dialog.type == DialogType.ScoreBoard then
        self.scoreBoard:ShowDialog(dialog)
        self.currentDialog = self.scoreBoard
    elseif dialog.type == DialogType.FadeDialog then
        self.fadeDialog:ShowDialog(dialog)
        self.currentDialog = self.fadeDialog
        self:SendBI("talk_start", "23")
    elseif dialog.type == DialogType.HeroOneOption then
        if self.manualOperateTimes == 1 then
            self.hero1Option:ShowDialog(dialog, self.manualButtonPool[ManualOperateType.Pass])
        elseif self.manualOperateTimes == 2 then
            self.hero1Option:ShowDialog(dialog, self.manualButtonPool[ManualOperateType.Dribble])
        elseif self.manualOperateTimes == 3 then
            self.hero1Option:ShowDialog(dialog, self.manualButtonPool[ManualOperateType.Shoot])
        end
        self.currentDialog = self.hero1Option
    end
end

function DemoMatchManager:DismissCurrentDialog()
    self.currentDialog:DismissDialog()
end

function DemoMatchManager:FadeInBlackScreen()
    -- TODO 淡入黑屏，如有需要，处理背景音
    self.blackScreen:SetActive(true)
    self.blackScreenAnimator:Play("Base Layer.MoveIn", 0)
end

function DemoMatchManager:FadeOutBlackScreen()
    -- TODO 淡出黑屏，如有需要，处理背景音    
    if self.currentScene.sceneId == SceneId.GameOver then
        self:EndDemoMatch()
        return
    end
    self.blackScreenAnimator:Play("Base Layer.MoveOut", 0)
    TimeLineWrap.TLUnfreeze()
    self:ToNextScene()
end

function DemoMatchManager:FadeInSeaBg()
    self.bgSea:SetActive(true)
    self.bgSeaAnim:Play("Base Layer.MoveIn", 0)
end

function DemoMatchManager:FadeOutSeaBg()
    self.bgSeaAnim:Play("Base Layer.MoveOut", 0)
end

function DemoMatchManager:FadeInLockerRoomBg()
    self.bgLockerRoom:SetActive(true)
    self.bgLockerRoomAnim:Play("Base Layer.MoveIn", 0)
end

function DemoMatchManager:FadeOutLockerRoomBg()
    self.bgLockerRoomAnim:Play("Base Layer.MoveOut", 0)
    TimeLineWrap.TLUnfreeze()
    self:ToNextScene()
    self.needDisableLockerRoomBg = true
end

function DemoMatchManager:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
        if not self.hasStarted then
        else
            if self.currentScene.sceneId == SceneId.GameOver and self.dialogIdx == 3 then
                self:ShowDialog(self.currentScene.dialogList[self.dialogIdx]) --show CR & coach dialog
            else
                self:ToNextDialogInBlackScreen()
            end
        end
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        if not self.hasStarted then
            self.bgLoading:SetActive(false)
            self.tip:SetActive(false)
            self.hasStarted = true
        else
            if self.currentScene.sceneId == SceneId.GameOver and self.dialogIdx == 4 then
                self.bgSea:SetActive(false)
                self:ShowDialog(self.currentScene.dialogList[self.dialogIdx]) --show note
            else
                if self.needDisableLockerRoomBg then
                    self.bgLockerRoom:SetActive(false)
                    self.needDisableLockerRoomBg = nil
                else
                    self.blackScreen:SetActive(false)
                end
            end
        end
    end
end

function DemoMatchManager:FlipLogo()
    ___matchUI.fightMenuManager:PlayMatchBreakAnim()
end

function DemoMatchManager:StartPlayback()
    self.inPlayback = true
    ___playbackManager:StartPlayback()
end

function DemoMatchManager:StopPlayback()
    self.inPlayback = false
    ___playbackManager:StopPlayback()
end

function DemoMatchManager:OnDemoMatchDialogDismiss(dialogId)
    if self.currentScene.sceneType == SceneType.MatchClip then
        self:OnDialogDismissInMatchClip(dialogId)
    elseif self.currentScene.sceneType == SceneType.DeadBall then
        -- TODO
    elseif self.currentScene.sceneType == SceneType.BlackScreen then
        self:ToNextDialogInBlackScreen()
    end
end

function DemoMatchManager:OnDialogDismissInMatchClip(dialogId)
    -- TODO
    if self.currentScene.sceneId == SceneId.MessiFirst
        or self.currentScene.sceneId == SceneId.MessiSecond
        or self.currentScene.sceneId == SceneId.MessiThird then
        self:StopPlayback()
        self:ToNextScene()
    elseif self.currentScene.sceneId == SceneId.CRCornerKick then
        if dialogId == 1 then
            self:ShowDialog(self.currentScene.dialogList[dialogId + 1])
        elseif dialogId == 3 then
            EmulatorInputWrap.SetIsTouchShoot(false)
            ___matchUI:ActivateTouchShoot(self.goal, self.shootAction)
        end
    elseif self.currentScene.sceneId == SceneId.CRHero then
        if dialogId == 1 then
            self:ShowDialog(self.currentScene.dialogList[dialogId + 1])
        elseif dialogId == 2 then
            self:ShowManualOperateButtonObjects()
            self:ShowDialog(self.currentScene.dialogList[dialogId + 1])
            self.allowedOperation = ManualOperateType.Pass
            self.allowManualOperate = true
        elseif dialogId == 3 then
            ___matchUI:recoverTimeScale()
        elseif dialogId == 4 then
            self:ShowManualOperateButtonObjects()
            self:ShowDialog(self.currentScene.dialogList[dialogId + 1])
            self.allowedOperation = ManualOperateType.Dribble
            self.allowManualOperate = true
        elseif dialogId == 5 then
            ___matchUI:recoverTimeScale()
        elseif dialogId == 6 then
            self:ShowManualOperateButtonObjects()
            self:ShowDialog(self.currentScene.dialogList[dialogId + 1])
            self.allowedOperation = ManualOperateType.Shoot
            self.allowManualOperate = true
        elseif dialogId == 7 then
            ___matchUI:recoverTimeScale()
        elseif dialogId == 9 then
            EmulatorInputWrap.SetIsTouchShoot(false)
            ___matchUI:ActivateTouchShoot(self.goal, self.shootAction)
        end
    end
end

function DemoMatchManager:ShouldActivateTouchShootProgressBar()
    return self.currentScene.sceneId ~= SceneId.CRCornerKick
        and self.currentScene.sceneId ~= SceneId.CRHero
end

function DemoMatchManager:EndDemoMatch()
    CommentaryManager.GetInstance():DestroyAudio()
    require("ui.controllers.login.LoginCtrl").OnDemoMatchEnd()
end

--适用于场景4-6，手划射门
function DemoMatchManager:OnTouchShootComplete(shooter, shootPath, shootAction)
    EmulatorInputWrap.SetIsTouchShoot(true)
    local shootResult = self:GetShootResult(shootPath.endPosition.x, shootPath.endPosition.y)
    if self.currentScene.sceneId == SceneId.CRCornerKick then -- 判断是否按照虚线手划
        if shootResult == AIUtils.shootResult.shootWide then
            self:ShowDialog(self.currentScene.dialogList[3])
            GameHubWrap.FingerTestRemovePath()
            self.shootResult = AIUtils.shootResult.shootWide
            return
        else
            TimeWrap.SetTimeScale(1)
        end
    elseif self.currentScene.sceneId == SceneId.CRHero then -- 判断是否在门框范围内
        if shootResult == AIUtils.shootResult.shootWide then
            self:ShowDialog(self.currentScene.dialogList[9])
            GameHubWrap.FingerTestRemovePath()
            self.shootResult = AIUtils.shootResult.shootWide
            return
        else
            TimeWrap.SetTimeScale(1)
        end
    end

    local goalProbability = shootAction.athleteAction.shootAction.goalProbability + 0.1
    self.shootResult = shootResult
    if shootResult == AIUtils.shootResult.shootWide then
        goalProbability = 0
    end
    
    local targetPosition = Vector2()
    targetPosition.x = shootPath.endPosition.x
    targetPosition.y = shootPath.endPosition.z
    local targetPositionHeight = shootPath.endPosition.y
    local projectedControlPosition = Vector2()
    projectedControlPosition.x = shootPath.controlPoint.x
    projectedControlPosition.y = shootPath.controlPoint.z
    local flyDuration = shootPath.flyDuration
    if self.currentScene.sceneId == SceneId.CRCornerKick then
        flyDuration = 0.2
    elseif self.currentScene.sceneId == SceneId.CRHero then
        flyDuration = 0.4
    elseif self.currentScene.sceneId == SceneId.CRPenalty and shootResult == AIUtils.shootResult.saveBounce then
        flyDuration = 0.4
    end
    self:EnqueuePostShoot(shooter, goalProbability, shootResult, targetPosition, targetPositionHeight, projectedControlPosition, flyDuration)

    if self.currentScene.sceneId == SceneId.CRCornerKick then
        self.fixTargetShoot:DismissDialog()
    elseif self.currentScene.sceneId == SceneId.CRHero then
        self.fixTargetShoot:DismissDialog()
    else
        self.freeShoot:DismissDialog()
    end
end

--适用于场景6，非手划
function DemoMatchManager:OnAutoShoot(shooter, shootPath, shootAction)
    local goalProbability = shootAction.athleteAction.shootAction.goalProbability
    local targetPositionHeight = ActionLayerConfig.GoalHeight + 0.1
    local shootResult = self:GetShootResult(shootPath.endPosition.x, targetPositionHeight)
    self.shootResult = shootResult
    local targetPosition = Vector2()
    targetPosition.x = shootPath.endPosition.x
    targetPosition.y = shootPath.endPosition.z

    local ballStartPos = BallActionExecutorWrap.GetBallPosition()
    local projectedControlPosition = Vector2()
    projectedControlPosition.x = (ballStartPos.x + targetPosition.x) / 2
    projectedControlPosition.y = (ballStartPos.z + targetPosition.y) / 2
    local flyDuration = 0.4

    self:DismissCurrentDialog()

    self:EnqueuePostShoot(shooter, goalProbability, shootResult, targetPosition, targetPositionHeight, projectedControlPosition, flyDuration)
end

--适用于场景1-3
function DemoMatchManager:OnOpponentShoot(shooter, shootAction)
    local goalProbability = shootAction.athleteAction.shootAction.goalProbability
    local tarPos = shootAction.athleteAction.shootAction.targetPosition
    local targetPosition = Vector2()
    targetPosition.x = tarPos.x
    targetPosition.y = tarPos.y
    local targetPositionHeight = nil
    if self.currentScene.sceneId == SceneId.MessiFirst then
        targetPositionHeight = 1.2
    elseif self.currentScene.sceneId == SceneId.MessiSecond then
        targetPositionHeight = 1.5
    elseif self.currentScene.sceneId == SceneId.MessiThird then
        targetPositionHeight = 2
    else
        targetPositionHeight = math.randomInRange(0.1, 2)
    end
    local shootResult = self:GetShootResult(targetPosition.x, targetPositionHeight)

    local ballStartPos = BallActionExecutorWrap.GetBallPosition()
    local projectedControlPosition = Vector2()
    if self.currentScene.sceneId == SceneId.MessiFirst then
        projectedControlPosition.x = (ballStartPos.x + targetPosition.x) / 2
        projectedControlPosition.y = (ballStartPos.z + targetPosition.y) / 2
    elseif self.currentScene.sceneId == SceneId.MessiSecond then
        projectedControlPosition.x = (ballStartPos.x + targetPosition.x) / 2 + math.sign(targetPosition.x - ballStartPos.x) * math.abs(ballStartPos.z - targetPosition.y) / 10
        projectedControlPosition.y = (ballStartPos.z + targetPosition.y) / 2
    else
        projectedControlPosition.x = (ballStartPos.x + targetPosition.x) / 2 + math.sign(targetPosition.x - ballStartPos.x) * math.abs(ballStartPos.z - targetPosition.y) / 8
        projectedControlPosition.y = (ballStartPos.z + targetPosition.y) / 2
    end
    local dis = math.sqrt((targetPosition.x - ballStartPos.x) ^ 2 + (targetPosition.y - ballStartPos.z) ^ 2)
    local flyDuration = nil
    if self.currentScene.sceneId == SceneId.MessiFirst then
        flyDuration = dis / 40
    elseif self.currentScene.sceneId == SceneId.MessiSecond then
        flyDuration = dis / 35
    else
        flyDuration = dis / 25
    end
    self:EnqueuePostShoot(shooter, goalProbability, shootResult, targetPosition, targetPositionHeight, projectedControlPosition, flyDuration)
end

function DemoMatchManager:GetShootResult(width, height)
    if self.currentScene.sceneId == SceneId.MessiFirst
        or self.currentScene.sceneId == SceneId.MessiSecond 
        or self.currentScene.sceneId == SceneId.MessiThird then
        return AIUtils.shootResult.goal
    elseif self.currentScene.sceneId == SceneId.CRCornerKick
        or self.currentScene.sceneId == SceneId.CRHero then
        if ActionLayerUtils.IsInGoal(width, height) then
            return AIUtils.shootResult.goal
        else
            return AIUtils.shootResult.shootWide
        end
    else
        if ActionLayerUtils.IsInGoal(width, height) then
            return AIUtils.shootResult.saveBounce
        else
            return AIUtils.shootResult.shootWide
        end
    end
end

function DemoMatchManager:EnqueuePostShoot(shooter, goalProbability, shootResult, targetPosition, targetPositionHeight, projectedControlPosition, flyDuration)
    if self.currentScene.sceneId == SceneId.CRCornerKick
        or self.currentScene.sceneId == SceneId.CRHero
        or self.currentScene.sceneId == SceneId.CRPenalty then
        flyDuration, targetPositionHeight = self:EnqueueSave(shooter, shootResult, targetPosition, targetPositionHeight, projectedControlPosition, flyDuration)
    end

    local postShoot = AthleteAction.PostShoot()
    postShoot.goalProbability = goalProbability
    postShoot.shootResult = shootResult
    postShoot.targetPosition = targetPosition
    postShoot.targetPositionHeight = targetPositionHeight
    postShoot.projectedControlPosition = projectedControlPosition
    postShoot.flyDuration = flyDuration

    local athleteAction = AthleteAction()
    athleteAction.athleteActionType = AthleteAction.ActionType.PostShoot
    athleteAction.postShootAction = postShoot

    local action = Action()
    action.athleteAction = athleteAction
    action.isWithBallAction = true

    if shooter < 11 then
        DataProvider.PlayerEnqueue(shooter, action)
    else
        DataProvider.OpponentEnqueue(shooter - 11, action)
    end
end

function DemoMatchManager:EnqueueSave(shooter, shootResult, targetBallPosition, targetBallPositionHeight, controlBallPosition, flyDuration)
    local goalKeeperId = nil
    if shooter < 11 then
        goalKeeperId = 11
    else
        goalKeeperId = 0
    end

    DataProvider.ClearActionQueue(goalKeeperId)
    DataProvider.ClearFrameQueue(goalKeeperId)

    local ballPos = BallActionExecutorWrap.GetBallPosition()
    local startBallPosition = { x = ballPos.x, y = ballPos.z }
    local startBallPositionHeight = ballPos.y
    local gkPosition = GameHubWrap.GetPlayerPosition(goalKeeperId) --vector3
    local gk = { x = gkPosition.x, y = gkPosition.z }

    local forward = vector2.norm(vector2.sub(startBallPosition, gk)) --self.bodyDirection
    local t = -1
    local a, b, c

    if math.sign(forward.y) ~= 0 then
        local _a = -forward.x / forward.y
        local _b = (forward.x * gk.x + forward.y * gk.y) / forward.y
        local k0 = startBallPosition.y - _a * startBallPosition.x
        local k1 = controlBallPosition.y - _a * controlBallPosition.x
        local k2 = targetBallPosition.y - _a * targetBallPosition.x
        a = k0 - 2 * k1 + k2
        b = 2 * (k1 - k0)
        c = k0 - _b
    else
        local a = startBallPosition.x - 2 * controlBallPosition.x + targetBallPosition.x
        local b = 2 * (controlBallPosition.x - startBallPosition.x)
        local c = startBallPosition.x - gk.x;
    end

    if math.sign(a) ~= 0 then
        local sqr = math.sqrt(b * b - 4 * a * c)
        local t1 = (-b + sqr) / (2 * a)
        local t2 = (-b - sqr) / (2 * a)
        if math.cmpf(t1, 0) >= 0 and math.cmpf(t1, 1) <= 0 then
            t = t1
        end
        if math.cmpf(t2, 0) >= 0 and math.cmpf(t2, 1) <= 0 then
            t = math.max(t2, t)
        end
    elseif math.sign(b) ~= 0 then
        local t1 = - c / b
        if math.cmpf(t1, 0) >= 0 and math.cmpf(t1, 1) <= 0 then
            t = t1
        end
    end
    if math.cmpf(t, 0) <= 0 then
        t = 0.95
    else
        t = math.min(t, 0.95)
    end

    local saveBallPosition, saveBallPositionHeight = Athlete.predictBallPositionOnCertainTime(t, flyDuration, startBallPosition, startBallPositionHeight, controlBallPosition, targetBallPosition, targetBallPositionHeight)
    local saveOffset = vector2.sub(saveBallPosition, gk)
    local sangle = vector2.sangle(forward, saveOffset)
    local cmpRe = math.cmpf(sangle, 0)
    local pivot = math.pi * 0.5
    if cmpRe > 0 then
        cmpRe = math.cmpf(sangle, pivot)
        if cmpRe > 0 then
            forward = vector2.rotate(forward, sangle - pivot)
        elseif cmpRe < 0 then
            forward = vector2.rotate(forward, sangle + pivot * 3)
        end
    elseif cmpRe < 0 then
        cmpRe = math.cmpf(sangle, -pivot)
        if cmpRe > 0 then
            forward = vector2.rotate(forward, sangle + pivot)
        elseif cmpRe < 0 then
            forward = vector2.rotate(forward, pivot + sangle)
        end
    end
    forward = vector2.norm(forward)

    local startBodyDirection = forward

    local choice, offset = Athlete.chooseSaveAction(shootResult, saveBallPosition, saveBallPositionHeight, gk, forward)
    local saveAnimation = Animations.RawData[choice]
    local saveFTBTime = saveAnimation.firstTouch * TIME_STEP
    local actualFlyDuration = saveFTBTime
    local originSaveTime = flyDuration * t
    local needPreSave = false

    local startPosition = gk
    if shootResult == AIUtils.shootResult.catch or shootResult == AIUtils.shootResult.saveBounce then
        startPosition = vector2.sub(saveBallPosition, vector2.vyrotate(saveAnimation.firstTouchBallPosition, startBodyDirection))
        flyDuration = saveFTBTime / t
        targetBallPositionHeight = Athlete.recalculateVerticalEndPoint(startBallPositionHeight, targetBallPositionHeight, saveBallPositionHeight, saveFTBTime, flyDuration)
    elseif shootResult == AIUtils.shootResult.goal then
        local newPos = vector2.sub(saveBallPosition, vector2.vyrotate(saveAnimation.firstTouchBallPosition, startBodyDirection))
        startPosition = startPosition + vector2.div(vector2.sub(newPos, startPosition), 2)
    end

    local save = AthleteAction.Save()
    save.savePosition = Vector2(saveBallPosition.x, saveBallPosition.y)
    save.savePositionHeight = saveBallPositionHeight
    if shootResult == AIUtils.shootResult.saveBounce then
        save.ikGoal = SaveActionIK[choice]
    else
        save.ikGoal = 0
    end
    save.shootResult = shootResult

    local athleteAction = AthleteAction()
    athleteAction.athleteActionType = AthleteAction.ActionType.Save
    athleteAction.saveAction = save

    local frame = Frame()
    frame.time = DemoMatchUtilWrap.GetSaveStartTime()
    frame.position = Vector2(startPosition.x, startPosition.y)
    frame.rotation = Vector2(startBodyDirection.x, startBodyDirection.y)

    local firstBallOffset = BallOffset()
    firstBallOffset.offset = Vector3(saveAnimation.firstTouchBallPosition.x, saveAnimation.firstTouchBallHeight, saveAnimation.firstTouchBallPosition.y)
    firstBallOffset.deltaTime = saveAnimation.firstTouch * 0.1
    firstBallOffset.normalizedTime = saveAnimation.firstTouch / saveAnimation.totalFrame


    local lastBallOffset = BallOffset()
    lastBallOffset.offset = Vector3(saveAnimation.lastTouchBallPosition.x, saveAnimation.lastTouchBallHeight, saveAnimation.lastTouchBallPosition.y)
    lastBallOffset.deltaTime = saveAnimation.lastTouch * 0.1
    lastBallOffset.normalizedTime = saveAnimation.lastTouch / saveAnimation.totalFrame + 1e-6

    local action = Action()
    action.nameHash = Animator.StringToHash("Base Layer." .. saveAnimation.name)
    action.actionStartFrame = frame
    action.firstBallOffset = firstBallOffset
    action.lastBallOffset = lastBallOffset
    action.athleteAction = athleteAction

    if shootResult == AIUtils.shootResult.saveBounce then
        action.isWithBallAction = true
    else
        action.isWithBallAction = false
    end

    if goalKeeperId < 11 then
        DataProvider.PlayerEnqueue(goalKeeperId, action)
    else
        DataProvider.OpponentEnqueue(goalKeeperId - 11, action)
    end
    return flyDuration, targetBallPositionHeight
end

function DemoMatchManager:DelayShowDialog(delay, dialogId)
    self:coroutine(function ()
        local startTime = TimeWrap.GetUnscaledTime()
        while TimeWrap.GetUnscaledTime() - startTime < delay
        do
            unity.waitForNextEndOfFrame()
        end
        self:ShowDialog(self.currentScene.dialogList[dialogId])
    end)
end

function DemoMatchManager:DelayCommentaryClip(delay, commentaryClip)
    self:coroutine(function ()
        coroutine.yield(WaitForSeconds(delay))
        CommentaryManager.GetInstance():PlayDemoMatchCommentary(commentaryClip)
    end)
end

function DemoMatchManager:SendBI(step, seq)
    luaevt.trig("HoolaiBISendGameinfo", step, seq)
    luaevt.trig("SendBIReport", step, seq)
end

function DemoMatchManager:DisableLoadingBg()
    self.bgLoadingAnim:Play("Base Layer.MoveOut", 0)
    self.bgLoadingAnim.speed = 2
end

return DemoMatchManager
