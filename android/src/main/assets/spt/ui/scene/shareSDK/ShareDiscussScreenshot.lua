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
local UnityQRCode = clr.QRCoder.UnityQRCode
local QRCodeGenerator = clr.QRCoder.QRCodeGenerator
local WaitForSeconds = UnityEngine.WaitForSeconds
local StaticCardModel = require("ui.models.cardDetail.StaticCardModel")
local ImageConversion = UnityEngine.ImageConversion

local ShareScreenshot = class(unity.base)

function ShareScreenshot:ctor()
    self.canvas = self.___ex.canvas
    self.screenshotCamera = self.___ex.screenshotCamera
    self.qrImage = self.___ex.qrImage
    self.cardParent = self.___ex.cardParent
    self.reply = self.___ex.reply
end

function ShareScreenshot:InitView(replys, cid, callBack)
    local playerCardModel = StaticCardModel.new(cid)
    local playerCardObject, playerCardView = res.Instantiate("Assets/CapstonesRes/Game/UI/Common/Card/Prefab/Card.prefab")
    playerCardView:InitView(playerCardModel)
    playerCardView:IsShowName(false)
    playerCardObject.transform:SetParent(self.cardParent.transform, false)
    local index = 1
    for k,v in pairs(self.reply) do
        self.reply[tostring(index)].text = replys[index] or ""
        index = index + 1
    end
    if callBack ~= nil then
        callBack()
    end
end

function ShareScreenshot:CreateScreenShot(toUrl, callBack)
    local width = Screen.width
    local height = Screen.height
    local qrCodeData = QRCodeGenerator():CreateQrCode(toUrl, QRCodeGenerator.ECCLevel.Q)
    local texQR = UnityQRCode(qrCodeData).GetGraphic(4)
    self.qrImage.texture = texQR

    local currentRenderTexture = RenderTexture.active
    RenderTexture.active = self.screenshotCamera.targetTexture
    self.screenshotCamera.Render()  --Lua assist checked flag

    local texMain = Texture2D(width, height, TextureFormat.RGB24, false)
    texMain:ReadPixels(Rect(0, 0, width, height), 0, 0, true)
    texMain.Apply()  --Lua assist checked flag
    RenderTexture.active = currentRenderTexture

    local dir = tostring(Application.persistentDataPath) .. "/screenshot"
    local name = os.date("%H%M%S")
    local path = dir .. "/share" .. tostring(name) ..".jpg"
    local jpgBytes = ImageConversion.EncodeToJPG(texMain)
    local bytesArray = clr.array(jpgBytes)
    PlatDependant.CreateFolder(dir)
    PlatDependant.DeleteFile(path)
    local stream = PlatDependant.OpenWrite(path)
    stream.Write(bytesArray, 0, bytesArray.Length)  --Lua assist checked flag
    stream.Dispose()  --Lua assist checked flag
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
