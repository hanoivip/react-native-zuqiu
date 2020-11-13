local UnityEngine = clr.UnityEngine
local Screen = UnityEngine.Screen
local Texture2D = UnityEngine.Texture2D
local Application = UnityEngine.Application
local PlatDependant = clr.Capstones.PlatExt.PlatDependant
local GameObject = UnityEngine.GameObject
local ResManager = clr.Capstones.UnityFramework.ResManager
local UnityQRCode = clr.QRCoder.UnityQRCode
local QRCodeGenerator = clr.QRCoder.QRCodeGenerator
local Color = UnityEngine.Color
local TextureFormat = UnityEngine.TextureFormat
local Rect = UnityEngine.Rect
local Object = UnityEngine.Object
local Camera = UnityEngine.Camera
local RenderTexture = UnityEngine.RenderTexture
local ShareConstants = require("ui.scene.shareSDK.ShareConstants")
local ShareSdkDialogCtrl = require("ui.controllers.shareSDK.ShareSdkDialogCtrl")
local PlayerInfoModel = require("ui.models.PlayerInfoModel")
local Mathf = clr.UnityEngine.Mathf

local ShareHelper = {}

local screenShotFileName = "share"
local qrSizeFactor = 0.2
local minTargetQRWidth = 177

function ShareHelper.Capture()
    local width = Screen.width
    local height = Screen.height
    local screenTex = Texture2D(width, height, TextureFormat.RGB24, false)
    screenTex:ReadPixels(Rect(0, 0, width, height), 0, 0, true)
    screenTex:Apply()
    local dir = Application.persistentDataPath .. "/" .. "screenshot/"
    local path = dir .. screenShotFileName .. ".png"
    local imagebytes = clr.array(screenTex.EncodeToPNG())
    PlatDependant.CreateFolder(dir)
    PlatDependant.DeleteFile(path)
    local stream = PlatDependant.OpenWrite(path)
    stream:Write(imagebytes, 0, imagebytes.Length)
    Object.Destroy(screenTex)
    stream:Dispose()
end

function ShareHelper.Capture(qrcodePath)
    if qrcodePath == nil or qrcodePath == "" then
        return nil
    end
    local width = Screen.width
    local height = Screen.height
    local screenTexMain = Texture2D(width, height, TextureFormat.RGB24, false)
    screenTexMain:ReadPixels(Rect(0, 0, width, height), 0, 0, true)
    screenTexMain:Apply()
    local screenTexQR = res.LoadRes(qrcodePath)
    local smallerEdge = width > height and height or width
    local targetQRWidth = (math.floor(smallerEdge * qrSizeFactor)/49)*49

    if targetQRWidth < screenTexQR.width then
        if targetQRWidth < minTargetQRWidth then
            targetQRWidth = minTargetQRWidth
        end
        local qrScaleFactor = targetQRWidth/screenTexQR.width
        screenTexQR = ScaleTextureBilinear(screenTexQR, qrScaleFactor)
    else
        targetQRWidth = screenTexQR.width
    end

    local qrX = 0
    local qrY = 0
    screenTexMain:SetPixels(qrX, qrY,targetQRWidth,targetQRWidth, screenTexQR:GetPixels(0,0,targetQRWidth,targetQRWidth))

    local dir = tostring(Application.persistentDataPath) .. "/" .. "screenshot/"
    local path = dir .. screenShotFileName .. ".png"

    local imagebytes = clr.array(screenTexMain.EncodeToPNG())
    PlatDependant.CreateFolder(dir)
    PlatDependant.DeleteFile(path)
    local stream = PlatDependant.OpenWrite(path)
    stream:Write(imagebytes, 0, imagebytes.Length)
    Object.Destroy(screenTexMain)
    Object.Destroy(screenTexQR)
    stream:Dispose()
    return path
end

function ShareHelper.CaptureWithQRText(screenText)
    if screenText == nil or screenText == "" then
        return nil
    end
    local width = Screen.width
    local height = Screen.height
    local screenTexMain = Texture2D(width, height, TextureFormat.RGB24, false)
    screenTexMain:ReadPixels(Rect(0, 0, width, height), 0, 0, true)
    screenTexMain:Apply()
    local smallerEdge = width > height and height or width
    local expectQRWidth = math.floor(smallerEdge * qrSizeFactor)
    if expectQRWidth < minTargetQRWidth then
        expectQRWidth = minTargetQRWidth
    end
    local qrCodeData = QRCodeGenerator():CreateQrCode(screenText, QRCodeGenerator.ECCLevel.Q)
    local screenTexQR = UnityQRCode(qrCodeData).GetGraphic(math.ceil(expectQRWidth /qrCodeData.ModuleMatrix.Count))
    local screenTexQRWidth = screenTexQR.width
    local qrX = 0
    local qrY = 0
    screenTexMain:SetPixels(qrX, qrY, screenTexQRWidth, screenTexQRWidth, screenTexQR:GetPixels(0, 0, screenTexQRWidth, screenTexQRWidth))

    local titleImageX = 0
    local titleImageY = height
    local titleImage = res.LoadRes("Assets/CapstonesRes/Game/UI/Scene/League/Images/TrueColor/MatchRewardTitle.png")
    screenTexMain:SetPixels(titleImageX, titleImageY, titleImage.width, titleImage.height, titleImage:GetPixels(0, 0, titleImage.width, titleImage.height))

    local dir = Application.persistentDataPath .. "/" .. "screenshot/"
    local path = dir .. screenShotFileName .. ".png"
    local imagebytes = clr.array(screenTexMain.EncodeToPNG())
    PlatDependant.CreateFolder(dir)
    PlatDependant.DeleteFile(path)
    local stream = PlatDependant.OpenWrite(path)
    stream:Write(imagebytes, 0, imagebytes.Length)
    Object.Destroy(screenTexMain)
    Object.Destroy(screenTexQR)
    stream:Dispose()
end

function ShareHelper.ScaleTextureBilinear(originalTexture, scaleFactor)
    local width = math.ceil(originalTexture.width * scaleFactor)
    local height =  math.ceil(originalTexture.height * scaleFactor)
    local newTexture = Texture2D(width,height)
    local scale = 1 / scaleFactor
    local maxX = originalTexture.width - 1
    local maxY = originalTexture.height - 1

    local originalColorArr = clr.table(originalTexture.GetPixels())
    local newColorArr = clr.table(Color[newTexture.width * newTexture.height])
    for i = 0, newTexture.height, 1 do
        for j = 0, newTexture.width, 1 do
            local targetX = (x+0.5) * scale - 0.5
            local targetY = (y+0.5) * scale - 0.5
            local x1 = Mathf.Min(maxX, math.floor(targetX))  --Lua assist checked flag
            local y1 = Mathf.Min(maxY, math.floor(targetY))  --Lua assist checked flag
            local x2 = Mathf.Min(maxX, x1 + 1)  --Lua assist checked flag
            local y2 = Mathf.Min(maxY, y1 + 1)  --Lua assist checked flag

            local u = targetX - x1
            local v = targetY - y1
            local w1 = (1 - u) * (1 - v)
            local w2 = u * (1 - v)
            local w3 = (1 - u) * v
            local w4 = u * v
            local color1 = originalColorArr[x1 + y1 * originalTexture.width]
            local color2 = originalColorArr[x2 + y1 * originalTexture.width]
            local color3 = originalColorArr[x1 + y2 * originalTexture.width]
            local color4 = originalColorArr[x2 + y2 * originalTexture.width]
            local color = Color(math.clamp(color1.r * w1 + color2.r * w2 + color3.r * w3 + color4.r * w4),
                math.clamp(color1.g * w1 + color2.g * w2 + color3.g * w3 + color4.g * w4),
                math.clamp(color1.b * w1 + color2.b * w2 + color3.b * w3 + color4.b * w4),
                math.clamp(color1.a * w1 + color2.a * w2 + color3.a * w3 + color4.a * w4)
            )
            newColorArr[x + y * newTexture.width] = color
        end
    end

    newTexture:SetPixels(clr.array(newColorArr))
    return newTexture
end

function ShareHelper.CaptrueCamera(shareType, playerName)
    local shareObj, shareSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ShareSDK/ShareSDK.prefab")
    ShareHelper.shareSpt = shareSpt
    ShareHelper.shareType = shareType
    local width = Screen.width
    local height = Screen.height
    local screenTex = Texture2D(width, height, TextureFormat.RGB24, false)
    screenTex:ReadPixels(Rect(0, 0, width, height), 0, 0, true)
    screenTex:Apply()
    local coldUpdateURL = ShareHelper.GetColdUpdateURL()

    local longText, longText2, shortText = "", "", ""
    if shareType and shareType ~= "" then 
        longText = lang.trans(ShareConstants.LongText[shareType])
        longText2 = lang.trans(ShareConstants.LongText[shareType], playerName)
        shortText = lang.trans(ShareConstants.ShortText[shareType])
    end
    local longText = playerName == nil and longText or longText2
    shareSpt:CreateScreenShot(screenTex, coldUpdateURL, longText, shortText, function() ShareHelper.ScreenShotCallBack() end)
end

function ShareHelper.HomeCaptrueCamera(shareType)
    clr.coroutine(function()
        local respone = req.playerShareInfo()
        if api.success(respone) then
            local data = respone.val
            ShareHelper.HomeCaptrueFunc(data, shareType)
        end
    end)
end

function ShareHelper.HomeCaptrueFunc(data, shareType)
    local shareObj, shareSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ShareSDK/ShareSDK_Home.prefab")
    ShareHelper.shareSpt = shareSpt
    ShareHelper.shareType = shareType
    shareSpt:InitView(data, function() ShareHelper.WaitForScreenShot(shareSpt, shareType, shareObj) end)
end

function ShareHelper.DiscussCaptrueCamera(reply, cid)
    clr.coroutine(function()
        local respone = req.playerShareInfo()
        if api.success(respone) then
            local data = respone.val
            ShareHelper.DiscussCaptrueFunc(reply, cid)
        end
    end)
end

function ShareHelper.DiscussCaptrueFunc(reply, cid)
    local shareObj, shareSpt = res.Instantiate("Assets/CapstonesRes/Game/UI/Scene/ShareSDK/ShareDiscussSDK.prefab")
    ShareHelper.shareSpt = shareSpt
    ShareHelper.shareType = ShareConstants.Type.HomeMain
    shareSpt:InitView(reply, cid, function() ShareHelper.WaitForScreenShot() end)
end

function ShareHelper.WaitForScreenShot()
    local coldUpdateURL = ShareHelper.GetColdUpdateURL()
    ShareHelper.shareSpt:CreateScreenShot(coldUpdateURL, function() ShareHelper.ScreenShotCallBack() end)
end

function ShareHelper.ScreenShotCallBack()
    local imgPath = ShareHelper.shareSpt:GetImagePath()
    EventSystem.SendEvent("ShareRenderComplete")
    ShareHelper.shareSpt:DestroyScreenshotCamera()
    local title = lang.trans(ShareConstants.Title)
    local text = lang.trans(ShareConstants.EditableText[ShareHelper.shareType])   

    ShareSdkDialogCtrl.new(title, text, imgPath)
end

local function GetCurrentTime()
    local serverZone = 28800
    local function get_timezone()
        local now = os.time()
        return os.difftime(now, os.time(os.date("!*t", now)))
    end
    local localTimeZone = get_timezone()
    return os.time() - (localTimeZone - serverZone)
end

function ShareHelper.GetColdUpdateURL()
    local playerInfoModel = PlayerInfoModel.new()
    local bichannel = luaevt.trig("SDK_GetChannel")
    local serverID = cache.getCurrentServer().id
    local pid = playerInfoModel:GetID()
    local channel = cache.getChannel()
    local platform = clr.plat
    bichannel = bichannel and tostring(bichannel) or ""
    local coldUpdateURL = cache.getCurrentServer().url .. "external/share?bichannel=" .. tostring(bichannel) .. "&pid=" .. tostring(pid) .. "&channel=" .. tostring(channel) .. "&serverID=" .. tostring(serverID) .. "&platform=" .. tostring(platform) .. "&time=" .. tostring(GetCurrentTime())
    return coldUpdateURL
end

function ShareHelper.encodeURI(s)
    s = string.gsub(s, "([^%w%.%- ])", function(c) return string.format("%%%02X", string.byte(c)) end)
    return string.gsub(s, " ", "+")
end

return ShareHelper
