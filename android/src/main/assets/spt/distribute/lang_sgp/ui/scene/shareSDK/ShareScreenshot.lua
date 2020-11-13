local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local RenderTexture = UnityEngine.RenderTexture
local Texture2D = UnityEngine.Texture2D
local TextureFormat = UnityEngine.TextureFormat
local Application = UnityEngine.Application
local Screen = UnityEngine.Screen
local Rect = UnityEngine.Rect
local Camera = UnityEngine.Camera
local PlatDependant = clr.Capstones.PlatExt.PlatDependant
local WaitForSeconds = UnityEngine.WaitForSeconds
local ImageConversion = UnityEngine.ImageConversion

local ShareScreenshot = class(unity.base)

function ShareScreenshot:ctor()
    self.canvas = self.___ex.canvas
    self.screenshotCamera = self.___ex.screenshotCamera
    self.screenImage = self.___ex.image
    self.descLong = self.___ex.descLong
    self.descShort = self.___ex.descShort
end

function ShareScreenshot:CreateScreenShot(screenTex, toUrl, longText, shortText, callBack)
    local width = Screen.width
    local height = Screen.height
    self.descLong.text = longText
    self.descShort.text = shortText

    self.screenImage.texture = screenTex

    local currentRenderTexture = RenderTexture.active
    RenderTexture.active = self.screenshotCamera.targetTexture
    self.screenshotCamera:Render()

    local texMain = Texture2D(width, height, TextureFormat.RGB24, false)
    texMain:ReadPixels(Rect(0, 0, width, height), 0, 0, true)
    texMain:Apply()
    RenderTexture.active = currentRenderTexture

    local dir = tostring(Application.persistentDataPath) .. "/screenshot"
    local name = os.date("%H%M%S")
    local path = dir .. "/share" .. tostring(name) ..".jpg"
    local jpgBytes = ImageConversion.EncodeToJPG(texMain)
    local bytesArray = clr.array(jpgBytes)
    PlatDependant.CreateFolder(dir)
    PlatDependant.DeleteFile(path)
    local stream = PlatDependant.OpenWrite(path)
    stream:Write(bytesArray, 0, bytesArray.Length)
    stream:Dispose()
    self.imgPath = path
    if callBack ~= nil then
        callBack()
    end
end

function ShareScreenshot:GetImagePath()
    return self.imgPath
end

function ShareScreenshot:DestroyScreenshotCamera()  
    Object.Destroy(self.gameObject)
end

return ShareScreenshot
