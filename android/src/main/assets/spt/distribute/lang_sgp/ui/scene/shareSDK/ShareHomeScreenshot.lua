local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
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
local ImageConversion = UnityEngine.ImageConversion
local ImageConversion = UnityEngine.ImageConversion

local FormationPosition = {
    Normal = {X = 0, Y = 5},
    NoGuild = {X = 0, Y = 30},
}
local GameObjectHelper = require("ui.common.GameObjectHelper")

local ShareHomeScreenshot = class(unity.base)

function ShareHomeScreenshot:ctor()
    self.canvas = self.___ex.canvas
    self.screenshotCamera = self.___ex.screenshotCamera
    self.qrImage = self.___ex.qrImage
    self.createTime = self.___ex.createTime
    self.server = self.___ex.server
    self.playerName = self.___ex.playerName
    self.union = self.___ex.union
    self.formationView = self.___ex.formationView
    self.leagueObj = self.___ex.leagueObj
    self.leagueLevel = self.___ex.leagueLevel
    self.leaguePercent = self.___ex.leaguePercent
    self.ladderRank = self.___ex.ladderRank
    self.ladderHonor = self.___ex.ladderHonor
    self.arena1 = self.___ex.arena1
    self.arena2 = self.___ex.arena2
    self.arena3 = self.___ex.arena3
    self.arena4 = self.___ex.arena4
    self.leagueLine = self.___ex.leagueLine
    self.lineGroup = {}
    self.formationTrans = self.___ex.formationTrans
end

function ShareHomeScreenshot:InitView(shareInfo, initCallBack)
    for k, v in pairs(self.leagueLine) do
        table.insert(self.lineGroup, v)
    end
    table.sort(self.lineGroup, function(a, b) return a.gameObject.name < b.gameObject.name end)
    self.formationView:InitView(initCallBack)
    local time = os.date(lang.transstr("calendar_time"), shareInfo.c_t)
    self.createTime.text = time
    self.server.text = lang.trans("share_create", shareInfo.displayId .. " " .. shareInfo.sid)
    self.playerName.text = lang.trans("share_name", shareInfo.name)
    self.union.text = shareInfo.guild ~= nil and lang.trans("share_union", shareInfo.guild) or ""
    self.formationTrans.anchoredPosition = shareInfo.guild ~= nil and Vector2(FormationPosition.Normal.X, FormationPosition.Normal.Y) or Vector2(FormationPosition.NoGuild.X, FormationPosition.NoGuild.Y)
    self.ladderRank.text = tostring(shareInfo.ladderRank)
    self.ladderHonor.text = tostring(shareInfo.ladderSeasonScore)
    local leagueDiff = shareInfo.league.diff
    if leagueDiff > 0 then
        GameObjectHelper.FastSetActive(self.leagueObj, true)
        GameObjectHelper.FastSetActive(self.lineGroup[leagueDiff].gameObject, true)
        self.leagueLevel.text = lang.trans("league_leagueLevel", leagueDiff)
    else
        GameObjectHelper.FastSetActive(self.leagueObj, false)
        self.leagueLevel.text = lang.trans("share_leagueNone")
    end
    local rank = shareInfo.league.pos + 1
    local total = shareInfo.league.total
    local percent = rank > 0 and ((total - rank) * 100 / total) or 0
    percent = string.format("%d", percent)
    self.leaguePercent.text = lang.trans("share_league_percent", percent)
    self.arena1:InitView(shareInfo.arena.silver)
    self.arena2:InitView(shareInfo.arena.gold)
    self.arena3:InitView(shareInfo.arena.black)
    self.arena4:InitView(shareInfo.arena.platinum)   
end

function ShareHomeScreenshot:CreateScreenShot(toUrl, callBack)
    self:coroutine(function ()
        unity.waitForNextEndOfFrame()
        local width = 750
        local height = 2048

        local currentRenderTexture = RenderTexture.active
        local renderTexture = RenderTexture(width, height, 0)
        self.screenshotCamera.targetTexture = renderTexture
        RenderTexture.active = self.screenshotCamera.targetTexture
        self.screenshotCamera:Render()

        local texMain = Texture2D(width, height, TextureFormat.RGB24, false)
        texMain:ReadPixels(Rect(0, 0, width, height), 0, 0, false)
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
    end)
end

function ShareHomeScreenshot:GetImagePath()
    return self.imgPath
end

function ShareHomeScreenshot:DestroyScreenshotCamera()
    Object.Destroy(self.gameObject)
end

return ShareHomeScreenshot
