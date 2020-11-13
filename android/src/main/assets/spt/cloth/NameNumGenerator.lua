local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local Material = UnityEngine.Material
local Shader = UnityEngine.Shader
local UI = UnityEngine.UI
local Image = UI.Image
local Camera = UnityEngine.Camera
local RenderTexture = UnityEngine.RenderTexture
local RenderTextureFormat = UnityEngine.RenderTextureFormat
local RenderTextureReadWrite = UnityEngine.RenderTextureReadWrite
local Texture2D = UnityEngine.Texture2D
local TextureFormat = UnityEngine.TextureFormat
local Rect = UnityEngine.Rect
local Color = UnityEngine.Color
local WaitForEndOfFrame = UnityEngine.WaitForEndOfFrame
local Vector3 = UnityEngine.Vector3
local Vector4 = UnityEngine.Vector4
local Text = UI.Text
local SkinnedMeshRenderer = UnityEngine.SkinnedMeshRenderer
local TextAsset = UnityEngine.TextAsset

local PlayerReplacer = require("coregame.PlayerReplacer")
local BaseTexGenerator = require("cloth.BaseTexGenerator")
local ClothUtils = require("cloth.ClothUtils")

local NameNumGenerator = class(unity.base)

NameNumGenerator.NameNumType = {
    NameTop = 1,
    NameBottom = 2,
}

local gridLine = 4
local gridColumn = 5

function NameNumGenerator:ctor()
    self.rendererCamera = self.___ex.camera
    self.image = self.___ex.image
    self.width = 512
    self.height = 512

    self.texturePanel = self.___ex.texturePanel
    self.templateCell = self.___ex.templateCell
    self.templateCell2 = self.___ex.templateCell2
end

function NameNumGenerator:start()
    --[[
    local playerParas = {
        mask = "Mask_31",
        maskRedChannel = "0.067, 0.102, 0.169, 1.000",
        maskGreenChannel = "0.449, 0.013, 0.183, 1.000",
        maskBlueChannel = "0.067, 0.102, 0.169, 1.000",
        backNumColor = "1.000, 1.000, 1.000, 1.000",
        trouNumColor = "1.000, 1.000, 1.000, 1.000",
        chestAd = "emirateswhite",
    }

    self:generateBaseTexture(NameNumGenerator.NameNumType.NameBottom,
    {
        {"JFWIOETJAS"},
        {"490YJFMDB"},
        {"EW904PYKMBN"},
        {"DFHIKWETRYH5EY"},
        {"E45Y9IPOMHSDF"},
        {"EDRPOHYUIKERY"},
        {"SDFOHYIPUER"},
        {"DSFPOGHJPSDROKH"},
        {"SDFHJSDROPKH"},
        {"SDGASDJIOGJASDG"},
        {"JFWIOETJAS"},
        {"490YJFMDB"},
        {"EW904PYKMBN"},
        {"DFHIKWETRYH5EY"},
        {"E45Y9IPOMHSDF"},
        {"SCHWEINSTEIGER"},
        {"REUS"},
        {"MULLER"},
        {"J. Rodríguez"},
        {"SDGASDJIOGJASDG"},
    },
    function(nameNumTexture)
        -- BaseTexGenerator.GenerateBaseTexture(playerParas, function(texture)
        --     local backNumColor = ClothUtils.parseColorString(playerParas.backNumColor)
        --     local trouNumColor = ClothUtils.parseColorString(playerParas.trouNumColor)
        --     -- test
        --     local index = 16
        --     PlayerReplacer.replaceKitNew(self.___ex.testPlayerNew, texture, nameNumTexture, NameNumGenerator.GetUVWH(index), backNumColor, trouNumColor, PlayerReplacer.PrintingStyle.BayernStyle)
        -- end)

        -- bayern test
        local texture = res.LoadRes("Assets/CapstonesRes/Game/ClothMaker/SpecificCloth/BayernHome.jpg", UnityEngine.Texture2D)
        local backNumColor = ClothUtils.parseColorString(playerParas.backNumColor)
        local trouNumColor = ClothUtils.parseColorString(playerParas.trouNumColor)
        -- test
        local index = 16
        PlayerReplacer.replaceKitNew(self.___ex.testPlayerNew, texture, nameNumTexture, NameNumGenerator.GetUVWH(index), backNumColor, trouNumColor, PlayerReplacer.PrintingStyle.BayernStyle)
    end)

    BaseTexGenerator.GenerateBaseTexture(playerParas, function(texture)
        local backNumColor = ClothUtils.parseColorString(playerParas.backNumColor)
        local trouNumColor = ClothUtils.parseColorString(playerParas.trouNumColor)
        PlayerReplacer.replaceKit(self.___ex.kitFontTexture, self.___ex.kitFont, texture, 16, self.___ex.testPlayer, backNumColor, trouNumColor)
    end)
    --]]
end

-- @return Vector4
function NameNumGenerator.GetUVWH(index)
    local line = math.ceil(index / gridColumn)
    local column = math.fmod(index, gridColumn)
    local w = 1 / gridColumn
    local h = 1 / gridLine
    local u = (column - 1) * w
    local v = (line - 1) * h

    return Vector4(u, v, w, h)
end

local tmpPosX = 0

-- 生成球衣的基础纹理
-- 注意: 内含coroutine调用,本帧末尾才能获取到纹理,所以纹理通过回调函数onComplete传回
-- 内存耗费: 默认情况下生成的512x512纹理耗费1MB内存
-- @param nameNumList: table
-- {
--     {"Benzema", "10"}, 
--     {"Messi", "11"}, 
-- } 
-- @param onComplete: function(Texture2D)
function NameNumGenerator.GenerateBaseTexture(nameNumType, nameNumList, onComplete)
    nameNumType = nameNumType or NameNumGenerator.NameNumType.NameTop
    local NameNumGenerator = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/ClothMaker/NameNumGeneratorEx.prefab"))
    NameNumGenerator.transform.position = Vector3(tmpPosX, -10000, -10000)
    tmpPosX = tmpPosX + 1000
    local script = res.GetLuaScript(NameNumGenerator)
    script:generateBaseTexture(nameNumType, nameNumList, function(texture)
        if onComplete and type(onComplete) == "function" then
            onComplete(texture)
        end
        Object.Destroy(NameNumGenerator)
    end)
end

-- 每个cell的宽width = 102.4，高height = 128
-- 划分512x512的图为4x5=20的格子
function NameNumGenerator:generateBaseTexture(nameNumType, nameNumList, onComplete)
    for i, nameNum in ipairs(nameNumList) do
        local tmpCellObject
        if nameNumType == NameNumGenerator.NameNumType.NameTop then
            tmpCellObject = Object.Instantiate(self.templateCell)
        elseif nameNumType == NameNumGenerator.NameNumType.NameBottom then
            tmpCellObject = Object.Instantiate(self.templateCell2)            
        end
        tmpCellObject.transform:SetParent(self.texturePanel, false)
        local nameText = tmpCellObject.transform:FindChild("Name"):GetComponent(Text)
        local numText = tmpCellObject.transform:FindChild("Num"):GetComponent(Text)
        -- 在动态字体中请求要使用的字(避免在使用文字的时候出现字体破碎的情况)
        if self.___ex.font.material.mainTexture.height >= 2048 and self.___ex.font.material.mainTexture.width >= 2048 then
        else
            self.___ex.font:RequestCharactersInTexture(nameNum[1], 64)
        end
        nameText.text = nameNum[1]
        numText.text = nameNum[2] and tostring(nameNum[2]) or tostring(i)
    end

    self:coroutine(function()
        coroutine.yield(WaitForEndOfFrame())

        local tempRT = RenderTexture.GetTemporary(self.width, self.height, 24, RenderTextureFormat.Default, RenderTextureReadWrite.Default, 1)
        tempRT.name = "NameNumGenerator RenderTexture"
        local currentRT = RenderTexture.active
        self.rendererCamera.targetTexture = tempRT
        self.rendererCamera.aspectRatio = 1
        RenderTexture.active = tempRT
        
        self.rendererCamera:Render()

        local width = self.width
        local height = self.height

        -- 此处 Android 系统只允许两种 TextureFormat: RGB24 或 ARGB32, 背号与名字显示需要是透明贴图，因此用了RGBA32
        local texture = Texture2D(width, height, TextureFormat.ARGB32, false)
        texture.name = "ClothBaseTextureEx(AutoGenerated)"
        texture:ReadPixels(Rect(0, 0, width, height), 0, 0)

        -- C# 函数定义: public void Apply(bool updateMipmaps = true, bool makeNoLongerReadable = false);
        -- 需要设置 makeNoLongerReadable = true, 此参数让 Unity 在 Apply 上传纹理到 GPU 之后释放内存
        texture:Apply(false, true)

        RenderTexture.active = currentRT

        RenderTexture.ReleaseTemporary(tempRT)

        self.image.texture = texture

        if onComplete and type(onComplete) == "function" then
            onComplete(texture)
        end
    end)
end

return NameNumGenerator
