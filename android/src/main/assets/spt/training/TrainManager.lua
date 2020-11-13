local TrainMenuCtrl = require("ui.controllers.training.TrainMenuCtrl")
local TrainType = require("training.TrainType")
local TrainData = require("training.TrainData")

local Card = require("data.Card")
local CardModel = require("data.CardModel")
local CardBuilder = require("ui.common.card.CardBuilder")
local PlayerTeamsModel = require("ui.models.PlayerTeamsModel")
local NameNumGenerator = require("cloth.NameNumGenerator")
local SimpleCardModel = require("ui.models.cardDetail.SimpleCardModel")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local PlayerReplacer = require("coregame.PlayerReplacer")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")
local BaseTexGenerator = require("cloth.BaseTexGenerator") 
local ClothUtils = require("cloth.ClothUtils")
local TeamUniformModel  = require("ui.models.common.TeamUniformModel")
local SpecificTeamData = require("cloth.SpecificTeamData")
local MatchUseShirtType = require("coregame.MatchUseShirtType")

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

local EventSystem = require("EventSystem")

local PREFAB_TRAIN_GK = "Assets/CapstonesRes/Game/Models/TrainPlayers/TrainGK.prefab"
local PREFAB_TRAIN_SHOOTER = "Assets/CapstonesRes/Game/Models/TrainPlayers/Shooter.prefab"
local PREFAB_TRAIN_BALL = "Assets/CapstonesRes/Game/Models/Ball/Ball.prefab"
local PREFAB_TRAIN_WALL = "Assets/CapstonesRes/Game/Models/Board/Wall.prefab"
local PREFAB_TRAIN_GLOVE = "Assets/CapstonesRes/Game/Models/TrainPlayers/Gloves.prefab"

local PREFAB_TRAIN_DRIBBLER = "Assets/CapstonesRes/Game/Models/TrainPlayers/Dribbler.prefab"
local PREFAB_TRAIN_STEAL = "Assets/CapstonesRes/Game/Models/TrainPlayers/Steal.prefab"
local PREFAB_TRAIN_DRIBBLER_BALL = "Assets/CapstonesRes/Game/Models/TrainPlayers/TrainBallDribble.prefab"

local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local RectTransform = UnityEngine.RectTransform
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3
local SphereCollider = UnityEngine.SphereCollider
local Mathf = UnityEngine.Mathf
local Random = UnityEngine.Random
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Camera = UnityEngine.Camera
local WaitForSeconds = UnityEngine.WaitForSeconds
local Canvas = UnityEngine.Canvas
local RenderMode = UnityEngine.RenderMode
local Application = UnityEngine.Application
local Rigidbody = UnityEngine.Rigidbody

local PlayerBuilder = clr.PlayerBuilder

local Tweening = clr.DG.Tweening
local DOTween = Tweening.DOTween
local ShortcutExtensions = Tweening.ShortcutExtensions
local TweenSettingsExtensions = Tweening.TweenSettingsExtensions
local Ease = Tweening.Ease
local LoopType = Tweening.LoopType


local function RandomRangeInt(min, max)
    return math.random(min, max)
end

local function RandomRangeFloat(min, max)
    return min + math.random() * (max - min)
end

local TrainManager = class()

function TrainManager:ctor()
    self.trainType = TrainData.trainType or TrainType.DEFEND
    self.pcid = TrainData.pcid
    if self.pcid then
        self.playerCardModel = SimpleCardModel.new(self.pcid)
    end
    self.playerModelID = self.pcid and self.playerCardModel:GetModelID() or "MDfletcher"
    self.gameID = TrainData.gameID

    self:InitClothRes()
end

function TrainManager:Init(trainMenuTrans, goalTrans)
    self.goalTrans = goalTrans
    self.trainMenuCtrl = TrainMenuCtrl.new(trainMenuTrans, self.trainType)
    self.trainData = TrainData.new()

    self.centerPos = Vector3(54, 0, 0)
    self.leftPos = Vector3(self.centerPos.x, 0, self.centerPos.z - 3.25)
    self.rightPos = Vector3(self.centerPos.x, 0, self.centerPos.z + 3.25)

    self:InitConfig()
    self:InitPlayer()
end

function TrainManager:InitConfig()
    self.currentLvl = 1
    self.life = 3
    self.score = 0
    self.defendResult = 100
    self.isTrain = true

    self.trainMenuCtrl:InitView(self.defendResult, self.trainType, self.life, self.score)
end

function TrainManager:InitPlayer()
    if self.trainType == TrainType.SHOOT then
        self:InitShootPlayer()
    elseif self.trainType == TrainType.GK then
        self:InitGKPlayer()
    elseif self.trainType == TrainType.DRIBBLE then
        self:InitDribblePlayer()
    elseif self.trainType == TrainType.DEFEND then
        self:InitDefendPlayer()
    end
end

function TrainManager:InitClothRes()
    if self.playerInfoModel == nil then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    if self.playerInfoModel.data == nil and (Application.loadedLevelName == "Training") then
        print("Editor Launch, Skip")
        return
    end

    if not self.isClothResReady then
        local playerTeamsModel = PlayerTeamsModel.new()
        local initPlayerData = playerTeamsModel:GetInitPlayersData(playerTeamsModel:GetNowTeamId())

        self.nameNumList = {}
        for k, pcid in pairs(initPlayerData) do
            local playerModel = CardBuilder.GetStarterModel(pcid)
            local modelID = playerModel:GetModelID()
            if modelID ~= self.playerModelID then
                local cid = playerModel:GetCid()
				local cardModelData = CardModel[modelID] or {}
				local cardData = Card[cid] or {}
				local cardNumPreference = cardData.numberPreference or {}
                table.insert(self.nameNumList, {cardModelData.kitName, cardNumPreference[1], ["modelID"] = modelID})
            end
        end
        -- 训练者的自身的名字与号码(插入在列表的末尾)
        table.insert(self.nameNumList, {CardModel[self.playerModelID].kitName, Card[self.playerCardModel:GetCid()].numberPreference[1], ["modelID"] = self.playerModelID})

        local teamLogoData = self.playerInfoModel:GetTeamLogo()
        local homeData = self.playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Home)
        homeData.logo = teamLogoData
        local awayData = self.playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.Away)
        awayData.logo = teamLogoData
        local homeGkData = self.playerInfoModel:GetTeamUniform(TeamUniformModel.UniformType.HomeGk)
        homeGkData.logo = teamLogoData

        local nameNumType = NameNumGenerator.NameNumType.NameTop
        if self.playerInfoModel:IsUseSpecificTeam() then
            local specificTeam = self.playerInfoModel:GetSpecificTeam()
            nameNumType = SpecificTeamData[specificTeam].nameNumType
        end

        NameNumGenerator.GenerateBaseTexture(nameNumType, self.nameNumList, function(nameNumTexture)
            self.nameNumTexture = nameNumTexture
            if self.playerInfoModel:IsUseSpecificTeam() then
                self.isClothResReady = true
                local specificTeam = self.playerInfoModel:GetSpecificTeam()
                local specificTeamData = SpecificTeamData[specificTeam]
                local clothTex = res.LoadRes(specificTeamData.resMap[MatchUseShirtType.HOME].shirtPath, UnityEngine.Texture2D)
                self.homeClothTexture = clothTex
                self.homeBackNumColor = ClothUtils.parseColorString(specificTeamData.homeShirt.backNumColor)
                self.homeTrouNumColor = ClothUtils.parseColorString(specificTeamData.homeShirt.trouNumColor)

                clothTex = res.LoadRes(specificTeamData.resMap[MatchUseShirtType.AWAY].shirtPath, UnityEngine.Texture2D)
                self.awayClothTexture = clothTex
                self.awayBackNumColor = ClothUtils.parseColorString(specificTeamData.awayShirt.backNumColor)
                self.awayTrouNumColor = ClothUtils.parseColorString(specificTeamData.awayShirt.trouNumColor)
            else
                -- 主场队服
                BaseTexGenerator.GenerateBaseTexture(homeData, function(clothTexture)
                    self.isClothResReady = true
                    local backNumColor = ClothUtils.parseColorString(homeData.backNumColor)
                    local trouNumColor = ClothUtils.parseColorString(homeData.trouNumColor)
                    self.homeClothTexture = clothTexture
                    self.homeBackNumColor = backNumColor
                    self.homeTrouNumColor = trouNumColor
                end)
                -- 客场队服
                BaseTexGenerator.GenerateBaseTexture(awayData, function(clothTexture)
                    local backNumColor = ClothUtils.parseColorString(awayData.backNumColor)
                    local trouNumColor = ClothUtils.parseColorString(awayData.trouNumColor)
                    self.awayClothTexture = clothTexture
                    self.awayBackNumColor = backNumColor
                    self.awayTrouNumColor = trouNumColor
                end)
            end
            -- 一个守门员队服
            BaseTexGenerator.GenerateBaseTexture(homeGkData, function(clothTexture)
                local backNumColor = ClothUtils.parseColorString(homeGkData.backNumColor)
                local trouNumColor = ClothUtils.parseColorString(homeGkData.trouNumColor)
                self.homeGkClothTexture = clothTexture
                self.homeGkBackNumColor = backNumColor
                self.homeGkTrouNumColor = trouNumColor
            end)            
        end)
    end    
end

function TrainManager:BuildPlayer(playerBuilder, playerModelID, uniformType)
    if self.playerInfoModel == nil then
        self.playerInfoModel = PlayerInfoModel.new()
    end
    if self.playerInfoModel.data == nil and (Application.loadedLevelName == "Training") then
        print("Editor Launch, Skip")
        return
    end

    clr.coroutine(function()
        while not self.isClothResReady do
            coroutine.yield()
        end
        
        -- playerModelID == nil
        if not playerModelID then
            playerModelID = self.nameNumList[math.random(1, #self.nameNumList - 1)].modelID
        end

        local printingStyle = PlayerReplacer.PrintingStyle.NormalStyle
        if self.playerInfoModel:IsUseSpecificTeam() then
            local specificTeam = self.playerInfoModel:GetSpecificTeam()
            printingStyle = SpecificTeamData[specificTeam].printingStyle
        end

        -- 取得modelID在nameNumList中的index
        for i = 1, #self.nameNumList do
            if self.nameNumList[i].modelID == playerModelID then
                if uniformType == TeamUniformModel.UniformType.Home then
                    PlayerReplacer.replaceKitNew(playerBuilder, self.homeClothTexture, self.nameNumTexture, NameNumGenerator.GetUVWH(i), self.homeBackNumColor, self.homeTrouNumColor, printingStyle)
                elseif uniformType == TeamUniformModel.UniformType.Away then
                    PlayerReplacer.replaceKitNew(playerBuilder, self.awayClothTexture, self.nameNumTexture, NameNumGenerator.GetUVWH(i), self.awayBackNumColor, self.awayTrouNumColor, printingStyle)
                elseif uniformType == TeamUniformModel.UniformType.HomeGk then
                    PlayerReplacer.replaceKitNew(playerBuilder, self.homeGkClothTexture, self.nameNumTexture, NameNumGenerator.GetUVWH(i), self.homeGkBackNumColor, self.homeGkTrouNumColor, printingStyle)
                end
                local athleteData = PlayerModelConstructer.CreatePlayerData(playerModelID)
                PlayerReplacer.replaceMesh(playerBuilder, athleteData.faceMesh, athleteData.faceTexture, athleteData.isUseFaceHair, athleteData.hairMesh, athleteData.hairTextrue, athleteData.beardTexture, athleteData.hairColor, athleteData.height, athleteData.bodyTexture, athleteData.bodyHairTexture, athleteData.somato, athleteData.faceHairTexID, true)              
              break
            end
        end
    end)
end

function TrainManager:InitShootPlayer()
    local lvl = self.currentLvl
    if lvl > 10 then
        lvl = 10
    end
    local info = self.trainData:GetTrainShootInfo(lvl)

    -- Ball
    self.ball:GetComponent(Rigidbody).isKinematic = false
    self.ball:GetComponent(SphereCollider).radius = 3

    local trainBall = self.ball:GetComponent(CapsUnityLuaBehav)
    trainBall.getGoal = function()
        return self.isGoal
    end
    trainBall:ClearApplyMove()
    trainBall:EndShoot()

    local ball_x = 0
    local ball_z = 0
    local deg = 90 - (info.angle * 0.5)
    local t = math.rad(deg) -- deg * Mathf.Deg2Rad
    local c = 20
    while c - 1 >= 0 do
        c = c - 1
        ball_x = RandomRangeFloat(info.min_distance * math.sin(t), info.max_distance)
        ball_z = RandomRangeFloat(-info.max_distance * math.cos(t), info.max_distance * math.cos(t))
        -- TODO: simplify caculate
        if (ball_x * ball_x + ball_z * ball_z >= info.min_distance * info.min_distance and
            ball_x * ball_x + ball_z * ball_z <= info.max_distance * info.max_distance and
            math.abs(Mathf.Atan (ball_x / ball_z)) > t) then
            break
        end
    end
    self.ball.transform.position = Vector3(self.centerPos.x - ball_x, 0.11, self.centerPos.z + ball_z)
    self.ball.transform:LookAt(self.centerPos)
    self.ball:GetComponent(Rigidbody).isKinematic = true

    -- Shooter
    if self.shooter then
        Object.Destroy(self.shooter)
        self.shooter = nil
    end
    self.shooter = res.Instantiate(PREFAB_TRAIN_SHOOTER)
    self:BuildPlayer(self.shooter:GetComponent(PlayerBuilder), self.playerModelID, TeamUniformModel.UniformType.Home)

    self.trainMenuCtrl:ReplaceHead(self.shooter)
    
    local ts = self.shooter:GetComponent(CapsUnityLuaBehav) -- TrainShooter
    ts:Init()
    self.shooter.transform.position = self.ball.transform.position - self.ball.transform.right * ts.deltaPosition.x * 7 - self.ball.transform.forward * ts.deltaPosition.z
    self.shooter.transform.position = Vector3(self.shooter.transform.position.x, 0, self.shooter.transform.position.z)
    local tmpPos = Vector3(self.ball.transform.position.x, 0, self.ball.transform.position.z)
    self.shooter.transform:LookAt(tmpPos)
    
    self.trainMenuCtrl:InitDistancePanel(Vector3.Distance(self.ball.transform.position, self.centerPos))

    -- GK
    if self.gk then
        Object.Destroy(self.gk)
        self.gk = nil
    end
    self.gk = res.Instantiate(PREFAB_TRAIN_GK)
    self:BuildPlayer(self.gk:GetComponent(PlayerBuilder), nil, TeamUniformModel.UniformType.HomeGk)

    self.gk.transform.position = Vector3(self.centerPos.x, 0, self.centerPos.z + RandomRangeFloat(-2, 2))
    self.gk.transform:LookAt(self.ball.transform.position)
    -- local trainGK = self.gk:GetComponent(CapsUnityLuaBehav)
    -- trainGK.setGoal = function(isGoal)
    --     self.isGoal = isGoal
    -- end
    -- trainGK:InitData(self.trainData)

    -- Walls
    if self.walls and #self.walls > 0 then
        for i = 1, #self.walls do
            Object.Destroy(self.walls[i])
        end
    end
    self.walls = {}

    local num = RandomRangeInt(info.min_defender, info.max_defender)
    if num == 0 then
        num = 1
    end
    for i = 1, num do
        local go = res.Instantiate(PREFAB_TRAIN_WALL)
        table.insert(self.walls, go)
    end

    local poses = {}
    for i = 1, 2 do
        local pos = self.ball.transform.position + self.ball.transform.forward * RandomRangeFloat(6, Vector3.Distance(self.ball.transform.position, self.centerPos) - 2)
        poses[i] = {}
        poses[i].pos = pos
        poses[i].left = 0
        poses[i].right = 0
        poses[i].speed = RandomRangeFloat(1, 2)
        poses[i].range = RandomRangeFloat(1, 1.5)
    end

    for i = 1, num do
        local r = RandomRangeInt(1, 2)
        local w = RandomRangeInt(1, 2)
        self.walls[i].transform.position = poses[r].pos
        self.walls[i].transform.position = Vector3(self.walls[i].transform.position.x,
                                                  0,
                                                  self.walls[i].transform.position.z)
        self.walls[i].transform:LookAt(self.ball.transform.position)
        if w == 0 then
            self.walls[i].transform.position = self.walls[i].transform.position + self.walls[i].transform.right * 0.5 * poses[r].right
            poses[r].right = poses[r].right + 1
        else
            self.walls[i].transform.position = self.walls[i].transform.position - self.walls[i].transform.right * 0.5 * poses[r].left
            poses[r].left = poses[r].left + 1
        end
        -- 往返运动，可以使用DoTween动画
        self.walls[i].transform.position = self.walls[i].transform.position - self.walls[i].transform.right * poses[r].range
        local rightPos = self.walls[i].transform.position + self.walls[i].transform.right * 2 * poses[r].range
        local tweener = ShortcutExtensions.DOMove(self.walls[i].transform, rightPos, 2 * poses[r].range / poses[r].speed, false)
        TweenSettingsExtensions.SetEase(tweener, Ease.Linear)
        TweenSettingsExtensions.SetLoops(tweener, -1, LoopType.Yoyo)
    end

    -- GameManager.GetInstance():startCameraFollowPlayerOnShoot(self.shooter.transform,  --Lua assist checked flag
    --                                                            self.ball.transform.position,
    --                                                            self.shooter.transform.position, nil, 0.1)
    EventSystem.SendEvent("training_camera_follow_when_shoot", self.shooter.transform, self.ball.transform.position, self.shooter.transform.position, 0.1)

    if not self.fingerTestCanvas then
        self.fingerTestCanvas = res.Instantiate("Assets/CapstonesRes/Game/Models/TrainPlayers/FingerTestCanvas.prefab")
        local canvasComp = self.fingerTestCanvas:GetComponent(Canvas)
        canvasComp.renderMode = RenderMode.ScreenSpaceCamera
        canvasComp.worldCamera = Camera.main
        canvasComp.planeDistance = 1
        self.fingerTestObj = self.fingerTestCanvas.transform:FindChild("FingerTest")
        self.fingerTest = self.fingerTestObj:GetComponent(clr.TrainFingerTest)
    end
    self.fingerTest.ball = self.ball.transform
    self.fingerTest:OnTrainTouchShootActivated(self.goalTrans)
    -- self.fingerTest.OnSlowMotionActivated(nil, self.shooter.transform, self.gk.transform)
end

function TrainManager:InitGKPlayer()
    local lvl = self.currentLvl
    if lvl > 10 then
        lvl = 10
    end
    local info = self.trainData:GetTrainSaveInfo(lvl)
    -- dump(info)

    local mainCamera = Camera.main
    -- mainCamera.transform:GetComponent(ShakeCamera).endShake()
    mainCamera.fieldOfView = 103
    mainCamera.transform.position = Vector3(57.31, 1.11, 0)
    mainCamera.transform.eulerAngles = Vector3(0, 270, 0)

    local vertical = RandomRangeInt(-16, 16)
    self.ball:GetComponent(Rigidbody).isKinematic = false
    self.ball:GetComponent(Rigidbody).velocity = Vector3.zero
    self.ball.transform.position = Vector3(self.centerPos.x - 13, 0.11, self.centerPos.z + vertical)
    self.ball.transform:LookAt(self.centerPos)

    -- Shooter
    if self.shooter then
        Object.Destroy(self.shooter)
        self.shooter = nil
    end
    self.shooter = res.Instantiate(PREFAB_TRAIN_SHOOTER)
    self:BuildPlayer(self.shooter:GetComponent(PlayerBuilder), nil, TeamUniformModel.UniformType.Home)

    self.trainMenuCtrl:ReplaceHead(self.shooter)
    local ts = self.shooter:GetComponent(CapsUnityLuaBehav) -- TrainShooter
    ts:Init()
    self.shooter.transform.position = self.ball.transform.position - self.ball.transform.right * ts.deltaPosition.x * 7 - self.ball.transform.forward * ts.deltaPosition.z
    self.shooter.transform.position = Vector3(self.shooter.transform.position.x, 0, self.shooter.transform.position.z)
    local tmpPos = Vector3(self.ball.transform.position.x, 0, self.ball.transform.position.z)
    self.shooter.transform:LookAt(tmpPos)
    
    self.trainMenuCtrl:InitDistancePanel(Vector3.Distance(self.ball.transform.position, self.centerPos))

    local speed = RandomRangeFloat(info.min_speed, info.max_speed)
    -- StartCoroutine(delayShoot(ts, 2f, 20f / speed))
    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(2))
        ts:Shoot()
        local deltaZ = RandomRangeFloat(-2.7, 2.7)
        local deltaY = RandomRangeFloat(0, 1.7)
        coroutine.yield(WaitForSeconds(ts.touchDuraTime))
        local ballSpt = self.ball:GetComponent(CapsUnityLuaBehav)
        ballSpt:StartRotate()
        ballSpt:ShootBall(Vector3(self.centerPos.x, self.centerPos.y + deltaY, self.centerPos.z + deltaZ), 20 / speed, true)
        ballSpt.isRoundOver = false
    end)

    if self.glove then
        Object.Destroy(self.glove)
        self.glove = nil
    end
    self.glove = res.Instantiate(PREFAB_TRAIN_GLOVE)
    self.glove.transform.position = Vector3(55, 0.8, 0)
end

function TrainManager:InitDribblePlayer()
    if self.ball then
        Object.Destroy(self.ball)
        self.ball = nil
    end
    self.ball = res.Instantiate(PREFAB_TRAIN_DRIBBLER_BALL)

    if self.dribbler then
        Object.Destroy(self.dribbler)
        self.dribbler = nil
    end
    self.dribbler = res.Instantiate(PREFAB_TRAIN_DRIBBLER)
    self:BuildPlayer(self.dribbler:GetComponent(PlayerBuilder), self.playerModelID, TeamUniformModel.UniformType.Home)
    
    local trainDribbler = self.dribbler:GetComponent(CapsUnityLuaBehav)
    trainDribbler:InitData(self.trainData, self.ball, self)

    local mainCamera = Camera.main
    mainCamera.transform.position = self.dribbler.transform.position + self.dribbler.transform.forward * 6.48 + self.dribbler.transform.up
    mainCamera.transform:LookAt(self.dribbler.transform.position + self.dribbler.transform.up)
end

function TrainManager:InitDefendPlayer()
    if self.steal then
        Object.Destroy(self.steal)
        self.steal = nil
    end
    self.steal = res.Instantiate(PREFAB_TRAIN_STEAL)
    local stealManager = self.steal:GetComponent(CapsUnityLuaBehav)
    stealManager:SetStealGameControl(self.trainMenuCtrl.trainMenuView, self)

    -- 删掉cameraMain
    local trainShootCamera = GameObject.Find("TrainShootCamera")
    if trainShootCamera then
        Object.Destroy(trainShootCamera)
    end
end

function TrainManager:SimpleTrySuccess()
    self.score = self.score + 1
    self.trainMenuCtrl:InitScorePanel(self.score)
end

function TrainManager:TrySuccess()
    local lvl = self.currentLvl
    if lvl > 10 then
        lvl = 10
    end
    local info = self.trainData:GetTrainShootInfo(lvl)
    self.currentLvl = self.currentLvl + 1
    self.score = self.score + info.score
    self.trainMenuCtrl:InitScorePanel(self.score)
    self.trainMenuCtrl:InitGoalPanel(info.score)

    local ballSpt = self.ball:GetComponent(CapsUnityLuaBehav)
    if ballSpt then
        ballSpt.isRoundOver = true
    end

    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(2))
        -- VideoCtl.GetInstance():Skip()  --Lua assist checked flag
        self:InitPlayer()
    end)
end

function TrainManager:TrySuccessCount(result)
    result = result or 1
    -- trainUIManager.InitScorePanel(defendResult);
    -- SoundCtl.GetInstance():PlaySound(ManagerConstants.SOUND_TRAIN_SHOOT_SUCCESS, false);  --Lua assist checked flag
    -- VideoCtl.GetInstance():Skip();  --Lua assist checked flag
    -- StartCoroutine(delayGameOver(1.2f));
    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(1.2))
        self.trainMenuCtrl:InitGameOverPanel(self.gameID, self.pcid, result)
    end)
end

function TrainManager:TryFailed()
    self.trainMenuCtrl:InitMissPanel()
    self.life = self.life - 1
    self.trainMenuCtrl:InitChancePanel(self.life)

    local ballSpt = self.ball:GetComponent(CapsUnityLuaBehav)
    if ballSpt then
        ballSpt.isRoundOver = true
    end

    clr.coroutine(function()
        coroutine.yield(WaitForSeconds(1))
        if self.life <= 0 then
            self:GameOver()
        else
            self:InitPlayer()
        end
    end)
end

function TrainManager:GameOver()
    self.trainMenuCtrl:InitGameOverPanel(self.gameID, self.pcid, self.trainType ~= TrainType.DEFEND and self.score or 1000)
end

function TrainManager:FingerTrigShoot(startPosition, endPosition, controlPoint, flyDuration, projectedOrigin, projectedDestination)
    local ts = self.shooter:GetComponent(CapsUnityLuaBehav)
    ts:Shoot()
    local shootStartTime = Time.time + ts.touchDuraTime

    local ballShoot = {
        type = "BallShoot",
        origin = startPosition,
        destination = endPosition,
        startTime = shootStartTime,
        time = flyDuration,
        projectedOrigin = projectedOrigin,
        projectedControl = controlPoint,
        projectedDestination = projectedDestination,
    }
    local trainBall = self.ball:GetComponent(CapsUnityLuaBehav)
    trainBall:AddBallAction(ballShoot)
    trainBall:StartShoot()

    local trainGK = self.gk:GetComponent(CapsUnityLuaBehav)
    -- trainGK:OnGoalKeeperSave(endPosition, shootStartTime + flyDuration - Time.time)
    local targetBallPosition = Vector2(endPosition.x, endPosition.z)
    local targetBallPositionHeight = endPosition.y
    local controlBallPosition = controlPoint
    local gkPosition = self.gk.transform.position
    local saveAnimation = self:EnqueueSave(startPosition, 2, targetBallPosition, targetBallPositionHeight, controlBallPosition, flyDuration, gkPosition)

    trainGK:PlayAnimationDelay(saveAnimation.name, flyDuration + 0.5)

    EventSystem.SendEvent("training_ball_trail_start")
end

-- ballPos 球的原始位置
-- gkPosition 守门员位置
-- 其他参数参照DemoMatchManager:EnqueueSave
function TrainManager:EnqueueSave(ballPos, shootResult, targetBallPosition, targetBallPositionHeight, controlBallPosition, flyDuration, gkPosition)
    -- local ballPos = startPosition
    local startBallPosition = { x = ballPos.x, y = ballPos.z }
    local startBallPositionHeight = ballPos.y
    -- local gkPosition = GameHubWrap.GetPlayerPosition(goalKeeperId) --vector3
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
    -- local saveFTBTime = saveAnimation.firstTouch * TIME_STEP
    -- local actualFlyDuration = saveFTBTime
    -- local originSaveTime = flyDuration * t
    -- local needPreSave = false

    -- local startPosition = gk
    -- if shootResult == AIUtils.shootResult.catch or shootResult == AIUtils.shootResult.saveBounce then
    --     startPosition = vector2.sub(saveBallPosition, vector2.vyrotate(saveAnimation.firstTouchBallPosition, startBodyDirection))
    --     flyDuration = saveFTBTime / t
    --     targetBallPositionHeight = Athlete.recalculateVerticalEndPoint(startBallPositionHeight, targetBallPositionHeight, saveBallPositionHeight, saveFTBTime, flyDuration)
    -- elseif shootResult == AIUtils.shootResult.goal then
    --     local newPos = vector2.sub(saveBallPosition, vector2.vyrotate(saveAnimation.firstTouchBallPosition, startBodyDirection))
    --     startPosition = startPosition + vector2.div(vector2.sub(newPos, startPosition), 2)
    -- end

    -- local save = AthleteAction.Save()
    -- save.savePosition = Vector2(saveBallPosition.x, saveBallPosition.y)
    -- save.savePositionHeight = saveBallPositionHeight
    -- if shootResult == AIUtils.shootResult.saveBounce then
    --     save.ikGoal = SaveActionIK[choice]
    -- else
    --     save.ikGoal = 0
    -- end
    -- save.shootResult = shootResult

    -- local athleteAction = AthleteAction()
    -- athleteAction.athleteActionType = AthleteAction.ActionType.Save
    -- athleteAction.saveAction = save

    -- local frame = Frame()
    -- frame.time = 0 -- DemoMatchUtilWrap.GetSaveStartTime()
    -- frame.position = Vector2(startPosition.x, startPosition.y)
    -- frame.rotation = Vector2(startBodyDirection.x, startBodyDirection.y)

    -- local firstBallOffset = BallOffset()
    -- firstBallOffset.offset = Vector3(saveAnimation.firstTouchBallPosition.x, saveAnimation.firstTouchBallHeight, saveAnimation.firstTouchBallPosition.y)
    -- firstBallOffset.deltaTime = saveAnimation.firstTouch * 0.1
    -- firstBallOffset.normalizedTime = saveAnimation.firstTouch / saveAnimation.totalFrame

    -- local lastBallOffset = BallOffset()
    -- lastBallOffset.offset = Vector3(saveAnimation.lastTouchBallPosition.x, saveAnimation.lastTouchBallHeight, saveAnimation.lastTouchBallPosition.y)
    -- lastBallOffset.deltaTime = saveAnimation.lastTouch * 0.1
    -- lastBallOffset.normalizedTime = saveAnimation.lastTouch / saveAnimation.totalFrame + 1e-6

    -- local action = Action()
    -- action.nameHash = Animator.StringToHash("Base Layer." .. saveAnimation.name)
    -- action.actionStartFrame = frame
    -- action.firstBallOffset = firstBallOffset
    -- action.lastBallOffset = lastBallOffset
    -- action.athleteAction = athleteAction

    -- if shootResult == AIUtils.shootResult.saveBounce then
    --     action.isWithBallAction = true
    -- else
    --     action.isWithBallAction = false
    -- end

    -- dump(saveAnimation)
    -- dump(action)

    return saveAnimation
end

function TrainManager:onDestroy()
    self.nameNumList = nil
    self.nameNumTexture = nil
    self.homeClothTexture = nil
    self.homeBackNumColor = nil
    self.homeTrouNumColor = nil
    self.awayClothTexture = nil
    self.awayBackNumColor = nil
    self.awayTrouNumColor = nil
    self.homeGkClothTexture = nil
    self.homeGkBackNumColor = nil
    self.homeGkTrouNumColor = nil
end

return TrainManager
