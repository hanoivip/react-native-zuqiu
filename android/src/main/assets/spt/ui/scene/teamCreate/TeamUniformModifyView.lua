local UnityEngine = clr.UnityEngine
local RenderSettings = UnityEngine.RenderSettings
local Color = UnityEngine.Color
local Time = UnityEngine.Time
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local ScrollRect = UnityEngine.UI.ScrollRect
local PlayerReplacer = require("coregame.PlayerReplacer")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")
local BaseTexGenerator = require("cloth.BaseTexGenerator") 
local ClothUtils = require("cloth.ClothUtils")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local NameNumGenerator = require("cloth.NameNumGenerator")

local TeamUniformModifyView = class(unity.base)

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

function TeamUniformModifyView:ctor()
    self.infoBarDynParent = self.___ex.infoBarDynParent
    self.saveBtn = self.___ex.saveBtn
    self.buttonGroup = self.___ex.buttonGroup
    self.maskBtn = self.___ex.maskBtn
    self.colorBtn = self.___ex.colorBtn
    self.scroll = self.___ex.scroll
    self.scrollBar = self.___ex.scrollBar
    self.kitFont = self.___ex.kitFont
    self.kitFontTexture = self.___ex.kitFontTexture
    self.uniformName = self.___ex.uniformName
    self.homePlayerTransform = self.___ex.homePlayerTransform
    self.homePlayerAnimator = self.___ex.homePlayerAnimator
    self.homePlayerDragArea = self.___ex.homePlayerDragArea 
    self.homePlayerBuilder = self.___ex.homePlayerBuilder
    self.homePlayerCamera = self.___ex.homePlayerCamera

    self.homePlayerDragArea:RegOnBeginDrag(function (eventData)
        self:RotateHomePlayer(eventData)
    end)
    self.homePlayerDragArea:RegOnDrag(function (eventData)
        self:RotateHomePlayer(eventData)
    end)
    self.homePlayerDragArea:RegOnEndDrag(function (eventData)
        self:RotateHomePlayer(eventData)
    end)

    self.homeMoveTime = math.random(autoMoveRange.min, autoMoveRange.max)
    self.homeMoveStartTime = Time.time
    self.homeResetStartTime = Time.time

    RenderSettings.ambientLight = Color(0.588, 0.588, 0.588, 1)

    PlayerReplacer.replaceMesh(self.homePlayerBuilder, "Face1", "FaceTexture1_B", false, nil, "HairTexture1", nil, PlayerModelConstructer.constHairColor.Black, 180, "BodyB", nil, nil, nil, true)
    self.homePlayerTransform.localScale = Vector3(100, 100, 100)
end

function TeamUniformModifyView:update()
    if type(self.homeMoveTime) == "number" and type(self.homeMoveStartTime) == "number" and Time.time - self.homeMoveStartTime > self.homeMoveTime then
        self.homePlayerAnimator:SetTrigger("MoveTrigger")
        self.homeMoveStartTime = Time.time
        self.homeMoveTime = math.random(autoMoveRange.min, autoMoveRange.max)
    end
    if type(self.homeResetStartTime) == "number" and Time.time - self.homeResetStartTime > autoResetPositionTime then
        if self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01") or self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01 0") then
            self.homePlayerTransform.localPosition = origPosition
            self.homePlayerTransform.localRotation = origRotation
        end
        self.homeResetStartTime = Time.time
    end
end

function TeamUniformModifyView:ResetCameraPosition()
    self.homePlayerTransform.localPosition = origPosition
    self.homePlayerTransform.localRotation = origRotation
    self.homePlayerCamera.localPosition = origCameraPosition
    self.homePlayerCamera.localRotation = origCameraRotation
end

function TeamUniformModifyView:RotateHomePlayer(eventData)
    local origAngles = self.homePlayerCamera.localRotation.eulerAngles
    local angle = (eventData.delta.x / dragWidth) * 360 + origAngles.y
    self.homePlayerCamera.localRotation = Quaternion.Euler(0, angle, 0)
    self.homePlayerCamera.localPosition = Vector3(origCameraPosition.z * math.sin(angle * math.pi / 180), 0, origCameraPosition.z * math.cos(angle * math.pi / 180))
end

function TeamUniformModifyView:DoChangeUniformAction()
    if self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01") or self.homePlayerAnimator:GetCurrentAnimatorStateInfo(0).IsName("idle01 0") then
        self.homePlayerAnimator:SetTrigger(format("ChangeUniform%sTrigger", math.random(3)))
    end
end

function TeamUniformModifyView:SetPlayerCloth(data)
    local playerInfoModel = PlayerInfoModel.new()
    local teamLogoData = playerInfoModel:GetTeamLogo()
    local data = clone(data)
    data.logo = teamLogoData 

    BaseTexGenerator.GenerateBaseTexture(data, function(homeKitTexture)
        local homeBackNumColor = ClothUtils.parseColorString(data.backNumColor)
        local homeTrouNumColor = ClothUtils.parseColorString(data.trouNumColor)
        PlayerReplacer.replaceKitNew(self.homePlayerBuilder, homeKitTexture, self.kitFontTexture, NameNumGenerator.GetUVWH(1), homeBackNumColor, homeTrouNumColor, "NormalStyle")
    end)
    self:DoChangeUniformAction()
end

function TeamUniformModifyView:SetPlyaerName(isHome)
    if isHome then
        self.uniformName.text = lang.trans("home_team_uniform")
    else
        self.uniformName.text = lang.trans("away_team_uniform")
    end
end

function TeamUniformModifyView:GetScroll()
    return self.scroll
end

function TeamUniformModifyView:JudgeScrollBarVisibility(count)
    if count > 15 then
        self.scroll:GetComponent(ScrollRect).enabled = true
        self.scrollBar:SetActive(true)
    else
        self.scroll:GetComponent(ScrollRect).enabled = false
        self.scrollBar:SetActive(false)
    end
end

function TeamUniformModifyView:RegOnDynamicLoad(func)
    self.infoBarDynParent:RegOnDynamicLoad(func)
end

function TeamUniformModifyView:RegOnSave(func)
    self.saveBtn:regOnButtonClick(func)
end

function TeamUniformModifyView:RegOnMenuMask(func)
    self.maskBtn:regOnButtonClick(func)
end

function TeamUniformModifyView:RegOnMenuColor(func)
    self.colorBtn:regOnButtonClick(func)
end

return TeamUniformModifyView

