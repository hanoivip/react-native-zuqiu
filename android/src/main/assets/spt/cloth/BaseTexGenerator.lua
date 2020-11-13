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

local ClothUtils = require("cloth.ClothUtils")
local TeamLogoCtrl = require("ui.controllers.common.TeamLogoCtrl")
local ShirtMask = require("data.ShirtMask")

-- 判断mask遮罩是否为大辅色
local function IsMaskBigAssistColor(mask)
    assert(type(mask) == "string")
    local maskTable = ShirtMask[mask]
    return maskTable and (tonumber(maskTable.assistColour) == 1) or false
end

local function GetChestAdTexturePath(chestAd, clothBaseParas, isRealMadrid)
    -- 所有队服都使用通用的胸前广告(以后可能改回)
    -- if (not isRealMadrid) or (not chestAd) then
    if true then
        local hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(clothBaseParas.maskRedChannel))
        local needBlackLogo = false
        if saturation1 <= 0.3 and value1 >= 0.6 then
            -- white
            needBlackLogo = true
        end

        local isBigAssistColor = IsMaskBigAssistColor(clothBaseParas.mask)
        if isBigAssistColor then
            hue1, saturation1, value1 = ClothUtils.getHsvFromRgb(ClothUtils.parseColorString(clothBaseParas.maskGreenChannel))
            if saturation1 <= 0.3 and value1 >= 0.6 then
                needBlackLogo = true
            end
        end

        chestAd = needBlackLogo and "LogoBlack" or "LogoWhite"
    end

    return "Assets/CapstonesRes/Game/ClothMaker/Textures/ChestAd/" .. chestAd .. "/" .. chestAd .. ".png"
end

local BaseTexGenerator = class(unity.base)

function BaseTexGenerator:ctor()
    self.baseTex = self.___ex.baseTex
    self.badge = self.___ex.badge
    self.image = self.___ex.image
    self.chestAd = self.___ex.chestAd
    self.width = 512
    self.height = 512
end

function BaseTexGenerator:start()
    -- self:generateBaseTexture({
    --     maskRedChannel = "1,0,0,1",
    --     maskGreenChannel = "0,1,0,1",
    --     maskBlueChannel = "0,0,1,1",
    --     mask = "Mask_01",
    --     logo = {
    --         boardId = "Board2",
    --         colorId = "2",
    --         frameId = "Frame1",
    --         ribbonId = "Ribbon2",
    --         figureId = "Figure1",
    --     }
    -- })
end

local tmpPosX = 0

-- 生成球衣的基础纹理
-- 注意: 内含coroutine调用,本帧末尾才能获取到纹理,所以纹理通过回调函数onComplete传回
-- 内存耗费: 默认情况下生成的512x512纹理耗费1MB内存
-- @param clothBaseParas: table
--        {
--            maskRedChannel = "1,0,0,1",
--            maskGreenChannel = "0,1,0,1",
--            maskBlueChannel = "0,0,1,1",
--            mask = "Mask_01",
--            logo = {
--                boardId = "Board2",
--                colorId = "2",
--                frameId = "Frame1",
--                ribbonId = "Ribbon2",
--                figureId = "Figure1",
--            }
--        }  
-- @param onComplete: function(Texture2D)
function BaseTexGenerator.GenerateBaseTexture(clothBaseParas, onComplete)
    local baseTexGenerator = Object.Instantiate(res.LoadRes("Assets/CapstonesRes/Game/ClothMaker/BaseTexGenerator.prefab"))
    baseTexGenerator.transform.position = Vector3(tmpPosX, 10000, 10000)
    tmpPosX = tmpPosX + 1000
    local script = res.GetLuaScript(baseTexGenerator)
    script:generateBaseTexture(clothBaseParas, function(texture)
        if onComplete and type(onComplete) == "function" then
            onComplete(texture)
        end
        Object.Destroy(baseTexGenerator)
    end)
end

function BaseTexGenerator:generateBaseTexture(clothBaseParas, onComplete)
    self.baseTex.material = Material(Shader.Find("Custom/ClothBase"))
    local baseTexMaterial = self.baseTex.material

    baseTexMaterial:SetColor("_MaskRedChannel", ClothUtils.parseColorString(clothBaseParas.maskRedChannel))
    baseTexMaterial:SetColor("_MaskGreenChannel", ClothUtils.parseColorString(clothBaseParas.maskGreenChannel))
    baseTexMaterial:SetColor("_MaskBlueChannel", ClothUtils.parseColorString(clothBaseParas.maskBlueChannel))

    local mask = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/ClothMask/' .. clothBaseParas.mask .. '/' .. clothBaseParas.mask .. '.jpg', UnityEngine.Texture2D)
    if mask == nil then mask = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/ClothMask/Mask_01/Mask_01.jpg', UnityEngine.Texture2D) end
    baseTexMaterial:SetTexture("_Mask", mask)

    baseTexMaterial:SetTexture("_Multiply", clr.null)
    baseTexMaterial:SetTexture("_LinearDodge", clr.null)
    -- baseTexMaterial:SetTexture("_Multiply", res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/ClothMultiply/kit_shading_multiply.jpg', UnityEngine.Texture2D))
    -- baseTexMaterial:SetTexture("_LinearDodge", res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/ClothLinearDodge/kit_shading_lineardodge.jpg', UnityEngine.Texture2D))

    if clothBaseParas.logo then
        -- TODO: logo 不该和clothBaseParas放在一起
        TeamLogoCtrl.BuildTeamLogo(self.badge, clothBaseParas.logo)
    end

    local isRealMadrid = false
    if clothBaseParas.logo and clothBaseParas.logo == "RealmadridPlayer" then
        isRealMadrid = true
    end

    local chestAdSprite = res.LoadRes(GetChestAdTexturePath(clothBaseParas.chestAd, clothBaseParas, isRealMadrid))
    self.chestAd.sprite = chestAdSprite

    self:coroutine(function()
        coroutine.yield(WaitForEndOfFrame())

        local tempRT = RenderTexture.GetTemporary(self.width, self.height, 24, RenderTextureFormat.Default, RenderTextureReadWrite.Default, 1)
        tempRT.name = "BaseTexGenerator RenderTexture"
        local currentRT = RenderTexture.active
        self.___ex.camera.targetTexture = tempRT
        self.___ex.camera.aspectRatio = 1
        RenderTexture.active = tempRT
        
        self.___ex.camera:Render()

        local width = self.width
        local height = self.height

        -- 此处 Android 系统只允许两种 TextureFormat: RGB24 或 ARGB32, 因此用了内存占用较小的 RGB24
        local texture = Texture2D(width, height, TextureFormat.RGB24, true)
        texture.name = "ClothBaseTexture(AutoGenerated)"
        texture:ReadPixels(Rect(0, 0, width, height), 0, 0)

        -- C# 函数定义: public void Apply(bool updateMipmaps = true, bool makeNoLongerReadable = false);
        -- 需要设置 makeNoLongerReadable = true, 此参数让 Unity 在 Apply 上传纹理到 GPU 之后释放内存
        texture:Apply(true, true)

        RenderTexture.active = currentRT

        RenderTexture.ReleaseTemporary(tempRT)

        self.image.texture = texture

        if onComplete and type(onComplete) == "function" then
            onComplete(texture)
        end
    end)
end

return BaseTexGenerator
