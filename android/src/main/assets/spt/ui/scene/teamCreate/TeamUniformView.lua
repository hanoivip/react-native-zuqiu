local UnityEngine = clr.UnityEngine
local Time = UnityEngine.Time
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local Object = UnityEngine.Object
local Button = UnityEngine.UI.Button

local RenderSettings = UnityEngine.RenderSettings
local Color = UnityEngine.Color

local PlayerReplacer = require("coregame.PlayerReplacer")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")
local BaseTexGenerator = require("cloth.BaseTexGenerator") 
local ClothUtils = require("cloth.ClothUtils")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local NameNumGenerator = require("cloth.NameNumGenerator")

local TeamUniformView = class(unity.base)

local dragWidth = 400
-- 相当于不做小动作，先这么改，防止以后再改回来
local autoMoveRange = {
    min = 1500000,
    max = 2000000,
}
local autoResetPositionTime = 20
local origPosition = Vector3(0, -88, 0)
local origRotation = Quaternion.Euler(0, -180, 0)
local origCameraPosition = Vector3(0, 0, -600)
local origCameraRotation = Quaternion.Euler(0, 0, 0)
local buttonClickSpan = 3

function TeamUniformView:ctor()
    self.backBtn = self.___ex.backBtn
    self.continueBtn = self.___ex.continueBtn
    self.randomBtn = self.___ex.randomBtn
    self.homePlayerTransform = self.___ex.homePlayerTransform
    self.homePlayerAnimator = self.___ex.homePlayerAnimator
    self.awayPlayerTransform = self.___ex.awayPlayerTransform
    self.awayPlayerAnimator = self.___ex.awayPlayerAnimator
    self.homePlayerDragArea = self.___ex.homePlayerDragArea 
    self.awayPlayerDragArea = self.___ex.awayPlayerDragArea 
    self.homePlayerBuilder = self.___ex.homePlayerBuilder
    self.awayPlayerBuilder = self.___ex.awayPlayerBuilder
    self.homePlayerCamera = self.___ex.homePlayerCamera
    self.awayPlayerCamera = self.___ex.awayPlayerCamera
    self.sceneAnimator = self.___ex.sceneAnimator
    self.kitFontTexture = self.___ex.kitFontTexture
    self.kitFont = self.___ex.kitFont
    self.teamLogo = self.___ex.teamLogo

    self.homePlayerDragArea:RegOnBeginDrag(function (eventData)
        self:RotateHomePlayer(eventData)
    end)
    self.homePlayerDragArea:RegOnDrag(function (eventData)
        self:RotateHomePlayer(eventData)
    end)
    self.homePlayerDragArea:RegOnEndDrag(function (eventData)
        self:RotateHomePlayer(eventData)
    end)
    self.awayPlayerDragArea:RegOnBeginDrag(function (eventData)
        self:RotateAwayPlayer(eventData)
    end)
    self.awayPlayerDragArea:RegOnDrag(function (eventData)
        self:RotateAwayPlayer(eventData)
    end)
    self.awayPlayerDragArea:RegOnEndDrag(function (eventData)
        self:RotateAwayPlayer(eventData)
    end)

    self.homeMoveTime = math.random(autoMoveRange.min, autoMoveRange.max)
    self.homeMoveStartTime = Time.time
    self.awayMoveTime = math.random(autoMoveRange.min, autoMoveRange.max)
    self.awayMoveStartTime = Time.time
    self.homeResetStartTime = Time.time
    self.awayResetStartTime = Time.time

    RenderSettings.ambientLight = Color(0.588, 0.588, 0.588, 1)

    PlayerReplacer.replaceMesh(self.homePlayerBuilder, "Face1", "FaceTexture1_B", false, nil, "HairTexture1", nil, PlayerModelConstructer.constHairColor.Black, 180, "BodyB", nil, nil, nil, true)
    self.homePlayerTransform.localScale = Vector3(100, 100, 100)
    PlayerReplacer.replaceMesh(self.awayPlayerBuilder, "Face1", "FaceTexture1_B", false, nil, "HairTexture1", nil, PlayerModelConstructer.constHairColor.Black, 180, "BodyB", nil, nil, nil, true)
    self.awayPlayerTransform.localScale = Vector3(100, 100, 100)
end

function TeamUniformView:update()
    if type(self.homeMoveTime) == "number" and type(self.homeMoveStartTime) == "number" and Time.time - self.homeMoveStartTime > self.homeMoveTime then
        self.homePlayerAnimator:SetTrigger("MoveTrigger")
        self.homeMoveStartTime = Time.time
        self.homeMoveTime = math.random(autoMoveRange.min, autoMoveRange.max)
    end
    if type(self.awayMoveTime) == "number" and type(self.awayMoveStartTime) == "number" and Time.time - self.awayMoveStartTime > self.awayMoveTime then
        self.awayPlayerAnimator:SetTrigger("MoveTrigger")
        self.awayMoveStartTime = Time.time
        self.awayMoveTime = math.random(autoMoveRange.min, autoMoveRange.max)
    end
    if type(self.homeResetStartTime) == "number" and Time.time - self.homeResetStartTime > autoResetPositionTime then
        if self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01") or self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01 0") then
            self.homePlayerTransform.localPosition = origPosition
            self.homePlayerTransform.localRotation = origRotation
        end
        self.homeResetStartTime = Time.time
    end
    if type(self.awayResetStartTime) == "number" and Time.time - self.awayResetStartTime > autoResetPositionTime then
        if self.awayPlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01") or self.awayPlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01 0") then
            self.awayPlayerTransform.localPosition = origPosition
            self.awayPlayerTransform.localRotation = origRotation
        end
        self.awayResetStartTime = Time.time
    end
end

function TeamUniformView:RegOnBackBtnClick(func)
    if type(func) == "function" then
        self.backBtn:regOnButtonClick(func)
    end
end

function TeamUniformView:ResetCameraPosition()
    self.homePlayerCamera.localPosition = origCameraPosition
    self.homePlayerCamera.localRotation = origCameraRotation
    self.awayPlayerCamera.localPosition = origCameraPosition
    self.awayPlayerCamera.localRotation = origCameraRotation
end

function TeamUniformView:ClearTeamLogo()
    for i = 1, self.teamLogo.childCount do
        Object.Destroy(self.teamLogo:GetChild(i - 1).gameObject)
    end
end

function TeamUniformView:InitView(homeModel, awayModel, teamLogo)
    self:ResetCameraPosition()

    self.randomBtn:onPointEventHandle(true)
    self.randomBtn:GetComponent(Button).interactable = true

    -- self:SetPlayerCloth(homeModel, awayModel)
    self:OnRandomUniform(homeModel, awayModel)
    
    self:ClearTeamLogo()
    if teamLogo then
        teamLogo.transform:SetParent(self.teamLogo, false)
    end
end

function TeamUniformView:DoChangeUniformAction()
    if (self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01")
        or self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01 0"))
        and
        (self.awayPlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01")
        or self.awayPlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01 0")) then
        local homeRandom = math.random(3)
        local awayRandom = math.random(3)
        while awayRandom == homeRandom do
            awayRandom = math.random(3)
        end
        self.homePlayerAnimator:SetTrigger(format("ChangeUniform%sTrigger", homeRandom))
        self.awayPlayerAnimator:SetTrigger(format("ChangeUniform%sTrigger", awayRandom))
    end
end

function TeamUniformView:SetPlayerCloth(homeModel, awayModel)
    local playerInfoModel = PlayerInfoModel.new()
    local teamLogoData = playerInfoModel:GetTeamLogo()
    local homeUniformData = clone(homeModel.data)
    homeUniformData.logo = teamLogoData 
    local awayUniformData = clone(awayModel.data)
    awayUniformData.logo = teamLogoData 

    BaseTexGenerator.GenerateBaseTexture(homeUniformData, function(homeKitTexture)
        local homeBackNumColor = ClothUtils.parseColorString(homeModel:GetBackNumColor())
        local homeTrouNumColor = ClothUtils.parseColorString(homeModel:GetTrouNumColor())
        PlayerReplacer.replaceKitNew(self.homePlayerBuilder, homeKitTexture, self.kitFontTexture, NameNumGenerator.GetUVWH(1), homeBackNumColor, homeTrouNumColor, "NormalStyle")
    end)

    BaseTexGenerator.GenerateBaseTexture(awayUniformData, function(awayKitTexture)
        local awayBackNumColor = ClothUtils.parseColorString(awayModel:GetBackNumColor())
        local awayTrouNumColor = ClothUtils.parseColorString(awayModel:GetTrouNumColor())
        PlayerReplacer.replaceKitNew(self.awayPlayerBuilder, awayKitTexture, self.kitFontTexture, NameNumGenerator.GetUVWH(1), awayBackNumColor, awayTrouNumColor, "NormalStyle")
    end)
end

function TeamUniformView:OnRandomUniform(homeModel, awayModel)
    self:SetPlayerCloth(homeModel, awayModel)
    self:DoChangeUniformAction()
end

function TeamUniformView:RegOnRandomBtnClick(func)
    if type(func) == "function" then
        self.randomBtn:regOnButtonClick(function (eventData)
            func()
        end)
    end
end

function TeamUniformView:RegOnContinueBtnClick(func)
    if type(func) == "function" then
        self.continueBtn:regOnButtonClick(func)
    end
end

function TeamUniformView:RotateHomePlayer(eventData)
    local origAngles = self.homePlayerCamera.localRotation.eulerAngles
    local angle = (eventData.delta.x / dragWidth) * 360 + origAngles.y
    self.homePlayerCamera.localRotation = Quaternion.Euler(0, angle, 0)
    self.homePlayerCamera.localPosition = Vector3(origCameraPosition.z * math.sin(angle * math.pi / 180), 0, origCameraPosition.z * math.cos(angle * math.pi / 180))
end

function TeamUniformView:RotateAwayPlayer(eventData)
    local origAngles = self.awayPlayerCamera.localRotation.eulerAngles
    local angle = (eventData.delta.x / dragWidth) * 360 + origAngles.y
    self.awayPlayerCamera.localRotation = Quaternion.Euler(0, angle, 0)
    self.awayPlayerCamera.localPosition = Vector3(origCameraPosition.z * math.sin(angle * math.pi / 180), 0, origCameraPosition.z * math.cos(angle * math.pi / 180))
end

function TeamUniformView:RegOnExitScene(func)
    self.onExitScene = func
end

function TeamUniformView:OnExitScene()
    if type(self.onExitScene) == "function" then
        self.onExitScene()
    end
end

function TeamUniformView:DoEnterSceneAnimation()
    self.sceneAnimator:Play("EnterUniformScene")
end

function TeamUniformView:DoExitSceneAnimation()
    self.sceneAnimator:Play("ExitUniformScene")
end

return TeamUniformView
