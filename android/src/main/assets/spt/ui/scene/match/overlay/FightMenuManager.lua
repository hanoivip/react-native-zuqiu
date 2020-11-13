local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Canvas = UnityEngine.Canvas
local Time = UnityEngine.Time
local Color = UnityEngine.Color
local UI = UnityEngine.UI
local Text = UI.Text
local Outline = UI.Outline
local BoxCollider = UnityEngine.BoxCollider
local CoreGameController = clr.ActionLayer.CoreGameController
local DataProvider = clr.ActionLayer.DataProvider
local Highlighting = clr.Highlighting
local Tweening = clr.DG.Tweening
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType
local ParticleSystem = UnityEngine.ParticleSystem
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local Mathf = UnityEngine.Mathf
local Space = UnityEngine.Space
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav

local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local SkillData = require('data.Skills')
local MatchInfoModel = require("ui.models.MatchInfoModel")
local EventSystem = require("EventSystem")
local MatchConstants = require("ui.scene.match.MatchConstants")
local CommentaryManager = require("ui.control.manager.CommentaryManager")
local MusicManager = require("ui.control.manager.MusicManager")
local ShootLineManager = require("coregame.ShootLineManager")
local EnumType = require("coregame.EnumType")
local QuestPageViewModel = require("ui.models.quest.QuestPageViewModel")
local LoseGuideCtrl = require("ui.controllers.loseGuide.LoseGuideCtrl")
local LadderShowRankchgCtrl = require("ui.controllers.ladder.LadderShowRankchgCtrl")
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ManualOperateType = EnumType.ManualOperateType

local FightMenuManager = class(unity.base)

local GameUIAnimation =
{
    selfObject = nil,
    showTime = 0,
    isDelete = false,
    isMove = false
}

function FightMenuManager:FormatTime(time)
    local actualTime = time * 30
    local hour = math.floor(actualTime / 60)
    local minute = math.ceil(actualTime % 60)
    return string.format("%02d : %02d", hour, minute)
end

function FightMenuManager:FormatTimeForPanel(time)
    local actualTime = time * 30
    local hour = math.floor(actualTime / 60)
    local minute = math.ceil(actualTime % 60)
    return string.format("%02d'", hour)
end

function FightMenuManager:onPanelClickChange()
    for k, v in pairs(self.listenerOnPanelClickChange) do
        if type(v) == 'function' then
            v()
        end
    end
end

function FightMenuManager:RegOnPanelClickChange(func,key)
    if func == nil or key == nil then
        print("Error panel Click")
    end
    self.listenerOnPanelClickChange[key] = func
end

function FightMenuManager:UnregOnPanelClickChange(key)
    self.listenerOnPanelClickChange[key] = nil
end

function FightMenuManager:ctor()
    self.listenerOnPanelClickChange = { }
    self.fightUIData = self.___ex.fightUIData:GetComponent(CapsUnityLuaBehav)
    self.playerNameObject = self.___ex.playerNameObject
    self.teamScoreObject = self.___ex.teamScoreObject
    self.noteObject = self.___ex.noteObject
    self.playerGoalObject = self.___ex.playerGoal
    self.playerShootPanelObject = self.___ex.playerShootPanelObject
    self.deployedPanelObject = self.___ex.deployedPanelObject
    self.substitutePanelObject = self.___ex.substitutePanelObject
    self.skipButtonObject = self.___ex.skipButtonObject
    self.foulPanelObject = self.___ex.foulPanelObject
    self.athleteLabelsObject = self.___ex.athleteLabelsObject
    self.preMatchManager = self.___ex.preMatchManager
    self.scoreBarGoalObject = self.___ex.scoreBarGoalObject
    self.settlementSystemObject = self.___ex.settlementSystemObject
    self.shootBallEffectObject = self.___ex.shootBallEffectObject
    self.ballEffectObject = self.___ex.ballEffectObject
    self.statePanelObject = self.___ex.statePanelObject
    self.manualOperateContainerObject = self.___ex.manualOperateContainerObject
    self.manualOperateWorldCanvasObject = self.___ex.manualOperateWorldCanvasObject
    self.replayLogo = self.___ex.replayLogo
    self.matchBreak = self.___ex.matchBreak

    self.skipButtonComponent = self.skipButtonObject:GetComponent(CapsUnityLuaBehav)
    self.skipButtonTitle = self.___ex.skipButtonTitle:GetComponent(Text)
    self.gameObjectAnimationList = { }
    self.playerNameComponent = self.playerNameObject:GetComponent(CapsUnityLuaBehav)
    self.teamScoreComponent = self.teamScoreObject:GetComponent(CapsUnityLuaBehav)
    self.playerGoalComponent = self.playerGoalObject:GetComponent(CapsUnityLuaBehav)
    self.noteComponent = self.noteObject:GetComponent(CapsUnityLuaBehav)
    self.playerShootPanelComponent = self.playerShootPanelObject:GetComponent(CapsUnityLuaBehav)
    self.deployedPanelComponent = self.deployedPanelObject:GetComponent(CapsUnityLuaBehav)
    self.substitutePanelComponent = self.substitutePanelObject:GetComponent(CapsUnityLuaBehav)
    self.foulPanelComponent = self.foulPanelObject:GetComponent(CapsUnityLuaBehav)
    self.athleteLabelsComponent = self.athleteLabelsObject:GetComponent(clr.AthleteLabels)
    self.labelManager = self.athleteLabelsObject:GetComponent(CapsUnityLuaBehav)
    self.scoreBarGoalComponent = self.scoreBarGoalObject:GetComponent(CapsUnityLuaBehav)
    self.shootBallEffectComponent = self.shootBallEffectObject:GetComponent(CapsUnityLuaBehav)
    self.statePanelComponent = self.statePanelObject:GetComponent(CapsUnityLuaBehav)

    self.canvasWidth = 0
    self.canvasHeight = 0
    self.selfCanvas = self.transform:GetComponent(Canvas)

    self.isRequestCompleted = false

    self.goalAnimationObject = nil

    self.skipButtonComponent:regOnButtonUp(function()
        self.skipButtonTitle.color = Color(0.44, 0.3, 0, 1)
    end)
    self.skipButtonComponent:regOnButtonDown(function()
        self.skipButtonTitle.color = Color(1, 1, 1, 1)
    end)
    self.skipButtonComponent:regOnButtonClick(function()
        self:SkipOpening()
    end)

    self.displayTimeOffset = 0
    self.stoppageTime = 0
    self.previousTime = 0
    self.matchStage = 0
    self.isGameOver = nil

    self.noteMenuInteractable = nil

    self.athleteSkillEffectList = {}
    self.currentMatchStageId = nil
    self.hasShowSkipGuide = false
    self.matchInfoModel = nil
end

function FightMenuManager:start()
    self.matchInfoModel = MatchInfoModel.GetInstance()
    local playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    local opponentTeamData = self.matchInfoModel:GetOpponentTeamData()

    self.isRequestCompleted = false
    PrefabCache.load()
    self:RegisterEvent()
    self:RegisterScreenClickEvent()

    if self.matchInfoModel:IsDemoMatch() then
        self.noteObject:SetActive(false)
        self.skipButtonObject:SetActive(false)
    end

    self:InitManualOperate()
    res.GetLuaScript(self.statePanelObject):init()

    if self.matchInfoModel:GetMatchType() == MatchConstants.MatchType.QUEST then
        local questPageViewModel = QuestPageViewModel.new()
        self.currentMatchStageId = questPageViewModel:GetMatchStageId()
    end
end

--- 注册事件
function FightMenuManager:RegisterEvent()
    EventSystem.AddEvent("FightMenuManager.ShowPlayerGoalPanel", self, self.ShowPlayerGoalPanel)
    EventSystem.AddEvent("FightMenuManager.ExitScene", self, self.ExitScene)
    EventSystem.AddEvent("FightMenuManager.CloseViewsOnCertainTime", self, self.CloseViewsOnCertainTime)
    EventSystem.AddEvent("OnMatchScoreChange", self, self.OnMatchScoreChange)
    EventSystem.AddEvent("FightMenuManager.UpdatePlayerState", self, self.UpdatePlayerState)
    EventSystem.AddEvent("FightMenuManager.OpenFingerGesture", self, self.OpenFingerGesture)
    EventSystem.AddEvent("FightMenuManager.CloseFingerGesture", self, self.CloseFingerGesture)
end

--- 移除事件
function FightMenuManager:RemoveEvent()
    EventSystem.RemoveEvent("FightMenuManager.ShowPlayerGoalPanel", self, self.ShowPlayerGoalPanel)
    EventSystem.RemoveEvent("FightMenuManager.ExitScene", self, self.ExitScene)
    EventSystem.RemoveEvent("FightMenuManager.CloseViewsOnCertainTime", self, self.CloseViewsOnCertainTime)
    EventSystem.RemoveEvent("OnMatchScoreChange", self, self.OnMatchScoreChange)
    EventSystem.RemoveEvent("FightMenuManager.UpdatePlayerState", self, self.UpdatePlayerState)
    EventSystem.RemoveEvent("FightMenuManager.OpenFingerGesture", self, self.OpenFingerGesture)
    EventSystem.RemoveEvent("FightMenuManager.CloseFingerGesture", self, self.CloseFingerGesture)
end

function FightMenuManager:UpdatePlayerState()
    self.statePanelComponent:UpdatePlayerState()
end

function FightMenuManager:updateNoteMenuButton()
    if self.noteMenuInteractable and not MatchInfoModel.GetInstance():IsReplay() then
        self.noteComponent:EnableButton()
        -- TODO 将来改回        
        -- 特殊赛事先屏蔽掉换人
        if MatchInfoModel:GetInstance():GetMatchType() == MatchConstants.MatchType.SPECIFIC then
            self.noteComponent:DisableChangeButton()
        end
    else
        self.noteComponent:DisableButton()
        if MatchInfoModel.GetInstance():IsReplay() then
            self.noteComponent:EnableSkipButton()
        end
    end
end

function FightMenuManager:EnableAccelerateBtn()
    self.noteComponent:EnableAccelerateBtn()
end

function FightMenuManager:DisableAccelerateBtn()
    self.noteComponent:DisableAccelerateBtn()
end

local stopTimes = {0, 90, 180, 210, 240, 240}

function FightMenuManager:update()
    if self.teamScoreObject.activeSelf then
        local currentTime = TimeLineWrap.TLMatchTime() - self.displayTimeOffset

        local minTime = stopTimes[self.matchStage] or 0
        local maxTime = self.matchStage and stopTimes[self.matchStage + 1] or 0

        local displayTime = math.clamp(currentTime, minTime, maxTime)

        if self.isGameOver then
            displayTime = self.matchStage > 2 and stopTimes[5] or stopTimes[3]
        end

        self.teamScoreComponent:UpdateMatchTime(self:FormatTime(displayTime))

        if self.previousTime < maxTime and maxTime <= currentTime then
            self.teamScoreComponent:SetMatchAddTime(self:FormatTime(self.stoppageTime), 4)
        end

        self.previousTime = currentTime
    end
end

function FightMenuManager:SetPanelActive(panel, isActive)
    if panel == MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL then
        -- CurrentUIPanel.playerNamePanel then
        self.playerNameObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL then
        -- CurrentUIPanel.teamNamePanel then
        self.teamScoreObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.PLAYER_GOAL_PANEL then
        -- CurrentUIPanel.playerGoalPanel then
        self.playerGoalObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.FOUL_PANEL then
        self.foulPanelObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.PLAYER_SHOOT_PANEL then
        -- CurrentUIPanel.playerShootPanel then
        if isActive then
            -- self:CloseViewsOnCertainTime()
        end
        self.playerShootPanelObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL then
        -- CurrentUIPanel.noteMenuPanel then
        self.noteObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.SKIP_BUTTON then
        -- CurrentUIPanel.skipButton
        self.skipButtonObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.SCORE_BAR_GOAL then
        self.scoreBarGoalObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.SETTLEMENT_SYSTEM then
        self.settlementSystemObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.SHOOT_BALL_EFFECT then
        self.shootBallEffectObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.STATE_PANEL then
        self.statePanelObject:SetActive(isActive)
    elseif panel == MatchConstants.CurrentUIPanel.REPLAY_LOGO_PANEL then
        self.replayLogo:SetActive(isActive)
    end
end

function FightMenuManager:ShowPlayerGoalPanel()
    self.playerGoalComponent:PlayMoveInAnim()
end

function FightMenuManager:MoveTeamScorePanel()
    self.teamScoreComponent:MoveOutIn()
end

function FightMenuManager:InitialPlayerName(athlete, isPlayer)
    self.playerNameComponent:Init(athlete, isPlayer, true)
end

function FightMenuManager:InitialTeamName(leftTeam, rightTeam, score)
    self.teamScoreComponent:InitTeamScore(leftTeam, rightTeam, score)
end

function FightMenuManager:InitialDisplayTime(gameTime)
    self.teamScoreComponent:InitTime(gameTime)
end

function FightMenuManager:InitialTeamMatchAddTime(overtime, deltaTime)
    self.teamScoreComponent:SetMatchAddTime(overtime, deltaTime)
end

function FightMenuManager:InitialScoreBarGoal(score)
    self.scoreBarGoalComponent:Init(score)
end

function FightMenuManager:InitialScoreInfo(isPlayer, athleteData, score, useTime, deltaTime)
    self:InitialScoreBarGoal(score)
    self.playerGoalComponent:Init(isPlayer, athleteData, score, self:FormatTimeForPanel(useTime - self.displayTimeOffset))
end

function FightMenuManager:InitialPlayerShootData(athleteData, playerFight, playerShootData, duration, isPlayer)
    self.playerShootPanelComponent:InitPlayerShootInfo(athleteData, playerFight, playerShootData, duration, isPlayer)
end

function FightMenuManager:InitialDeployedInfo()
    self.deployedPanelObject:SetActive(true)
    self.deployedPanelComponent:Display()
end

function FightMenuManager:InitialFoulInfo(isPlayer, number, name, time, foulType)
    self.foulPanelObject:SetActive(true)
    self.foulPanelComponent:Display(isPlayer, number, name, self:FormatTimeForPanel(time - self.displayTimeOffset), foulType)
end

function FightMenuManager:InitialSubstituteInfo(data)
    self.substitutePanelObject:SetActive(true)
    self.substitutePanelComponent:Init(data)
end

function FightMenuManager:InitialPlayerShootState(successRate, shootEvaluationType)
    self.playerShootPanelComponent:InitPlayerShootState(successRate, shootEvaluationType)
end

function FightMenuManager:HideShoot()
    self.playerShootPanelComponent.gameObject:SetActive(false)
end

function FightMenuManager:HideMatchAddTime()
    self.teamScoreComponent:HideMatchAddTime()
end

function FightMenuManager:ShowShootBallEffect()
    self:SetPanelActive(MatchConstants.CurrentUIPanel.SHOOT_BALL_EFFECT, true)
    self.shootBallEffectComponent:InitView()
end

function FightMenuManager:HighlightBallOwner(onfieldId)
    if not PrefabCache.EffectSelect then
        return
    end
    if not self.ballOwnerObj then
        self.ballOwnerObj = Object.Instantiate(PrefabCache.EffectSelect)
    end
    if onfieldId then
        self.ballOwnerObj:SetActive(true)
        local athleteObj = ___matchUI:getAthleteObject(onfieldId)
        self.ballOwnerObj.transform:SetParent(athleteObj.transform, false)
    else
        self.ballOwnerObj:SetActive(false)
    end
end

local whiteColor = Color(1, 1, 1)
local grayColor = Color(0.5, 0.5, 0.5)
local skillTextColor = Color(1, .922, 0.392)
local skillOutlineColor = Color(.686, .431, .078)

function FightMenuManager:DisplayLabel(athlete, athleteObject, labelText, priority, displayTime, delayTime, textColor, outlineColor, callbackFunc)
    self.labelManager:DisplayLabel(athlete, athleteObject, labelText, nil, nil, priority, displayTime, delayTime, textColor, outlineColor, callbackFunc)
end

function FightMenuManager:RemoveLabel(onfieldId, athleteObject)
    self.labelManager:RemoveLabel(onfieldId, athleteObject)
end

function FightMenuManager:RemoveAllLabel()
    for onfieldId = 0, 21 do
        local obj = ___matchUI:getAthleteObject(onfieldId)
        self:RemoveLabel(onfieldId, obj)
    end
end

function FightMenuManager:RemoveAllEffect()
    for onfieldId = 1, 22 do
        local skillObj = self.athleteSkillEffectList[onfieldId]
        if skillObj then
            skillObj:SetActive(false)
        end
    end
end

local skillValuePrefix = {
    A07 = "+",
    B03 = lang.transstr("match_skill_all") .. "+",
    G01 = "+",
    G02 = lang.transstr("match_skill_all") .. "+",
    G03 = lang.transstr("match_skill_all") .. "+",
}

function FightMenuManager:onSkillLabelDisplay(athlete, obj, skill)
    local skillId = skill.SkillId
    local skillName = SkillData[skillId] and SkillData[skillId].skillName
    if skillName then
        local skillValue
        if skill.Reserved1 and skill.Reserved1 ~= 0 then
            skillValue = (skillValuePrefix[skillId] or "") .. tostring(skill.Reserved1) .. "%"
        elseif skill.TargetOnfieldId and skill.TargetOnfieldId ~= 0 then
            skillValue = ___matchUI:getAthlete(GameHubWrap.GetAthleteId(skill.TargetOnfieldId)).name
        end
        self.labelManager:DisplayLabel(athlete, obj, skillName, skillId, skillValue, 3, 1, nil, skillTextColor, skillOutlineColor, function()
            local prefix = string.sub(skillId, 1, 1)
            if prefix == 'C' or prefix == 'D' then
                ___matchUI:onDisplayName(athlete, obj)
            end
        end)
    end
end

function FightMenuManager:InitialSkillEffect(athlete, obj, skillId)
    if self.manualOperateObject and self.manualOperateObject.activeSelf then
        return
    end

    self:coroutine(function()
        -- skill effect
        local skillObject = PrefabCache.EffectSelectPool:getObject()
        skillObject:SetActive(true)
        skillObject.transform:SetParent(obj.transform, false)
        if self.athleteSkillEffectList[athlete.onfieldId] then
            self.athleteSkillEffectList[athlete.onfieldId]:SetActive(false)
        end
        self.athleteSkillEffectList[athlete.onfieldId] = skillObject

        coroutine.yield(UnityEngine.WaitForSeconds(2))

        -- remove skill effect
        skillObject:SetActive(false)
        PrefabCache.EffectSelectPool:returnObject(skillObject)
        if self.athleteSkillEffectList[athlete.onfieldId] == skillObject then
            self.athleteSkillEffectList[athlete.onfieldId] = nil
        end
    end)
end

function FightMenuManager:InitUIAnimation(gameObject, deltaTime, delete, move)
    for k, v in pairs(self.gameObjectAnimationList) do
        if v.selfObject == gameObject then
            v.showTime = deltaTime
            return
        end
    end

    local gameUiAnimation = { }
    gameUiAnimation.selfObject = gameObject
    gameUiAnimation.showTime = deltaTime
    gameUiAnimation.isDelete = delete
    gameUiAnimation.isMove = move
    table.insert(self.gameObjectAnimationList, gameUiAnimation)
end

function FightMenuManager:onPointerClick(eventData)
    self:onPanelClickChange()
end

function FightMenuManager:onButtonClick()
    self:onButtonClickChange()
end

function FightMenuManager:PlayGoalAnimation()
    self.goalAnimationObject = Object.Instantiate(PrefabCache.goalAnimation)
end

function FightMenuManager:StopGoalAnimation()
    self.goalAnimationObject = nil
    EventSystem.SendEvent("Match_DestroyGoal")
end

function FightMenuManager:ShowMatchOverData(data)
    if self.penaltyShootOutBar then
        self.penaltyShootOutBar:SetActive(false)
    end
    self:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.SETTLEMENT_SYSTEM, true)
end

function FightMenuManager:onRequestCompleted(response)
    self.isRequestCompleted = true
    self.response = response
end

local function CleanGlobalVarOnExit()
    ___matchUI = nil
    ___upperBodyUtil = nil
    ___playbackManager = nil
    ___deadBallTimeManager = nil
    ___cameraCtrlCore = nil
end

function FightMenuManager:ExitScene()
    luaevt.trig("SetOnBackType", "forbid")
    local matchType = self.matchInfoModel:GetMatchType()
    EventSystem.SendEvent("ShadowManager.ReleaseCamera")
    local matchResult = self.matchInfoModel:GetMatchResult()
    CommentaryManager.GetInstance():DestroyAudio()
    clr.coroutine(function()
        CleanGlobalVarOnExit()
        res.DestroyAll()
        -- 点击特效
        -- local touchEffect = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/EffectClick/TouchEffect.prefab")
        -- res.DestroyAllExceptSaved()
        local loading = res.Instantiate('Assets/CapstonesRes/Game/UI/Match/Loading/SceneLoading.prefab')
        res.DontDestroyOnLoad(loading)

        clr.coroutine(function()
            unity.waitForNextEndOfFrame()

            TimeWrap.SetTimeScale(1)
            CoreGameController.Stop()

            print("DataProvider continue on ExitScene")
            DataProvider.Continue()

            Object.Destroy(self.manualOperateObject)
            if self.penaltyShootOutBar then
                Object.Destroy(self.penaltyShootOutBar)
            end
            PrefabCache.destroy()
            DataProvider.Reset()

            unity.waitForNextEndOfFrame()

            res.CollectGarbageDeep(function()
                luaevt.trig("SetOnBackType", "common")
                res.PopSceneWithoutCurrent()
                unity.waitForNextEndOfFrame()
                Object.Destroy(loading)
                MusicManager.play(0.2)
                LadderShowRankchgCtrl.new(matchResult)
                if matchType == MatchConstants.MatchType.PEAK or matchType == MatchConstants.MatchType.TRANSPORT 
                    or matchType == MatchConstants.MatchType.WORLDBOSS
                    or matchType == MatchConstants.MatchType.ADVENTURE then
                    return
                end
                LoseGuideCtrl.new(matchResult)
            end)
        end)
    end)
end

function FightMenuManager:DisableNoteButton()
    self.noteMenuInteractable = nil
    self:updateNoteMenuButton()
end

function FightMenuManager:EnableNoteButton()
    self.noteMenuInteractable = true
    self:updateNoteMenuButton()
end

function FightMenuManager:SkipOpening()
    GameHubWrap.DoMatchStart()
end

function FightMenuManager:InitManualOperate()
    self.manualOperateObject = Object.Instantiate(PrefabCache.manualOperatePanelObj)
    self.manualOperateObject.transform:SetParent(self.manualOperateContainerObject.transform, false)
    self.manualOperateObject:SetActive(false)

    self.manualOperateScript = res.GetLuaScript(self.manualOperateObject)
    self.manualOperateScript.fightMenuManager = self
    self.manualOperateScript:InitManualOperateButtonConfig()
end

function FightMenuManager:InitAthleteManualOperateEffect(athlete, manualOperateAction, manualOperateAthleteObject, manualOperateAthleteOnfieldId)
    self:RemoveAllLabel()
    self:RemoveAllEffect()
    self:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)
    self.manualOperateContainerObject:SetActive(true)

    local manualOperateAthletePosition = manualOperateAthleteObject.transform.position
    self.manualOperateScript:ShowManualOperateView(manualOperateAction, manualOperateAthletePosition, athlete, manualOperateAthleteOnfieldId)
    self.playerNameComponent:Init(athlete, true, true)
end

function FightMenuManager:OnDisableUnselectedButtons()
    self.manualOperateScript:DisableUnselectedButtons()
end

function FightMenuManager:OnClearAthleteManualOperateEffect()
    local overEffectDuration = self.manualOperateScript:ShowOverEffect()
    if overEffectDuration then
        self:coroutine(function ()
            local startTime = TimeWrap.GetUnscaledTime()
            while TimeWrap.GetUnscaledTime() - startTime < overEffectDuration do
                coroutine.yield(UnityEngine.WaitForEndOfFrame())
            end
            self:ClearManualOperateEffectImpl()
        end)
    else
        self:ClearManualOperateEffectImpl()
    end
end

function FightMenuManager:ClearManualOperateEffectImpl()
    self.manualOperateScript:ClearManualOperateView()

    if EmulatorInputWrap.GetManualOperateType() == ManualOperateType.Pass then
        self.ballEffectObject:SetActive(true)
    end

    self:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, true)
    if not MatchInfoModel.GetInstance():IsDemoMatch() then
        self:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, true)
    end
    self.manualOperateContainerObject:SetActive(false)

    if not MatchInfoModel.GetInstance():IsDemoMatch() then
        self:RecoverTimeScale()
    end
end

function FightMenuManager:RecoverTimeScale()
    local duration = 0.2
    self:coroutine(function ()
        local startTime = TimeWrap.GetUnscaledTime()
        while TimeWrap.GetUnscaledTime() - startTime < duration do
            coroutine.yield(UnityEngine.WaitForEndOfFrame())
            local timeScale = math.lerp(self.manualOperateScript.slowdownTimeScale, self.manualOperateScript.nowTimeScale, (TimeWrap.GetUnscaledTime() - startTime) / duration)
            TimeWrap.SetTimeScale(math.min(timeScale, self.manualOperateScript.nowTimeScale))
        end
        TimeWrap.SetTimeScale(self.manualOperateScript.nowTimeScale)
    end)
end

function FightMenuManager:OnTouchShootActivated(callback)
    self.playerShootPanelComponent:OnTouchShootActivated(callback)
end

function FightMenuManager:OnTouchShootDeactivated()

end

function FightMenuManager:OnManualOperateActivated()

end

function FightMenuManager:OnManualOperateDeactivated()

end

function FightMenuManager:DisablePreMatch()
    self.preMatchManager.gameObject:SetActive(false)
end

function FightMenuManager:EnablePreMatch()
    self.preMatchManager.gameObject:SetActive(true)
end

function FightMenuManager:onAthleteBuff(buff)
    -- TODO:接入BuffUI
    -- print(
    --     "buffId=" .. buff.BuffId .. " " ..
    --     "time=" .. buff.Time .. " " ..
    --     "athleteId=" .. buff.AthleteId .. " " ..
    --     "value=" .. buff.Value .. " " ..
    --     "state=" .. buff.State .. " " ..
    --     "skillId=" .. buff.SkillId .. " "
    -- )
    self.statePanelComponent:onAthleteBuff(buff)

    if buff.State == 0 then
        local legendSkillIds = {
            -- 战神区域
            "D07_A",
            -- 风驰电掣
            "B01_A",
            -- 中场指挥家
            "B03_A",
            -- 蓝桥大脑
            "C04_A",
            -- 永不疲倦
            "G01_A",
        }

        if table.isArrayInclude(legendSkillIds, buff.SkillId) then
            local athleteObj = ___matchUI:getAthleteObject(buff.OnfieldId - 1)
            local duration = buff.SkillId == "B01_A" and 2 or nil
            if self:ShowSkillPlayerEffect(buff.SkillId, athleteObj, duration) then
                return false
            end
        end

        if buff.SkillId == "A02" or buff.SkillId == "A07" or buff.SkillId == "A08"
            or buff.SkillId == "G01" or buff.SkillId == "G02" or buff.SkillId == "G03"
            or buff.SkillId == "B03" or buff.SkillId == "D05" or buff.SkillId == "E08" then
            local athleteObj = ___matchUI:getAthleteObject(buff.OnfieldId - 1)
            local buffPool = buff.Value > 0 and PrefabCache.PlayerBuffPool or PrefabCache.PlayerDebuffPool
            local buffObj = buffPool:getObject()
            buffObj.transform:SetParent(athleteObj.transform, false)
            buffObj:SetActive(true)
            self:coroutine(function()
                local endtime = Time.realtimeSinceStartup + 0.9
                repeat 
                    coroutine.yield()
                until Time.realtimeSinceStartup >= endtime
                buffObj:SetActive(false)
                buffPool:returnObject(buffObj)
            end)
        end
    end
end

function FightMenuManager:ShowSkillPlayerEffect(skillId, parentObj, duration)
    local skillEffectPool = PrefabCache.getSkillEffectPool(skillId, "Player")
    return self:ShowSkillEffect(skillEffectPool, parentObj, duration)
end

function FightMenuManager:ShowSkillBallEffect(skillId, parentObj, duration)
    local skillEffectPool = PrefabCache.getSkillEffectPool(skillId, "Ball")
    return self:ShowSkillEffect(skillEffectPool, parentObj, duration)
end

function FightMenuManager:ShowSkillEffect(skillEffectPool, parentObj, duration)
    if skillEffectPool ~= nil then
        local skillEffectObj = skillEffectPool:getObject()
        skillEffectObj.transform:SetParent(parentObj.transform, false)
        GameObjectHelper.FastSetActive(skillEffectObj, true)
        self:coroutine(function ()
            coroutine.yield(UnityEngine.WaitForSeconds(duration or 1.5))
            GameObjectHelper.FastSetActive(skillEffectObj, false)
            if skillEffectPool ~= nil then
                skillEffectPool:returnObject(skillEffectObj)
            end
        end)
        return true
    end

    return false
end

function FightMenuManager:setStatePanelVisible(visible)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.STATE_PANEL, visible)
end

function FightMenuManager:StartPlayback()
    if MatchInfoModel.GetInstance():IsDemoMatch() then
        self:MoveInReplayLogo()
    else
        self:PlayMatchBreakAnim()
    end
    self:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
end

function FightMenuManager:StopPlayback()
    if MatchInfoModel.GetInstance():IsDemoMatch() then
        self:MoveOutReplayLogo()
    else
        self:PlayMatchBreakAnim()
        self:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, true)
        if not ___matchUI.inPenaltyShootOut then
            self:coroutine(function()
                coroutine.yield(UnityEngine.WaitForSeconds(0.8))
                self:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, true)
            end)
        end
    end
    self:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, true)
end

function FightMenuManager:StartPlaybackMatchHighlights()
    self:SetPanelActive(MatchConstants.CurrentUIPanel.NOTE_MENU_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.TEAM_SCORE_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.PLAYER_NAME_PANEL, false)
    self:SetPanelActive(MatchConstants.CurrentUIPanel.SETTLEMENT_SYSTEM, false)
end

function FightMenuManager:OnPlaybackMatchHighlightsEnd()
    self:SetPanelActive(MatchConstants.CurrentUIPanel.SETTLEMENT_SYSTEM, true)
end

function FightMenuManager:SkipPlayback()
    ___playbackManager:SkipPlayback()
end

function FightMenuManager:SkipDeadBallTime()
    ___deadBallTimeManager:TryToSkipDeadBallTimeScene()
end

function FightMenuManager:RegisterScreenClickEvent()
    self:RegOnPanelClickChange(self.SkipPlayback, "FightMenuManager.SkipPlayback")
    self:RegOnPanelClickChange(self.SkipDeadBallTime, "FightMenuManager.SkipDeadBallTime")
end

function FightMenuManager:UnregisterScreenClickEvent()
    self:UnregOnPanelClickChange("FightMenuManager.SkipPlayback")
    self:UnregOnPanelClickChange("FightMenuManager.SkipDeadBallTime")
end

function FightMenuManager:onDestroy()
    self:RemoveEvent()
    self:UnregisterScreenClickEvent()
end

function FightMenuManager:PlayMatchBreakAnim()
    self.isMatchBreakMoveIn = not self.isMatchBreakMoveIn
    self.matchBreak:SetActive(true)
    if not self.isMatchBreakMoveIn and not MatchInfoModel.GetInstance():IsDemoMatch() then
        self:MoveOutReplayLogo()
    end
end

function FightMenuManager:OnMatchBreakAnimEnd()
    self.matchBreak:SetActive(false)
    ___playbackManager:OnMatchBreakAnimEnd()
    if self.isMatchBreakMoveIn and not MatchInfoModel.GetInstance():IsDemoMatch() then
        self:MoveInReplayLogo()
    end
end

function FightMenuManager:MoveInReplayLogo()
    -- self.replayLogo:SetActive(true)
    -- self.replayImgAnim:Play("ReplayLogoMoveIn")
end

function FightMenuManager:MoveOutReplayLogo()
    -- self.replayLogoMask:SetActive(false)
    -- self.replayImgAnim:Play("ReplayLogoMoveOut")
end

function FightMenuManager:OnReplayLogoMoveOut()
    -- self.replayLogo:SetActive(false)
end

--- 在英雄时刻、射门、结算等时刻关闭一些界面
function FightMenuManager:CloseViewsOnCertainTime()
    EventSystem.SendEvent("NoteMenu.HideStatePanel")
    EventSystem.SendEvent("TacticsDlg.Destroy")
    EventSystem.SendEvent("FormationPageView.Destroy")
    EventSystem.SendEvent("Match_DestroyGoal")
end

function FightMenuManager:OnMatchScoreChange(playerScore, opponentScore)
    local autoSkipQuests = cache.getAutoSkipQuestStageStateListe() or { ["Q101"] = true, ["Q102"] = true }
    if self.currentMatchStageId and autoSkipQuests[self.currentMatchStageId] and not self.hasShowSkipGuide and playerScore - opponentScore == 2 then
        self.hasShowSkipGuide = true
        local skipMatch = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/PlayerGuide/SkipMatch.prefab")
        local skipMatchScript = res.GetLuaScript(skipMatch)
        skipMatchScript:InitView(MatchInfoModel.GetInstance())
    end
end

function FightMenuManager:OnPenaltyShootOutStart()
    self.noteComponent:EnterPenaltyShootOut()
end

function FightMenuManager:OnPenaltyShootOutKickResult(matchInfo)
    if not self.penaltyShootOutBar then
        self.penaltyShootOutBar = res.Instantiate("Assets/CapstonesRes/Game/UI/Match/Overlay/PenaltyShootOutBar.prefab")
        self.penaltyShootOutBar.transform:SetParent(self.transform, false)
        self.penaltyShootOutBarScript = res.GetLuaScript(self.penaltyShootOutBar)
    end
    self.penaltyShootOutBarScript:SetPenaltyShootOutData(matchInfo)
end

function FightMenuManager:OpenFingerGesture()
    self.fingerGesture.enabled = true
end

function FightMenuManager:CloseFingerGesture()
    self.fingerGesture.enabled = false
end

return FightMenuManager
