local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds
local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local Tweener = Tweening.Tweener
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local Mathf = UnityEngine.Mathf
local Space = UnityEngine.Space
local SpriteState = UnityEngine.UI.SpriteState

local EventSystem = require("EventSystem")
local MatchInfoModel = require("ui.models.MatchInfoModel")
local MatchConstants = require("ui.scene.match.MatchConstants")
local AudienceAudioConstants = require("ui.scene.match.AudienceAudioConstants")
local UISoundManager = require("ui.control.manager.UISoundManager")
local UIBgmManager = require("ui.control.manager.UIBgmManager")
local AssetFinder = require("ui.common.AssetFinder")
local ShootLineManager = require("coregame.ShootLineManager")
local EnumType = require("coregame.EnumType")
local ManualOperateType = EnumType.ManualOperateType
local PrefabCache = require("ui.scene.match.overlay.PrefabCache")
local SkillData = require('data.Skills')
local AudioManager = require("unity.audio")

local ManualOperatePanel = class(unity.base)

local adjustPlayerColor = ManualOperationUtilsWrap.AdjustPlayerColor
local resetPlayerMaterialColor = ManualOperationUtilsWrap.ResetPlayerMaterialColor
local tableInsert = table.insert
local heroMomentSoundDir = "Assets/CapstonesRes/Game/Audio/UI/Match/"

function ManualOperatePanel:ctor()
    self.manualOperateClickAudioPlayer = AudioManager.GetPlayer("manualOperateClick")
    self.manualOperateOverEffectAudioPlayer = AudioManager.GetPlayer("manualOperateOverEffect")
    self.commonObject = self.___ex.commonObject
    self.enterObject = self.___ex.enterObject
    self.maskObject = self.___ex.maskObject
    -- 动画
    self.panelAnimator = self.___ex.panelAnimator
    -- 剩余时间
    self.countdownObject = self.___ex.countdownObject
    self.countdownTime = self.___ex.countdownTime
    -- 倒计时动画文本
    self.countdownEffectTime1 = self.___ex.countdownEffectTime1
    self.countdownEffectTime2 = self.___ex.countdownEffectTime2
    -- 倒计时动画播放器
    self.countdownAnimator = self.___ex.countdownAnimator
   -- 倒计时持续时间
    self.countdownDuration = nil
    -- 倒计时起始时间
    self.countdownStartTime = nil
    -- 倒计时终止时间
    self.countdownEndTime = nil
    -- 当前的时间缩放
    self.nowTimeScale = nil
    self.matchInfoModel = MatchInfoModel.GetInstance()
    -- 慢动作的timeScale
    self.slowdownTimeScale = 0.0125
    -- 停止的timeScale
    self.stopTimeScale = 0.000001
    self.stopTimeScaleUpperLimit = 0.00001
    -- 是否开始倒计时
    self.isStartCountdown = false
    -- 是否显示倒计时
    self.isShowCountdown = true
    -- 当前剩余秒数
    self.nowLastSecond = nil
    -- 是否显示进入画面
    self.isShowSplash = false
    -- 是否是示例赛
    self.isDemoMatch = self.matchInfoModel:IsDemoMatch()

    self.GameHubInstance = clr.GameHub.GetInstance()

    self.playerIdInfos = {}

    -- 预先创建3个button备用
    self.manualOperateButtonPool = {}
    for i = 1, 3 do
        tableInsert(self.manualOperateButtonPool, PrefabCache.ManualOperateButtonPool:getObject())
    end
end

function ManualOperatePanel:Init(countdownDuration, playerIconImage, isShowSplash)
    local playerIconRes = AssetFinder.GetPlayerIcon(playerIconImage)
    self.countdownDuration = countdownDuration
    self.isShowCountdown = not self.isDemoMatch
    self.isShowSplash = isShowSplash
    self.nowTimeScale = Time.timeScale

    if self.isShowSplash then
        TimeWrap.SetTimeScale(self.stopTimeScale)
        self.panelAnimator.enabled = true
        UISoundManager.play('Match/heroMatch_fireballMoveIn', 1)
        UIBgmManager.play('Match/heroMatch_titleMoveIn', 1)
        self.enterObject:SetActive(true)
        self.maskObject:SetActive(true)
        self.commonObject:SetActive(false)
        self.panelAnimator:Play("HeroTimeCN")
    else
        self:StartCountdown()
    end
end

function ManualOperatePanel:update()
    self:PlayCountdown()
end

--- 播放倒计时
function ManualOperatePanel:PlayCountdown()
    --stop animation after half of the countdown
    if self.isStartCountdown and self.isShowCountdown then
        local nowTime = TimeWrap.GetUnscaledTime()
        if nowTime <= self.countdownEndTime then
            local timeElapsed = nowTime - self.countdownStartTime
            self:SetCountdownTime(timeElapsed)
        else
            self.isStartCountdown = false
            GameHubWrap.AutoManualOperate()
            UISoundManager.stop()
            self.gameObject:SetActive(false)
        end
    end
end

--- 设置倒计时时间
function ManualOperatePanel:SetCountdownTime(timeElapsed)
    local lastSecond = self.countdownDuration - math.floor(timeElapsed)
    if self.nowLastSecond ~= lastSecond then
        self.nowLastSecond = lastSecond
        self.countdownTime.text = tostring(lastSecond)
        self.countdownEffectTime1.text = tostring(lastSecond)
        self.countdownEffectTime2.text = tostring(lastSecond)
        self.countdownAnimator:Play("Base Layer.MoveIn", 0, 0)
    end
end

--- 开始倒计时
function ManualOperatePanel:StartCountdown()
    UISoundManager.play("Match/heroMatch_bgm", 1, true)
    self.countdownStartTime = TimeWrap.GetUnscaledTime()
    self.countdownEndTime = self.countdownStartTime + self.countdownDuration

    self.isStartCountdown = true
    self.countdownObject:SetActive(self.isShowCountdown)
    self.commonObject:SetActive(true)
    if not self.isShowCountdown then
        TimeWrap.SetTimeScale(self.stopTimeScale)
    else
        TimeWrap.SetTimeScale(self.slowdownTimeScale)
    end

    if not self.isDemoMatch then
        self:ShowManualOperateButtonObjects()
    end
end

--- 结束倒计时
function ManualOperatePanel:EndCountdown()
    self.isStartCountdown = false
    self.countdownObject:SetActive(false)

    self.panelAnimator.enabled = false
    self.gameObject:SetActive(false)

    self.commonObject:SetActive(false)

    UISoundManager.stop()
end

function ManualOperatePanel:OnSplashEnd()
    self.enterObject:SetActive(false)
    self.maskObject:SetActive(false)
    self:StartCountdown()
    if self.isDemoMatch then
        ___demoManager:OnManualOperateSplashEnd()
    end
end

function ManualOperatePanel:ShowManualOperateButtonObjects()
    for _, entry in ipairs(self.manualOperateButtonObjectList) do
        entry.obj:SetActive(true)
    end
    if self.isDemoMatch then
        for _, entry in ipairs(self.passLineList) do
            entry.obj:SetActive(true)
        end
        for _, entry in ipairs(self.catchLineList) do
            entry.obj:SetActive(true)
        end
        for _, entry in ipairs(self.passTargetList) do
            entry.obj:SetActive(true)
        end
        for _, entry in ipairs(self.dribbleArrowList) do
            entry.obj:SetActive(true)
        end
        if self.goalSquareObj then
            self.goalSquareObj:SetActive(true)
        end
    end
end

function ManualOperatePanel:SetNewPlayerIdInfos()
    self.playerIdInfos = {}

    local totalPlayerNumber = self.GameHubInstance:GetPlayerTransforms().Length
    for i = 1, totalPlayerNumber do
        tableInsert(self.playerIdInfos, {playerId = i - 1, isEmphasized = false})
    end
end

function ManualOperatePanel:ShowManualOperateView(manualOperateAction, manualOperateAthletePosition, athlete, manualOperateAthleteOnfieldId)
    self.currentButtonId = 1
    self.selectedButtonId = 0
    self.selectedManualOperateType = ManualOperateType.Invalid
    self.manualOperateButtonObjectList = {}
    self.outOfScreenLabelObjectList = {}
    self.passLineList = {}
    self.catchLineList = {}
    self.passTargetList = {}
    self.dribbleArrowList = {}
    self:SetNewPlayerIdInfos()

    self:InitManualOperatePassUI(manualOperateAction, manualOperateAthletePosition)
    self:InitManualOperateDribbleUI(manualOperateAction, manualOperateAthletePosition)
    self:InitManualOperateShootUI(manualOperateAction, manualOperateAthletePosition)

    self.gameObject:SetActive(true)
    if manualOperateAction.manualOperateTimes == 1 then
        self:Init(10, athlete.cid, true)
    else
        self:Init(10, athlete.cid, false)
    end

    self.playerIdInfos[manualOperateAthleteOnfieldId].isEmphasized = true

    self:ShowEmphasizationEffect()

    --- 播放英雄时刻解说
    EventSystem.SendEvent("CommentaryManager.PlayHeroicMomentAudio", manualOperateAction.isShootEnabled)
end

function ManualOperatePanel:ShowEmphasizationEffect()
    ___matchUI.stadiumManager.pitchMaterial:SetFloat("_ColorCoe", 0.4)
    ___matchUI.stadiumManager.pitchLineMaterial:SetFloat("_ColorCoe", 0.7)

    for _, playerIdInfo in ipairs(self.playerIdInfos) do
        if playerIdInfo.isEmphasized then
            adjustPlayerColor(playerIdInfo.playerId, 1.5)
        else
            adjustPlayerColor(playerIdInfo.playerId, 0.5)
        end
    end
end

function ManualOperatePanel:EndEmphasizationEffect()
    ___matchUI.stadiumManager.pitchMaterial:SetFloat("_ColorCoe", 1)
    ___matchUI.stadiumManager.pitchLineMaterial:SetFloat("_ColorCoe", 1)

    resetPlayerMaterialColor()
end

local MANUAL_OPERATE_BUTTON_CONFIG = {
    [ManualOperateType.Pass] = {
        deltaPixel = Vector2(0, 20),
        imageRectPos = Vector2(1, 13),
        imageRectSizeDelta = Vector2(75, 65)
    },
    [ManualOperateType.Dribble] = {
        deltaPixel = Vector2(0, 20),
        imageRectPos = Vector2(-2, 8),
        imageRectSizeDelta = Vector2(88, 88)
    },
    [ManualOperateType.Shoot] = {
        deltaPixel = Vector2(0, 0),
        imageRectPos = Vector2(-0.1, -0.1),
        imageRectSizeDelta = Vector2(85, 85)
    },
}

function ManualOperatePanel:InitManualOperateButtonConfig()
    MANUAL_OPERATE_BUTTON_CONFIG[ManualOperateType.Pass].nonSkillImageSprite = PrefabCache.ManualOperatePassSprite
    MANUAL_OPERATE_BUTTON_CONFIG[ManualOperateType.Pass].effectIcon = PrefabCache.EffectSkillIcoPass
    MANUAL_OPERATE_BUTTON_CONFIG[ManualOperateType.Dribble].nonSkillImageSprite = PrefabCache.ManualOperateDribbleSprite
    MANUAL_OPERATE_BUTTON_CONFIG[ManualOperateType.Dribble].effectIcon = PrefabCache.EffectSkillIcoDribble
    MANUAL_OPERATE_BUTTON_CONFIG[ManualOperateType.Shoot].nonSkillImageSprite = PrefabCache.ManualOperateGoalSprite
    MANUAL_OPERATE_BUTTON_CONFIG[ManualOperateType.Shoot].effectIcon = PrefabCache.EffectSkillIcoShoot
end

local COLLISION_RADIUS = 80

function ManualOperatePanel:InitManualOperateButton(
    buttonId,
    manualOperateType,
    id,
    followedObj,
    rate,
    playerName,
    deltaPos,
    skillId,
    needCollisionAvoidance
    )
    local config = MANUAL_OPERATE_BUTTON_CONFIG[manualOperateType]

    -- create button
    local manualOperateButtonObj = nil
    if #self.manualOperateButtonPool ~= 0 then
        manualOperateButtonObj = table.remove(self.manualOperateButtonPool)
    else
        manualOperateButtonObj = PrefabCache.ManualOperateButtonPool:getObject()
    end

    if self.isDemoMatch then
        ___demoManager:RegManualOperateButton(manualOperateButtonObj, manualOperateType)
    end

    manualOperateButtonObj:SetActive(false)
    local buttonScript = res.GetLuaScript(manualOperateButtonObj)
    buttonScript:regOnButtonClick(function ()
        if self.selectedButtonId == 0 and (not self.isDemoMatch or ___demoManager:IsOperationAllowed(manualOperateType)) then
            self.selectedButtonId = buttonId
            self.selectedManualOperateType = manualOperateType
            self.manualOperateClickAudioPlayer.PlayAudio(heroMomentSoundDir .. "heroTimeSelectionSound.wav", 2)
            GameHubWrap.OnManualOperateFingerUp(manualOperateType, id)
        end
    end)
    manualOperateButtonObj.transform:SetParent(self.fightMenuManager.manualOperateContainerObject.transform, false)

    local outOfScreenLabelObj = PrefabCache.ManualOperateLabelPool:getObject()
    outOfScreenLabelObj:SetActive(false)
    outOfScreenLabelObj.transform:SetParent(self.transform, false)

    self.fightMenuManager.athleteLabelsComponent:AddLabel(
        manualOperateButtonObj, followedObj, deltaPos, config.deltaPixel, false, needCollisionAvoidance, COLLISION_RADIUS, outOfScreenLabelObj)
    local isShoot = nil
    if manualOperateType == ManualOperateType.Shoot then
        isShoot = true
    end
    tableInsert(self.manualOperateButtonObjectList, {buttonId = buttonId, obj = manualOperateButtonObj, isShoot = isShoot})
    tableInsert(self.outOfScreenLabelObjectList, {buttonId = buttonId, obj = outOfScreenLabelObj})

    -- set normal and pressed image
    if buttonScript.lastEffectObj then
        Object.Destroy(buttonScript.lastEffectObj)
    end

    buttonScript.___ex.buttonUpImage.sprite = PrefabCache.ManualOperateButtonUpSprite
    local effectObj = Object.Instantiate(config.effectIcon)
    effectObj.transform:SetParent(manualOperateButtonObj.transform, false)
    buttonScript.lastEffectObj = effectObj

    local spriteState = SpriteState()
    spriteState = buttonScript.___ex.buttonObject.spriteState
    spriteState.pressedSprite = PrefabCache.ManualOperateButtonDownSprite
    buttonScript.___ex.buttonObject.spriteState = spriteState

    buttonScript.___ex.imageRectTransform.anchoredPosition = config.imageRectPos
    buttonScript.___ex.imageRectTransform.sizeDelta = config.imageRectSizeDelta

    -- set text
    if manualOperateType == ManualOperateType.Pass or manualOperateType == ManualOperateType.Dribble then
        buttonScript.___ex.rate.text = tostring(rate)
        buttonScript.___ex.playerName.text = playerName
        buttonScript.___ex.rate.gameObject:SetActive(true)
        buttonScript.___ex.percent.gameObject:SetActive(true)
        buttonScript.___ex.playerName.gameObject:SetActive(true)
    else
        buttonScript.___ex.rate.gameObject:SetActive(false)
        buttonScript.___ex.percent.gameObject:SetActive(false)
        buttonScript.___ex.playerName.gameObject:SetActive(false)
    end

    -- set skill info
    if skillId then
        local skillName = SkillData[skillId] and SkillData[skillId].skillName
        local icon = AssetFinder.GetMatchSkillIcon(skillId)
        if icon and icon ~= clr.null then
            buttonScript.___ex.skillImage.overrideSprite = icon
        end
        if skillName then
            buttonScript.___ex.skillName.text = skillName
        end
        buttonScript.___ex.image.gameObject:SetActive(false)
        buttonScript.___ex.skillName.gameObject:SetActive(true)
        buttonScript.___ex.skillImage.gameObject:SetActive(true)
    else
        buttonScript.___ex.image.overrideSprite = config.nonSkillImageSprite
        buttonScript.___ex.image.gameObject:SetActive(true)
        buttonScript.___ex.skillImage.gameObject:SetActive(false)
        buttonScript.___ex.skillName.gameObject:SetActive(false)
    end
end

function ManualOperatePanel:GetArrowAngle(playerPosition, targetPosition)
    local direction = targetPosition - Vector2Lua(playerPosition.x, playerPosition.z)
    direction = direction.normalized
    local angle = Vector2Lua.Angle(Vector2Lua(1, 0), direction)
    local cross = Vector3Lua.Cross(Vector3Lua(1, 0, 0), Vector3Lua(direction.x, direction.y, 0))
    angle = cross.z > 0 and -angle or angle
    --angle: 0 right, 90 down, 180 left, 270 up
    return angle
end

function ManualOperatePanel:TransferArrow(arrowObject, playerPosition, dribbleTargetPosition)
    local angle = self:GetArrowAngle(playerPosition, dribbleTargetPosition)

    local arrowTransform = arrowObject.transform
    arrowTransform.position = Vector3(playerPosition.x, playerPosition.y + 0.1, playerPosition.z)
    arrowTransform.rotation = Quaternion.Euler(Vector3(270, 0, 0));
    arrowTransform:Rotate(Vector3(0, angle - 90, 0), Space.World)

    arrowObject:SetActive(true)
    arrowTransform:Translate(Vector3(0, 2, 0))
end

local manualPassDeltaPixel = Vector2(0, 20)

local function GetAdjustedEndPos(startPos, endPos)
    local startPosLua = Vector3Lua(startPos.x, startPos.y, startPos.z)
    local endPosLua = Vector3Lua(endPos.x, endPos.y, endPos.z)
    local adjustedEndPosLua = endPosLua + (startPosLua - endPosLua).normalized * 0.5
    return Vector3(adjustedEndPosLua.x, adjustedEndPosLua.y, adjustedEndPosLua.z)
end

function ManualOperatePanel:InitManualOperatePassUI(manualOperateAction, manualOperateAthletePosition)
    for _, manualPass in ipairs(manualOperateAction.passList) do
        local onfieldId = manualPass.onfieldId

        local playerTransform = self.GameHubInstance:GetPlayerTransform(onfieldId - 1)
        local rate = math.clamp(math.round(manualPass.successProbability * 100), 1, 99)

        local athleteId = GameHubWrap.GetAthleteId(onfieldId - 1)
        local athleteFriend = ___matchUI:getAthlete(athleteId)
        self.playerIdInfos[onfieldId].isEmphasized = true

        self:InitManualOperateButton(
            self.currentButtonId,
            ManualOperateType.Pass,
            onfieldId,
            playerTransform.gameObject,
            rate,
            athleteFriend.name,
            Vector3(0, athleteFriend.height / 100, 0),
            manualPass.skillId,
            true
            )

        local passTargetGameObject = Object.Instantiate(PrefabCache.ManualOperatePassObj)
        tableInsert(self.passTargetList, {buttonId = self.currentButtonId, obj = passTargetGameObject})
        local passTargetPosition = Vector3(manualPass.targetPosition.x, 0.1, manualPass.targetPosition.y)
        passTargetGameObject.transform:SetParent(self.fightMenuManager.manualOperateWorldCanvasObject.transform, false)
        passTargetGameObject.transform.position = passTargetPosition
        if self.isDemoMatch then
            passTargetGameObject:SetActive(false)
        else
            passTargetGameObject:SetActive(true)
        end

        local isHighPass = false
        if manualPass.type == 'High' then
            isHighPass = 'true'
        end
        local lineType = "pass"
        if manualPass.skillId then
            lineType = "skillPass"
        end
        local passArrowPosition = GetAdjustedEndPos(manualOperateAthletePosition, passTargetPosition)
        local catchArrowPosition = GetAdjustedEndPos(playerTransform.position, passTargetPosition)
        local linePass = ShootLineManager.CreateLineMesh(manualOperateAthletePosition, nil, nil, passArrowPosition, lineType, isHighPass)
        local lineCatch = ShootLineManager.CreateLineMesh(playerTransform.position, nil, nil, catchArrowPosition, "run", false)

        linePass:SetActive(false)
        if self.isDemoMatch then
            lineCatch:SetActive(false)
        else
            lineCatch:SetActive(true)
        end

        tableInsert(self.passLineList, {buttonId = self.currentButtonId, obj = linePass})
        tableInsert(self.catchLineList, {buttonId = self.currentButtonId, obj = lineCatch})

        self.currentButtonId = self.currentButtonId + 1
    end
end

local manualDribbleDeltaPixel = Vector2(0, 20)

function ManualOperatePanel:InitManualOperateDribbleUI(manualOperateAction, manualOperateAthletePosition)
    for i, manualDribble in ipairs(manualOperateAction.dribbleList) do
        local arrowGameObj = Object.Instantiate(PrefabCache.ManualOperateDribbleObj)
        tableInsert(self.dribbleArrowList, {buttonId = self.currentButtonId, obj = arrowGameObj})
        arrowGameObj:SetActive(true)
        arrowGameObj.transform:SetParent(self.fightMenuManager.manualOperateWorldCanvasObject.transform, false)
        self:TransferArrow(arrowGameObj, manualOperateAthletePosition, manualDribble.targetPosition)
        if self.isDemoMatch then
            arrowGameObj:SetActive(false)
        end
        local rate = math.clamp(math.round(manualDribble.successProbability * 100), 1, 99)

        local angle = self:GetArrowAngle(manualOperateAthletePosition, manualDribble.targetPosition)
        local deltaPos = Vector3(
            0.7 * math.cos(-angle * Mathf.Deg2Rad),
            0,
            0.7 * math.sin(-angle * Mathf.Deg2Rad)
            )
        self:InitManualOperateButton(
            self.currentButtonId,
            ManualOperateType.Dribble,
            manualDribble.index,
            arrowGameObj,
            rate,
            '',
            deltaPos,
            manualDribble.skillId,
            false
            )
        self.currentButtonId = self.currentButtonId + 1
    end
end

local manualShootDeltaPos = Vector3(0, 0.8, 0)

function ManualOperatePanel:InitManualOperateShootUI(manualOperateAction, manualOperateAthletePosition)
    self.goalSquareObj = nil
    if manualOperateAction.isShootEnabled then
        local goalTransform = self.GameHubInstance:GetGoalNear(Vector2(manualOperateAthletePosition.x, manualOperateAthletePosition.z))
        local script = res.GetLuaScript(goalTransform)
        self.goalSquareObj = script.___ex.effectHeroTimeGoal
        if self.isDemoMatch then
            self.goalSquareObj:SetActive(false)
        else
            self.goalSquareObj:SetActive(true)
        end
        self:InitManualOperateButton(
            self.currentButtonId,
            ManualOperateType.Shoot,
            0,
            goalTransform.gameObject,
            0,
            '',
            manualShootDeltaPos,
            manualOperateAction.shootEnabledSkillId,
            false
            )
        self.currentButtonId = self.currentButtonId + 1
    end
end

function ManualOperatePanel:DisableUnselectedButtons()
    self:EndEmphasizationEffect()

    for _, entry in ipairs(self.manualOperateButtonObjectList) do
        if entry.buttonId == self.selectedButtonId and entry.isShoot then
            self:ProcessShootEffect(entry.obj, true)
        else
            entry.obj:SetActive(false)
        end
    end

    for _, entry in ipairs(self.outOfScreenLabelObjectList) do
        entry.obj:SetActive(false)
    end

    local manualOperateAthletePosition = GameHubWrap.GetPlayerPosition(self.GameHubInstance.manualOperateAthleteOnfieldId)
    local goalObject = self.GameHubInstance:GetGoalNear(Vector2(manualOperateAthletePosition.x, manualOperateAthletePosition.z))
    local script = res.GetLuaScript(goalObject)
    local goalSquareObj = script.___ex.effectHeroTimeGoal
    goalSquareObj:SetActive(false)

    for _, entry in ipairs(self.dribbleArrowList) do
        if entry.buttonId ~= self.selectedButtonId then
            entry.obj:SetActive(false)
        end
    end

    for _, entry in ipairs(self.passTargetList) do
        if entry.buttonId ~= self.selectedButtonId then
            entry.obj:SetActive(false)
        else
            self:ProcessPassTargetIdleEffect(entry.obj, true, "EffectHeroTimeDestinationIdle")
        end
    end

    for _, entry in ipairs(self.passLineList) do
        if entry.buttonId ~= self.selectedButtonId then
            entry.obj:SetActive(false)
        end
    end

    for _, entry in ipairs(self.catchLineList) do
        if entry.buttonId ~= self.selectedButtonId then
            entry.obj:SetActive(false)
        end
    end

    GameHubWrap.SetFingerTestActive(false)
    self:EndCountdown()
end

function ManualOperatePanel:ProcessShootEffect(manualOperateButtonObj, isShowing, isOver)
    local manualOperateButtonScript = res.GetLuaScript(manualOperateButtonObj)
    local effectIdleObject = manualOperateButtonScript.___ex.effectOperateButtonIdle
    local effectOverObject = manualOperateButtonScript.___ex.effectOperateButtonOver
    if isShowing then
        if isOver then
            effectIdleObject:SetActive(false)
            effectOverObject:SetActive(true)
        else
            effectIdleObject:SetActive(true)
            effectOverObject:SetActive(false)
        end
    else
        effectIdleObject:SetActive(false)
        effectOverObject:SetActive(false)
    end
end

function ManualOperatePanel:GetShootEffectDuration(manualOperateButtonObj)
    local manualOperateButtonScript = res.GetLuaScript(manualOperateButtonObj)
    local effectOverParticleObject = manualOperateButtonScript.___ex.effectOverParticleObject
    return effectOverParticleObject.duration
end

function ManualOperatePanel:ProcessDribbleArrowIdleEffect(dribbleArrowObject, isShowing, animationName)
    local dribbleArrowScript = res.GetLuaScript(dribbleArrowObject)
    local dribbleArrowAnimator = dribbleArrowScript.___ex.animator
    dribbleArrowAnimator.enabled = isShowing
    if isShowing then
        dribbleArrowAnimator:Play(animationName)
    end
end

function ManualOperatePanel:ProcessPassTargetIdleEffect(passTargetObject, isShowing, animationName)
    local passTargetScript = res.GetLuaScript(passTargetObject)
    local passTargetAnimator = passTargetScript.___ex.animator
    passTargetAnimator.enabled = isShowing
    local effectOverObject = passTargetScript.___ex.effectHeroTimeDestinationOver
    if isShowing then
        if animationName == "EffectHeroTimeDestinationOver" then
            passTargetScript.___ex.desCross02:SetActive(true)
            effectOverObject:SetActive(true)
        end
        passTargetAnimator:Play(animationName)
    else
        effectOverObject:SetActive(false)
    end
end

function ManualOperatePanel:GetPassTargetOverEffectDuration(passTargetObject)
    local passTargetScript = res.GetLuaScript(passTargetObject)
    local effectOverParticleObject = passTargetScript.___ex.effectOverParticleObject
    return effectOverParticleObject.duration
end

function ManualOperatePanel:ShowOverEffect()
    if self.selectedManualOperateType == ManualOperateType.Pass then
        for _, entry in ipairs(self.passTargetList) do
            if entry.buttonId == self.selectedButtonId then
                self:ProcessPassTargetIdleEffect(entry.obj, true, "EffectHeroTimeDestinationOver")
                self.manualOperateOverEffectAudioPlayer.PlayAudio(heroMomentSoundDir .. "afterPassSelectionSound.mp3", 4)
                return self:GetPassTargetOverEffectDuration(entry.obj)
            end
        end
    elseif self.selectedManualOperateType == ManualOperateType.Dribble then
        for _, entry in ipairs(self.dribbleArrowList) do
            if entry.buttonId == self.selectedButtonId then
                self:ProcessDribbleArrowIdleEffect(entry.obj, true, "EffectHeroTimeBallAnimationOver")
                self.manualOperateOverEffectAudioPlayer.PlayAudio(heroMomentSoundDir .. "afterDribbleSelectionSound.mp3", 4)
                return 0.5
            end
        end
    elseif self.selectedManualOperateType == ManualOperateType.Shoot then
        for _, entry in ipairs(self.manualOperateButtonObjectList) do
            if entry.buttonId == self.selectedButtonId and entry.isShoot then
                self:ProcessShootEffect(entry.obj, true, true)
                self.manualOperateOverEffectAudioPlayer.PlayAudio(heroMomentSoundDir .. "afterShootSelectionSound.mp3", 4)
                return self:GetShootEffectDuration(entry.obj)
            end
        end
    end
end

function ManualOperatePanel:ClearManualOperateView()
    for _, entry in ipairs(self.manualOperateButtonObjectList) do
        if entry.buttonId == self.selectedButtonId and entry.isShoot then
            self:ProcessShootEffect(entry.obj, false)
        end
        entry.obj.transform:SetParent(clr.null, false)
        self.fightMenuManager.athleteLabelsComponent:RemoveLabel(entry.obj)
        entry.obj:SetActive(false)
        PrefabCache.ManualOperateButtonPool:returnObject(entry.obj)
    end
    self.manualOperateButtonObjectList = {}

    for _, entry in ipairs(self.outOfScreenLabelObjectList) do
        entry.obj.transform:SetParent(clr.null, false)
        entry.obj:SetActive(false)
        PrefabCache.ManualOperateLabelPool:returnObject(entry.obj)
    end
    self.outOfScreenLabelObjectList = {}

    for _, obj in ipairs(self.manualOperateButtonPool) do
        PrefabCache.ManualOperateButtonPool:returnObject(obj)
    end
    self.manualOperateButtonPool = {}

    for _, entry in ipairs(self.dribbleArrowList) do
        if entry.buttonId == self.selectedButtonId then
            self:ProcessDribbleArrowIdleEffect(entry.obj, false)
        end
        Object.Destroy(entry.obj)
    end
    self.dribbleArrowList = {}

    for _, entry in ipairs(self.passTargetList) do
        if entry.buttonId == self.selectedButtonId then
            self:ProcessPassTargetIdleEffect(entry.obj, false)
        end
        Object.Destroy(entry.obj)
    end
    self.passTargetList = {}

    for _, entry in ipairs(self.passLineList) do
        Object.Destroy(entry.obj)
    end
    self.passLineList = {}

    for _, entry in ipairs(self.catchLineList) do
        Object.Destroy(entry.obj)
    end
    self.catchLineList = {}

    self.gameObject:SetActive(false)
end

function ManualOperatePanel:onDestroy()
    if self.manualOperateClickAudioPlayer ~= clr.null then
        Object.Destroy(self.manualOperateClickAudioPlayer.gameObject)
    end
    if self.manualOperateOverEffectAudioPlayer ~= clr.null then
        Object.Destroy(self.manualOperateOverEffectAudioPlayer.gameObject)
    end
end

return ManualOperatePanel
