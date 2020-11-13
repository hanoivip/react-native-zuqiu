local UnityEngine = clr.UnityEngine
local Camera = UnityEngine.Camera
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local Color = UnityEngine.Color
local Animator = UnityEngine.Animator
local MeshRenderer = UnityEngine.MeshRenderer
local Random = UnityEngine.Random

local Tweening = clr.DG.Tweening
local Tweener = Tweening.Tweener
local DOTween = Tweening.DOTween
local Sequence = Tweening.Sequence
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local TweenExtensions = Tweening.TweenExtensions
local Ease = Tweening.Ease
local PathType = Tweening.PathType
local PathMode = Tweening.PathMode
local RotateMode = Tweening.RotateMode

local Card = require("data.Card")
local CardModel = require("data.CardModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerReplacer = require("coregame.PlayerReplacer")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")
local BaseTexGenerator = require("cloth.BaseTexGenerator")
local NameNumGenerator = require("cloth.NameNumGenerator")
local ClothUtils = require("cloth.ClothUtils")
local TeamUniformModel  = require("ui.models.common.TeamUniformModel")
local Shooter = require("ui.scene.gacha.Shooter")
local AudioManager = require("unity.audio")

local GachaAnimationView = class(unity.newscene)

local lightMapPath = "Assets/CapstonesRes/Game/MatchScenes/Lightmaps/Night/LightmapFar-0.exr"

-- 球门的大小
local Goal = {
    Width = 7.28,
    Height = 2.35,
}

-- 第一次射门时射门动作停止的时间
local FirstShootPauseTime = 5.6

-- 第一次射门时摄像机的FOV
local CameraFirstFOV = 32

-- 第一次之后摄像机的FOV
local CameraFOV = 50

-- 球的基础飞行速度倍数
local BallFlySpeed = 2.25 / 1.3
-- 球飞行时转动的速度
local BallRotateSpeed = 0.5

-- 主球员跑向球的动作触发时间点
local PlayerMoveToBallActionTime = {
    Appear = 1.5,
    Shoot = 5.5,
}

-- 引导射门的手型图标移动的范围
local FingerGuideTimeDuration = 1
local FingerDownAndUpStopTime = 0.2

-- 球飞行开始减速的时间百分比
local BallFlySpeedDownStartTimePercent = 1

-- 球慢速飞行的总时间
local BallFlySpeedDownTimeTotal = 0.5

-- 最终展示结果的时候摄像机和球的距离
local ResultShowCameraToBallDistance = 5

-- 最终展示结果的时候摄像机的角度
local ResultShowCameraRotationY = 150 -- 70 60 

-- 最终展示结果的时候摄像机低于球的高度
local ResultShowCameraLowerThanBall = 0.3

-- 球和门的距离
local ShootBallStartPosToGoalDis = 11

-- 球摆放的间隔角度
local ShootBallStartPosAngle = 11.25

-- 第一次之后的射门球的起始点
local ShootBallStartPos = {}
for i = 2, 10 do
    local angle
    if i < 7 then
        angle = (1 - i) * ShootBallStartPosAngle * math.pi / 180
    else
        angle = (i - 6) * ShootBallStartPosAngle * math.pi / 180
    end
    local x = -math.sin(angle) * ShootBallStartPosToGoalDis 
    local z = -55 + math.cos(angle) * ShootBallStartPosToGoalDis 
    ShootBallStartPos[i] = Vector3(x, 0.1, z)
end

-- 第一次之后的射门相机和球的起始距离
local CameraStartPosToBallDis = 5.89

-- 第一次之后的射门球员开始做射门动作时和球的距离
local PlayerStartShootPosToBallDis = 2.5

-- 第一次之后的射门相机的起始高度
local ShootCameraStartHeight = 1.8

-- 第一次之后的射门相机的起始点
local ShootCameraStartPos = {}
-- 第一次之后的射门球员的起始点
local ShootPlayerStartPos = {}
for i = 2, 10 do
    local ballPos = ShootBallStartPos[i]
    local ballPosX = ballPos.x
    local ballPosZ = ballPos.z
    local ballToGoalDis = math.sqrt(math.pow(ballPosX, 2) + math.pow(ballPosZ + 55, 2))
    local cameraParam = (ballToGoalDis + CameraStartPosToBallDis) / ballToGoalDis
    local cameraPosX = cameraParam * ballPosX
    local cameraPosZ = cameraParam * (ballPosZ + 55) - 55
    ShootCameraStartPos[i] = Vector3(cameraPosX, ShootCameraStartHeight, cameraPosZ)
    local playerParam = (ballToGoalDis + PlayerStartShootPosToBallDis) / ballToGoalDis
    local playerPosX = playerParam * ballPosX
    local playerPosZ = playerParam * (ballPosZ + 55) - 55
    ShootPlayerStartPos[i] = Vector3(playerPosX, 0, playerPosZ)
end

-- 第一次之后的射门球员开始射门的时间
local ShootPlayerStartTime = 1

-- 第一次之后的射门球员暂停的时间
local ShootPlayerPauseTime = 1.5

-- 球门前玻璃板的localScale
local GlassBoardScale = Vector3(1.36, 1.05, 5)

-- 恭喜获得板自动关闭时间
local CongratulationBoardAutoCloseTime = 5

local function easeInOutCubic(s, e, v)
    v = v / 0.5
    e = e - s
    if v < 1 then
        return e * 0.5 * v * v * v + s
    end
    v = v - 2
    return e * 0.5 * (v * v * v + 2) + s
end

local function easeOutExpo(s, e, v)
    e = e - s
    return e * (-math.pow(2, -10 * v) + 1) + s
end

local function easeOutQuart(s, e, v)
    v = v - 1
    e = e - s
    return -e * (math.pow(v, 4) - 1) + s
end

local function easeBezierCurve(s, c, e, v)
    return (1 - v) * (1 - v) * s + 2 * v * (1 - v) * c + v * v * e
end

function GachaAnimationView:ctor()
    GachaAnimationView.super.ctor(self)

    self.skipBtn = self.___ex.skipBtn
    self.mainCamera = self.___ex.mainCamera
    self.mainBallTransform = self.___ex.mainBallTransform
    self.otherBalls = self.___ex.otherBalls
    self.finger = self.___ex.finger
    self.fingerDown = self.___ex.fingerDown
    self.fingerUp = self.___ex.fingerUp
    self.fingerTest = self.___ex.fingerTest
    self.animator = self.___ex.animator
    self.player = self.___ex.player
    self.ball = self.___ex.ball
    self.kitFontTexture = self.___ex.kitFontTexture
    self.kitFont = self.___ex.kitFont
    self.maskCanvas = self.___ex.maskCanvas
    self.maskImage = self.___ex.maskImage
    self.glass = self.___ex.glass
    self.questionMark = self.___ex.questionMark
    self.ballQuality = self.___ex.ballQuality
    self.fireworks1 = self.___ex.fireworks1
    self.fireworks2 = self.___ex.fireworks2
    self.gachaCameraCtrl = self.___ex.gachaCameraCtrl
    self.gachaBox = self.___ex.gachaBox
    self.endCallback = nil
    self.leftAim = self.___ex.leftAim
    self.exposureAnim = self.___ex.exposureAnim

    self.brokenBoards = {}
    self.bgmPlayer = AudioManager.GetPlayer("GachaBGM")
    self.bgmPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/Gacha/001_Gacha_Intro.wav", 1, function()
        local function playBGM(path)
            self.bgmPlayer.PlayAudio(path, 1, function()
                playBGM(path)
            end)
        end
        if self:GetDataLength() == 1 then
            playBGM("Assets/CapstonesRes/Game/Audio/UI/Gacha/002_Gacha_1time_Loop.wav")
        else
            playBGM("Assets/CapstonesRes/Game/Audio/UI/Gacha/002_Gacha_10times_Loop.wav")
        end
    end)

    self.skipBtn:regOnButtonClick(function()
        self:EndGachaAnimation()
    end)

    self:initSpectators()
    self:setSpectators()
end

function GachaAnimationView:GetDataLength()
    local length = 0
    if type(self.data.card) == "table" then
        length = length + #self.data.card
    end
    if type(self.data.item) == "table" then
        length = length + #self.data.item
    end
    if type(self.data.mDetail) == "table" then
        length = length + #self.data.mDetail
    end
    return length
end

local SpectatorsState = {
    INVALID = 0,
    CALM = 1,
    CHEER = 2,
}


function GachaAnimationView:setSpectatorsFrames(side, startFrame, endFrams)
    local denseMaterial = self.spectatorsMaterial[side .. "Dense"]
    local sparseMaterial = self.spectatorsMaterial[side .. "Sparse"]

    denseMaterial:SetInt("_StartFrame", startFrame)
    denseMaterial:SetInt("_EndFrame", endFrams)
    sparseMaterial:SetInt("_StartFrame", startFrame)
    sparseMaterial:SetInt("_EndFrame", endFrams)
end

function GachaAnimationView:setSpectatorsSpeed(side, speed)
    local denseMaterial = self.spectatorsMaterial[side .. "Dense"]
    local sparseMaterial = self.spectatorsMaterial[side .. "Sparse"]

    denseMaterial:SetFloat("_Speed", speed)
    sparseMaterial:SetFloat("_Speed", speed)
end

function GachaAnimationView:initSpectators()
    self.spectatorsMaterial = {}
    self.spectatorsMaterial.homeDense = Object.Instantiate(self.___ex.spectatorsMaterial.homeDense) 
    self.spectatorsMaterial.homeSparse = Object.Instantiate(self.___ex.spectatorsMaterial.homeSparse) 
    self.spectatorsMaterial.awayDense = Object.Instantiate(self.___ex.spectatorsMaterial.awayDense) 
    self.spectatorsMaterial.awaySparse = Object.Instantiate(self.___ex.spectatorsMaterial.awaySparse)

    local spectatorsMap = {
        ["1_A1"] = "homeDense",
        ["1_A2"] = "homeDense",
        ["1_B"] = "awayDense",
        ["1_C1"] = "homeDense",
        ["1_C2"] = "homeDense",
        ["1_D"] = "homeDense",
        ["2_A1"] = "homeSparse",
        ["2_A2"] = "homeSparse",
        ["2_B"] = "awaySparse",
        ["2_C1"] = "homeSparse",
        ["2_C2"] = "homeSparse",
        ["2_D"] = "homeSparse",
        ["3_A1"] = "homeSparse",
        ["3_A2"] = "homeSparse",
        ["3_B"] = "awaySparse",
        ["3_C1"] = "homeSparse",
        ["3_C2"] = "homeSparse",
        ["3_D"] = "homeSparse",
    }

    for k, v in pairs(self.___ex.spectatorsRenderer) do
        if spectatorsMap[k] then
            v.sharedMaterial = self.spectatorsMaterial[spectatorsMap[k]]
        end
    end

    self.spectatorsState = {
        home = SpectatorsState.INVALID,
        away = SpectatorsState.INVALID,
    }

    self:cheerSpectators("home")
    self:cheerSpectators("away")
end

function GachaAnimationView:setSpectators()
    local playerColor = {}
    local playerInfoModel = PlayerInfoModel.new()
    local playerParas = playerInfoModel:GetSpectators()
    playerColor.Red = ClothUtils.parseColorString(playerParas.firstColor)
    playerColor.Green = ClothUtils.parseColorString(playerParas.secondColor)
    playerColor.MaskTex = playerParas.maskTex

    local homeColor = playerColor
    local awayColor = playerColor

    local denseSpectatorsPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Spectators/Dense/" .. playerColor.MaskTex .. ".png"
    local sparseSpectatorsPath = "Assets/CapstonesRes/Game/Models/Stadium/Textures/Spectators/Sparse/" .. playerColor.MaskTex .. ".png"

    self.spectatorsMaterial.homeDense:SetColor("_FirstColor", playerColor.Red)
    self.spectatorsMaterial.homeDense:SetColor("_SecondColor", playerColor.Green)
    self.spectatorsMaterial.homeDense:SetColor("_ThirdColor", Color(0.075, 0.067, 0.259, 1))
    self.spectatorsMaterial.homeDense:SetTexture("_MaskTex", res.LoadRes(denseSpectatorsPath))

    self.spectatorsMaterial.homeSparse:SetColor("_FirstColor", playerColor.Red)
    self.spectatorsMaterial.homeSparse:SetColor("_SecondColor", playerColor.Green)
    self.spectatorsMaterial.homeSparse:SetColor("_ThirdColor", Color(0.439, 0.365, 0.051, 1))
    self.spectatorsMaterial.homeSparse:SetTexture("_MaskTex", res.LoadRes(sparseSpectatorsPath))

    self.spectatorsMaterial.awayDense:SetColor("_FirstColor", playerColor.Red)
    self.spectatorsMaterial.awayDense:SetColor("_SecondColor", playerColor.Green)
    self.spectatorsMaterial.awayDense:SetColor("_ThirdColor", Color(0.075, 0.067, 0.259, 1))
    self.spectatorsMaterial.awayDense:SetTexture("_MaskTex", res.LoadRes(denseSpectatorsPath))

    self.spectatorsMaterial.awaySparse:SetColor("_FirstColor", playerColor.Red)
    self.spectatorsMaterial.awaySparse:SetColor("_SecondColor", playerColor.Green)
    self.spectatorsMaterial.awaySparse:SetColor("_ThirdColor", Color(0.439, 0.365, 0.051, 1))
    self.spectatorsMaterial.awaySparse:SetTexture("_MaskTex", res.LoadRes(sparseSpectatorsPath))
end

local spectatorsSpeed = 6

function GachaAnimationView:cheerSpectators(side)
    if self.spectatorsState[side] ~= SpectatorsState.CHEER then
        self.spectatorsState[side] = SpectatorsState.CHEER
        self:coroutine(function()
            coroutine.yield(WaitForSeconds(1 / spectatorsSpeed))
            self:setSpectatorsSpeed(side, 0)
            self:setSpectatorsFrames(side, 5, 5)
            coroutine.yield(WaitForSeconds(1 / spectatorsSpeed))
            self:setSpectatorsSpeed(side, 0)
            self:setSpectatorsFrames(side, 6, 6)
            coroutine.yield(WaitForSeconds(1 / spectatorsSpeed))
            self:setSpectatorsSpeed(side, spectatorsSpeed)
            self:setSpectatorsFrames(side, 7, 16)
        end)
    end
end

function GachaAnimationView:InitView(contents, endCallback)
    self.finger.gameObject:SetActive(false)
    res.SetSceneLightmaps{}

    self.curStep = 1
    self.data = contents
    self.endCallback = endCallback

    local playerInfoModel = PlayerInfoModel.new()
    local teamLogoData = playerInfoModel:GetTeamLogo()
    local homeUniformData = playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Home)
    homeUniformData.logo = teamLogoData

    local playerTeamsModel = PlayerTeamsModel.new()
    local initPlayerData = playerTeamsModel:GetInitPlayersData(playerTeamsModel:GetNowTeamId())

    local nameNumList = {}
    for k, pcid in pairs(initPlayerData) do
        if tonumber(k) ~= 26 then
            local playerModel = CardBuilder.GetStarterModel(pcid)
            local modelID = playerModel:GetModelID()
            local cid = playerModel:GetCid()
            table.insert(nameNumList, {CardModel[modelID].kitName, Card[cid].numberPreference[1], ["modelID"] = modelID})
        end
    end

    NameNumGenerator.GenerateBaseTexture(NameNumGenerator.NameNumType.NameTop, nameNumList, function(nameNumTexture)
        -- not gk
        BaseTexGenerator.GenerateBaseTexture(homeUniformData, function(texture)
            local backNumColor = ClothUtils.parseColorString(homeUniformData.backNumColor)
            local trouNumColor = ClothUtils.parseColorString(homeUniformData.trouNumColor)
            for i = 1, #nameNumList do
                local player = self.player[format("p%s", i)]:GetComponent(PlayerBuilder)
                -- PlayerReplacer.replaceMesh(player, "Face1", "FaceTexture1_B", false, nil, "HairTexture1", nil, PlayerModelConstructer.constHairColor.Black, 180, "BodyB") 
                local athleteData = PlayerModelConstructer.CreatePlayerData(nameNumList[i].modelID)
                PlayerReplacer.replaceMesh(player, athleteData.faceMesh, athleteData.faceTexture, athleteData.isUseFaceHair, athleteData.hairMesh, athleteData.hairTextrue, athleteData.beardTexture, athleteData.hairColor, athleteData.height, athleteData.bodyTexture, athleteData.bodyHairTexture, athleteData.somato, athleteData.faceHairTexID, true)                           
                PlayerReplacer.replaceKitNew(player, texture, nameNumTexture, NameNumGenerator.GetUVWH(i), backNumColor, trouNumColor)
            end
        end)
    end)
end

-- 播放开场动画完毕时的回调
function GachaAnimationView:OnTowardsBall()
    self:RotateAroundBall()
end

-- 播放开场动画灯光调整完成
function GachaAnimationView:OnAnimEnd()
    self.animator.enabled = false
end

-- 亮灯时的回调
function GachaAnimationView:OnLightOn()
    self.actionPlayer = AudioManager.GetPlayer("GachaAction")
    self.actionPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/Gacha/gacha_lighton.wav", 1)
    self.mainCamera:GetComponent(Camera).fieldOfView = CameraFirstFOV
end

-- 播放开场动画开始转向球的回调
function GachaAnimationView:OnRotateToBall()
    -- 打开光照贴图
    res.SetSceneLightmaps{lightMapPath}
end

function GachaAnimationView:InitCameraState()
    if self:GetDataLength() == 1 then
        self.mainCamera.localPosition = Vector3(4.63743, 9.38634, -10.092)
        self.mainCamera.eulerAngles = Vector3(24.597, -170, 0)
    else
        self.mainCamera.localPosition = Vector3(8.336, 6.2866, -51.545)
        self.mainCamera.eulerAngles = Vector3(28.3, -47.736, 0)
    end
end

-- 使用DeadBallTimeManager来做摄像机的移动，同时球员开始向球跑动，最终停在射门的一瞬间
function GachaAnimationView:RotateAroundBall()
    self.gachaCameraCtrl:DoCameraRotate()

    if self:GetDataLength() == 1 then
        self.gachaCameraCtrl.anim:Play("CGacha_Ten")
    else
        self.gachaCameraCtrl.anim:Play("CGacha_One")
    end
    self.gachaCameraCtrl.anim:Update(0)

    -- 十个球员均向前走
    for i = 1, 10 do
        self:ShooterStartAction(i)
    end
    self:coroutine(function()
        local startTime = Time.time
        local lastPassedTime = Time.time
        while true do
            coroutine.yield()
            local passedTime = Time.time - startTime
            if passedTime > FirstShootPauseTime then
                self.fireworks1:SetActive(false)
                self.fireworks2:SetActive(false)
                self.gachaCameraCtrl.gameObject:SetActive(false)
                -- 进入手动射门时间
                self:ShooterPause()
                self:ShowFingerGuide()

                break
            end
            lastPassedTime = passedTime
        end
    end)
end

-- 球员开始射门
function GachaAnimationView:ShooterShoot(i)
    self.player[format("p%s", i or 1)]:Shoot()
end

-- 球员开始向球走动
function GachaAnimationView:ShooterStartAction(i)
    self.player[format("p%s", i or 1)]:StartAction(i)
end

-- 球员停止动作
function GachaAnimationView:ShooterPause(i)
    self.player[format("p%s", i or 1)]:Pause()
end

-- 球员继续动作
function GachaAnimationView:ShooterContinue(i)
    self.player[format("p%s", i or 1)]:Continue()
end

-- 显示射门引导
function GachaAnimationView:ShowFingerGuide()
    self.finger.gameObject:SetActive(true)
    self.fingerDown:SetActive(false)
    self.fingerUp:SetActive(true)

    self.fingerTest.gameObject:SetActive(true)
    self.fingerTest:EnableTouch(true)
    self.fingerTest:ShowBallGuide()

    local canvasWidth = self.transform.rect.width
    local canvasHeight = self.transform.rect.height
    local ballPos = self.mainBallTransform.position
    
    local ballScreenPos = Camera.main.WorldToScreenPoint(ballPos)
    local startAp = Vector2(ballScreenPos.x / Camera.main.pixelWidth * canvasWidth, ballScreenPos.y / Camera.main.pixelHeight * canvasHeight)

    local goalCenterPos = Vector3(0, Goal.Height / 2, -55)
    local goalCenterScreenPos = Camera.main.WorldToScreenPoint(goalCenterPos)
    local endAp = Vector2(goalCenterScreenPos.x / Camera.main.pixelWidth * canvasWidth, goalCenterScreenPos.y / Camera.main.pixelHeight * canvasHeight)

    endAp = Vector2(endAp.x * 2 / 3 + startAp.x / 3, endAp.y * 2 / 3 + startAp.y / 3)

    self.finger.anchoredPosition = startAp
    
    local mySequence = DOTween.Sequence()
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self.fingerUp:SetActive(true)
        self.fingerDown:SetActive(false)
    end)
    TweenSettingsExtensions.AppendInterval(mySequence, FingerDownAndUpStopTime)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self.fingerUp:SetActive(false)
        self.fingerDown:SetActive(true)
    end)
    TweenSettingsExtensions.AppendInterval(mySequence, FingerDownAndUpStopTime)
    TweenSettingsExtensions.Append(mySequence, ShortcutExtensions.DOAnchorPos(self.finger, endAp, FingerGuideTimeDuration))
    TweenSettingsExtensions.AppendInterval(mySequence, FingerDownAndUpStopTime)
    TweenSettingsExtensions.AppendCallback(mySequence, function ()
        self.fingerUp:SetActive(true)
        self.fingerDown:SetActive(false)
    end)
    TweenSettingsExtensions.AppendInterval(mySequence, FingerDownAndUpStopTime)
    TweenSettingsExtensions.SetLoops(mySequence, -1)
    self.fingerMoveTweener = mySequence
end

-- 隐藏射门引导
function GachaAnimationView:HideFingerGuide()
    self.finger.gameObject:SetActive(false)
    if self.fingerMoveTweener then
        TweenExtensions.Kill(self.fingerMoveTweener)
    end
    self.fingerTest:EnableTouch(false)
    self.fingerTest.gameObject:SetActive(false)
    self:ShooterContinue(1)
end

function GachaAnimationView:OnShootEndCallback(shootPath)
    self:HideFingerGuide()
    self:DoBallFly(shootPath)
end

function GachaAnimationView:AdjustEndPositionToGoal(endPosition)
    local fromLeft = 0
    local fromBottom = 0
    local minDistance = math.max_int32
    local newEndPosition = nil
    local newEndPositionName = nil

    for k, v in pairs(self.gachaBox) do
        local distance = Vector3.Distance(endPosition, v.position)
        if distance < minDistance then
            minDistance = distance
            newEndPosition = v.position
            newEndPositionName = v.gameObject.name
        end
    end

    if newEndPositionName == "GachaBoxLeft" then
        newEndPosition = newEndPosition + Vector3(0.2, 0, -3)
    elseif newEndPositionName == "GachaBoxMiddle" then
        newEndPosition = newEndPosition + Vector3(-0.4, 0, -3)
    elseif newEndPositionName == "GachaBoxRight" then
        newEndPosition = newEndPosition + Vector3(-0.6, 0, -3)
    end

    return newEndPosition, fromLeft, fromBottom, newEndPositionName
end

local BoardEffectStartChangeAlpha = 0.5
local BoardEffectAllWhite = 0.7
local BoardEffectEnd = 0.7

function GachaAnimationView:OnTriggerEnter(animGO)
    anim = animGO:GetComponent(Animator)
    anim.enabled = true
    anim:Play("GachaBoxAnimation")

    local camPosition = self.mainCamera.position
    local camRotate = self.mainCamera.rotation
    local camAimPos = self.leftAim.position
    local camAimRotate = self.leftAim.rotation

    if self.endPositionName == "GachaBoxMiddle" then
        camAimPos = camAimPos - Vector3(2.8, 0, 0)
    elseif self.endPositionName == "GachaBoxRight" then
        camAimPos = camAimPos - Vector3(2 * 2.5, 0, 0)
    end

    self:coroutine(function()
        self.gachaCameraCtrl.gameObject:SetActive(false)
        self.gachaCameraCtrl.anim:Stop()
        local startTime = Time.time
        while true do
            coroutine.yield()
            local step = Time.time - startTime
            self.mainCamera.rotation = Quaternion.Lerp(camRotate, camAimRotate, step * (1 + step))
            self.mainCamera.position = Vector3.Lerp(camPosition, camAimPos, step * (1 + step))
            if step * (1 + step) >= 1 then
                break
            end
        end

        self:coroutine(function ()
            local camLocalPosition = self.mainCamera.localPosition
            local shakeAmount = 0.04
            local decreaseFactor = 1.0
            local shakeTime = 1.0
            self.exposureAnim.enabled = true
            while true do
                if shakeTime > 0 then
                    self.mainCamera.localPosition = camLocalPosition + Random.insideUnitSphere * shakeAmount
                    shakeTime = shakeTime - Time.deltaTime * decreaseFactor
                else
                    shakeTime = 0
                    self.mainCamera.localPosition = camLocalPosition
                    break
                end
                coroutine.yield()
            end
        end)
    end)
end

function GachaAnimationView:DoBallFly(shootPath)
    self.actionPlayer = AudioManager.GetPlayer("GachaAction")
    self.actionPlayer.PlayAudio("Assets/CapstonesRes/Game/Audio/UI/Gacha/gacha_kick.wav", 1)

    self.ballQuality:SetActive(false)
    local totalTime = shootPath.flyDuration * BallFlySpeed
    local startPosition = shootPath.startPosition
    local endPosition, fromLeft, fromBottom, endPositionName = self:AdjustEndPositionToGoal(shootPath.endPosition)
    self.endPositionName = endPositionName
    self.fromLeft = fromLeft
    self.fromBottom = fromBottom

    local controlPoint = Vector3((startPosition.x + endPosition.x) / 2, (startPosition.y + endPosition.y) / 2 + 0.5, (startPosition.z + endPosition.z) / 2)

    local startMainCameraPositionX = self.mainCamera.position.x
    local startMainCameraPositionY = self.mainCamera.position.y
    local startMainCameraPositionZ = self.mainCamera.position.z
    local startBallPositionX = self.mainBallTransform.position.x
    local startBallPositionZ = self.mainBallTransform.position.z
    local startCameraToBallDis = math.sqrt(math.pow(startMainCameraPositionX - startBallPositionX, 2) + math.pow(startMainCameraPositionZ - startBallPositionZ, 2))
    local startCameraRotationY = self.mainCamera.localRotation.eulerAngles.y

    self.ballRotateTweener = ShortcutExtensions.DOLocalRotate(self.mainBallTransform, Vector3(-360, 0, 0), BallRotateSpeed, RotateMode.FastBeyond360)
    TweenSettingsExtensions.SetEase(self.ballRotateTweener, Ease.Linear)
    TweenSettingsExtensions.SetLoops(self.ballRotateTweener, -1)

    self.gachaCameraCtrl:DoCameraRotate()
    self.gachaCameraCtrl.anim:Play(endPositionName)

    self:coroutine(function()
        local lastPassedTime = Time.time
        local startTime = Time.time
        while true do
            coroutine.yield()
            local passedTime = Time.time - startTime
            local value
            if passedTime < totalTime * BallFlySpeedDownStartTimePercent then
                value = passedTime / totalTime
            elseif passedTime < totalTime * BallFlySpeedDownStartTimePercent + BallFlySpeedDownTimeTotal then
                value = BallFlySpeedDownStartTimePercent + (1 - BallFlySpeedDownStartTimePercent) * easeOutQuart(0, 1, (passedTime - totalTime * BallFlySpeedDownStartTimePercent) / BallFlySpeedDownTimeTotal)
            else
                break
            end

            -- 设置球的位置
            local ballPosX = easeBezierCurve(startPosition.x, controlPoint.x, endPosition.x, value)
            local ballPosY = easeBezierCurve(startPosition.y, endPosition.y, endPosition.y, value)
            local ballPosZ = easeBezierCurve(startPosition.z, controlPoint.z, endPosition.z, value)
            self.mainBallTransform.position = Vector3(ballPosX, ballPosY, ballPosZ)

            lastPassedTime = passedTime
        end
    end)
end

function GachaAnimationView:ShowCongratulationsPage(data, closeCallback)
    local dialog, dialogcomp = res.ShowDialog("Assets/CapstonesRes/Game/UI/Scene/Congratulations/Congratulations.prefab", "camera", true, true)
    dialogcomp.___ex.ImgShadow.color = Color(0, 0, 0, 1)
    local script = dialogcomp.contentcomp
    local closeDialog = script.closeDialog
    script.closeDialog = function()
        closeDialog()
        if type(closeCallback) == "function" then
            closeCallback()
        end
    end
    local playerInfoModel = PlayerInfoModel.new()
    script:InitView(data, playerInfoModel)

    -- 自动关闭
    self:coroutine(function()
        coroutine.yield(WaitForSeconds(CongratulationBoardAutoCloseTime))
        if script and script ~= clr.null and not script:IsPlayMoveOutAnim() then
            script:PlayMoveOutAnim()
        end
    end)
end

function GachaAnimationView:EndGachaAnimation()
    if type(self.endCallback) == "function" then
        self.endCallback()
    end
end

function GachaAnimationView:onDestroy()
    if self.bgmPlayer then
        Object.Destroy(self.bgmPlayer.gameObject)
    end

    if self.actionPlayer then
        Object.Destroy(self.actionPlayer.gameObject)
    end
    
    res.CollectGarbageDeep()
end

return GachaAnimationView
