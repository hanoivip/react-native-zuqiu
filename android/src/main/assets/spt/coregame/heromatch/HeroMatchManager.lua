local MatchInfoModel = require("ui.models.MatchInfoModel")
local EnumType = require("coregame.EnumType")
local ManualOperateType = EnumType.ManualOperateType
local AssetFinder = require("ui.common.AssetFinder")
local ShootLineManager = require("coregame.ShootLineManager")
local CommonConstants = require("ui.common.CommonConstants")

local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local Time = UnityEngine.Time
local SpriteState = UnityEngine.UI.SpriteState
local Camera = UnityEngine.Camera

local HeroMatchManager = class(unity.base)

local BUTTON_CONFIG = {
    [ManualOperateType.Pass] = {
        imageRectPos = Vector2(1, 13),
        imageRectSizeDelta = Vector2(75, 65),
        buttonPosition = Vector3(21.19, 2.5, 13),
        spritePath = "Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_icon_ChuanQiu.png",
        handPosition = Vector2(80, -110),
        handRotation = Vector3(0, 0, 30),
        rate = 80,
        effectIcon = "Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectSkillIcoPass.prefab",
    },
    [ManualOperateType.Dribble] = {
        imageRectPos = Vector2(-2, 8),
        imageRectSizeDelta = Vector2(88, 88),
        buttonPosition = Vector3(25.12, 1.8, -9.76),
        spritePath = "Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_icon_DaiQiu.png",
        handPosition = Vector2(90, -90),
        handRotation = Vector3(0, 0, 45),
        rate = 90,
        effectIcon = "Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectSkillIcoDribble.prefab",
    },
    [ManualOperateType.Shoot] = {
        imageRectPos = Vector2(-0.1, -0.1),
        imageRectSizeDelta = Vector2(85, 85),
        buttonPosition = Vector3(0, 0.8, -55),
        spritePath = "Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_icon_SheMen.png",
        handPosition = Vector2(10, -125),
        handRotation = Vector3(0, 0, 0),
        effectIcon = "Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectSkillIcoShoot.prefab",
    },
}

HeroMatchManager.HeroMatchEvent = {
    goal = 0,
    pass = 1,
    long_pass = 2,
    catch = 3,
    shoot = 4,
    commentary = 5,
}

local function SetTimeScale(timeScale)
    Time.timeScale = timeScale
end

local function WorldToRectPosition(worldPosition, rect)
    local viewPortPos = Camera.main.WorldToViewportPoint(worldPosition)
    return Vector2(viewPortPos.x * rect.width, viewPortPos.y * rect.height)
end

function HeroMatchManager:ctor()
    ___heroMatchManager = self
    self.manualOperatePanel = self.___ex.manualOperatePanel
    self.buttonObj = self.___ex.buttonObj
    self.buttonScript = self.___ex.buttonScript
    self.buttonRect = self.___ex.buttonRect
    self.handRect = self.___ex.handRect
    self.blackScreenAnim = self.___ex.blackScreenAnim
    self.worldCanvas = self.___ex.worldCanvas

    self.matchInfoModel = MatchInfoModel.GetInstance()
    self.playerTeamData = self.matchInfoModel:GetPlayerTeamData()
    self.opponentTeamData = self.matchInfoModel:GetOpponentTeamData()

    self.passStartPosition = Vector3(-19.7, 0, 11.07)
    self.passEndPosition = Vector3(28.62, 0, -1.3)
    self.catchStartPosition = Vector3(21.19, 0, 13.25)
    self.passTargetPosition = Vector3(28.62, 0.1, -1.3)
    self.dribblePathPosition = Vector3(25.22, 0.1, -13.74)

    self.effectObj = nil
    self.passTarget = nil
    self.dribblePath = nil
    self.effectHeroTimeGoal = self.___ex.effectHeroTimeGoal
end

function HeroMatchManager:start()
    luaevt.trig("SendBIReport", "heroMatch_start", "7")
    self.blackScreenAnim.gameObject:SetActive(true)
    self.blackScreenAnim:Play("Base Layer.MoveOut", 0)
    self.blackScreenAnim.speed = 0.5
    require("ui.control.manager.MusicManager").stop()
end

function HeroMatchManager:OnManualOperateStart(operateType)
    self.manualOperatePanel.gameObject:SetActive(true)
    if operateType == ManualOperateType.Pass then
        self:InitManualOperate(operateType, 5, 7)
    elseif operateType == ManualOperateType.Dribble then
        self:InitManualOperate(operateType, 7, 7)
    elseif operateType == ManualOperateType.Shoot then
        self:InitManualOperate(operateType, 1, 1)
    end
    SetTimeScale(0.000001)
end

function HeroMatchManager:InitManualOperate(operateType, athleteId, targetAthleteId)
    local athlete = self:GetAthlete(athleteId)

    if operateType == ManualOperateType.Pass then
        self:InitManualOperatePass(operateType, targetAthleteId)
    elseif operateType == ManualOperateType.Dribble then
        self:InitManualOperateDribble(operateType, athlete)
    elseif operateType == ManualOperateType.Shoot then
        self:InitManualOperateShoot(operateType)
    end

    ___heroMatchAudioManager:InitManualOperate()
end

function HeroMatchManager:InitManualOperatePass(operateType, targetAthleteId)
    local targetAthlete = self:GetAthlete(targetAthleteId)
    self:InitButton(operateType, BUTTON_CONFIG[operateType], targetAthlete.name)

    self.linePass = ShootLineManager.CreateLineMesh(self.passStartPosition, nil, nil, self.passEndPosition, "pass", true)
    self.lineCatch = ShootLineManager.CreateLineMesh(self.catchStartPosition, nil, nil,  self.passEndPosition, "run", false)

    self.passTarget = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectHeroTimeDestination.prefab"))
    self.passTarget.transform:SetParent(self.worldCanvas, false)
    self.passTarget.transform.position = self.passTargetPosition
    self.passTarget:SetActive(true)

    self.passTargetScript = res.GetLuaScript(self.passTarget)
    self.passTargetAnimator = self.passTargetScript.___ex.animator
    self.passTargetOver = self.passTargetScript.___ex.effectHeroTimeDestinationOver
    self.passDestCross = self.passTargetScript.___ex.desCross02

    self.passTargetOver:SetActive(false)

    self.buttonScript:regOnButtonClick(function ()
        self:OnButtonClick(operateType)
    end)
end

function HeroMatchManager:InitManualOperateDribble(operateType, athlete)
    self:InitButton(operateType, BUTTON_CONFIG[operateType], athlete.name)

    self.dribblePath = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/EffectHeroTimeBallDestination.prefab"))
    self.dribblePath.transform:SetParent(self.worldCanvas, false)
    self.dribblePath.transform.position = self.dribblePathPosition
    self.dribblePath.transform.rotation = Quaternion.Euler(Vector3(270, 0, 0));
    self.dribblePath:SetActive(true)

    self.dribblePathScript = res.GetLuaScript(self.dribblePath)
    self.dribblePathAnimator = self.dribblePathScript.___ex.animator
    self.dribblePathAnimator.enabled = true
    self.dribblePathAnimator:Play("EffectHeroTimeBallAnimationIdle")

    self.buttonScript:regOnButtonClick(function ()
        self:OnButtonClick(operateType)
    end)
end

function HeroMatchManager:InitManualOperateShoot(operateType)
    self:InitButton(operateType, BUTTON_CONFIG[operateType])

    self.buttonScript.___ex.effectOperateButtonIdle:SetActive(true)
    self.buttonScript.___ex.effectOperateButtonOver:SetActive(false)

    self.buttonScript:regOnButtonClick(function ()
        self:OnButtonClick(operateType)
    end)

    self.effectHeroTimeGoal:SetActive(true)
end

function HeroMatchManager:InitButton(operateType, config, playerName)
    if not self.ManualOperateButtonUpSprite then
        self.ManualOperateButtonUpSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_up.png")
        self.buttonScript.___ex.buttonUpImage.sprite = self.ManualOperateButtonUpSprite
        self.ManualOperateButtonDownSprite = res.LoadRes("Assets/CapstonesRes/Game/UI/Match/Overlay/ManualOperate/HeroTime_Button_Down.png")
        local spriteState = SpriteState()
        spriteState = self.buttonScript.___ex.buttonObject.spriteState
        spriteState.pressedSprite = self.ManualOperateButtonDownSprite
        self.buttonScript.___ex.buttonObject.spriteState = spriteState
    end
    self.buttonScript.___ex.image.overrideSprite = res.LoadRes(config.spritePath)
    self.buttonScript.___ex.imageRectTransform.anchoredPosition = config.imageRectPos
    self.buttonScript.___ex.imageRectTransform.sizeDelta = config.imageRectSizeDelta

    if operateType == ManualOperateType.Pass or operateType == ManualOperateType.Dribble then
        self.buttonScript.___ex.rate.text = tostring(config.rate)
        self.buttonScript.___ex.playerName.text = playerName
        self.buttonScript.___ex.rate.gameObject:SetActive(true)
        self.buttonScript.___ex.percent.gameObject:SetActive(true)
        self.buttonScript.___ex.playerName.gameObject:SetActive(true)
    else
        self.buttonScript.___ex.rate.gameObject:SetActive(false)
        self.buttonScript.___ex.percent.gameObject:SetActive(false)
        self.buttonScript.___ex.playerName.gameObject:SetActive(false)
    end
    self.buttonScript.___ex.skillImage.gameObject:SetActive(false)
    self.buttonScript.___ex.skillName.gameObject:SetActive(false)

    self.buttonObj:SetActive(true)
    self.buttonRect.anchoredPosition = WorldToRectPosition(config.buttonPosition, self.manualOperatePanel.rect)

    self.handRect.anchoredPosition = config.handPosition
    self.handRect.transform.rotation = Quaternion.Euler(config.handRotation)

    self.effectObj = Object.Instantiate(res.LoadRes(config.effectIcon))
    self.effectObj.transform:SetParent(self.buttonObj.transform, false)
end

function HeroMatchManager:OnButtonClick(operateType)
    self:coroutine(function ()
        if operateType == ManualOperateType.Pass then
            luaevt.trig("SendBIReport", "click_pass", "8")
            self.buttonObj:SetActive(false)
            self.passTargetOver:SetActive(true)
            self.passDestCross:SetActive(true)
            self.passTargetAnimator.enabled = true
            self.passTargetAnimator:Play("EffectHeroTimeDestinationIdle")

            local startTime = Time.unscaledTime
            while Time.unscaledTime - startTime < 0.75 do
                coroutine.yield(UnityEngine.WaitForEndOfFrame())
            end
            self.passTargetAnimator.enabled = false

            self.passTarget:SetActive(false)
            self.linePass:SetActive(false)
            self.lineCatch:SetActive(false)
        elseif operateType == ManualOperateType.Dribble then
            luaevt.trig("SendBIReport", "click_dribble", "9")
            self.buttonObj:SetActive(false)
            self.dribblePathAnimator:Play("EffectHeroTimeBallAnimationOver")

            local startTime = Time.unscaledTime
            while Time.unscaledTime - startTime < 0.5 do
                coroutine.yield(UnityEngine.WaitForEndOfFrame())
            end
            self.dribblePathAnimator.enabled = false

            self.dribblePath:SetActive(false)
        elseif operateType == ManualOperateType.Shoot then
            luaevt.trig("SendBIReport", "click_shoot", "10")
            self.buttonScript.___ex.effectOperateButtonIdle:SetActive(false)
            self.buttonScript.___ex.effectOperateButtonOver:SetActive(true)

            local startTime = Time.unscaledTime
            while Time.unscaledTime - startTime < 0.5 do
                coroutine.yield(UnityEngine.WaitForEndOfFrame())
            end
            self.effectHeroTimeGoal:SetActive(false)
            self.buttonScript.___ex.effectOperateButtonOver:SetActive(false)
            self.buttonObj:SetActive(false)
        end
        self:StopManualOperate(operateType)
    end)
end

function HeroMatchManager:StopManualOperate(operateType)
    self.manualOperatePanel.gameObject:SetActive(false)
    ___heroMatchAudioManager:OnManualOperateClick(operateType)
    SetTimeScale(1)
    ___heroMatchAudioManager:StopUISound()
    Object.Destroy(self.effectObj)
    self.effectObj = nil
end

function HeroMatchManager:IsPlayer(athleteId)
    if self.opponentTeamData then
        return athleteId < self.opponentTeamData.startId
    end
    return athleteId <= 11
end

function HeroMatchManager:GetAthlete(athleteId)
    local athlete = self:IsPlayer(athleteId) and
        self.playerTeamData.athletes[athleteId] or
        self.opponentTeamData.athletes[athleteId - self.opponentTeamData.startId + 1]
    return athlete
end

function HeroMatchManager:OnHeroMatchEvent(eventType)
    ___heroMatchAudioManager:OnHeroMatchEvent(eventType)
end

function HeroMatchManager:OnHeroMatchEnds()
    Object.Destroy(self.linePass)
    Object.Destroy(self.lineCatch)
    ___heroMatchAudioManager:OnHeroMatchEnds()
    self.blackScreenAnim.gameObject:SetActive(true)
    self.blackScreenAnim:Play("Base Layer.MoveIn", 0)
    self.blackScreenAnim.speed = 1

    local stadiumManager = res.GetLuaScript(GameObject.Find("/StadiumManager"))
    stadiumManager:enableGoalNet()
end

function HeroMatchManager:EndHeroMatch()
    res.ChangeScene("ui.controllers.login.LoginCtrl")
    require("ui.control.manager.MusicManager").play()
end

function HeroMatchManager:OnAnimEnd(animMoveType)
    if animMoveType == CommonConstants.UIAnimMoveType.MOVE_IN then
    elseif animMoveType == CommonConstants.UIAnimMoveType.MOVE_OUT then
        self.blackScreenAnim.gameObject:SetActive(false)
    end
end

return HeroMatchManager
