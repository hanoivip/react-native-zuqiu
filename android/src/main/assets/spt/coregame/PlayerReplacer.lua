local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Color = UnityEngine.Color
local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

local WeatherConstParams = require("coregame.WeatherConstParams")
local PlayerModelConstructer = require("coregame.PlayerModelConstructer")

local QualitySetting = require("coregame.QualitySetting")

local PlayerReplacer = {}

local faceRoot = "Assets/CapstonesRes/Game/Models/Players/Face/"

local function loadFace(faceId, forceHighQuality)
    local prefabPath = faceRoot .. faceId .. "/" .. faceId .. ((forceHighQuality or (QualitySetting.GetLevel() or "low") == "high") and "_LOD1.prefab" or "_LOD2.prefab")
    local prefab = res.LoadRes(prefabPath)
    return Object.Instantiate(prefab)
end

local faceTextureRoot = "Assets/CapstonesRes/Game/Models/Players/Face/Textures/"

local function loadFaceTexture(faceTextureId)
    local texturePath = faceTextureRoot .. faceTextureId .. "/" .. faceTextureId .. ".jpg"
    return res.LoadRes(texturePath)
end

local function loadFaceHairTexture(isUseFaceHair, faceHairTextureId)
    if faceHairTextureId then
        local texturePath = faceTextureRoot .. string.gsub(faceHairTextureId, "Hair", "Texture") .. "/" .. faceHairTextureId .. ".png"
        return res.LoadRes(texturePath)
    end
    if isUseFaceHair then
       return nil
    else
        return res.LoadRes("Assets/CapstonesRes/Game/Models/Players/Face/Textures/FaceHair.png")
    end
end

local hairRoot = "Assets/CapstonesRes/Game/Models/Players/Hair/"

local function loadHair(hairId)
    if hairId == "Hairless" or hairId == "Supershort" or hairId == "null" then
        return nil
    end

    local prefabPath = hairRoot .. hairId .. "/" .. hairId .. ".prefab"
    local prefab = res.LoadRes(prefabPath)
    if prefab == nil or prefab == clr.null then
        dump(prefabPath)
    else
        return Object.Instantiate(prefab)
    end
end

local hairTextureRoot = "Assets/CapstonesRes/Game/Models/Players/Hair/Textures/"

local function loadHairTexture(hairTextureId)
    if hairTextureId == "null" then
        -- 光头
        return
    end

    local texturePath = hairTextureRoot .. hairTextureId .. "/" .. hairTextureId .. ".png"
    return res.LoadRes(texturePath)
end

local beardRoot = "Assets/CapstonesRes/Game/Models/Players/Beard/"

local function loadBeard(beardId)
    local texturePath = beardRoot .. beardId .. "/" .. beardId .. ".png"
    return res.LoadRes(texturePath)
end

local bodyTextureRoot = "Assets/CapstonesRes/Game/Models/Players/Body/Textures/"

local function loadBodyTexture(bodyTextureId)
    local texturePath = bodyTextureRoot .. bodyTextureId .. "/" .. bodyTextureId .. ".jpg"
    return res.LoadRes(texturePath)
end

local bodyHairTextureRoot = "Assets/CapstonesRes/Game/Models/Players/Body/Textures/BodyHair/"

local function loadBodyHairTexture(bodyHairTextureId)
    local texturePath = "Assets/CapstonesRes/Game/Models/Players/Body/Textures/BodyHair.png"
    if bodyHairTextureId then
        if bodyHairTextureId == "null" then
            -- 光头的情况
            return
        end
        texturePath = bodyHairTextureRoot .. bodyHairTextureId .. "/" .. bodyHairTextureId .. ".png"
    end

    return res.LoadRes(texturePath)
end

local somatotypeRoot = "Assets/CapstonesRes/Game/Models/Players/Body/"

local function loadSomatotype(somatotype, forceHighQuality)
    local prefabPath = somatotypeRoot .. somatotype .. "/Body_" .. somatotype .. ((forceHighQuality or (QualitySetting.GetLevel() or "low") == "high") and "_LOD1.prefab" or "_LOD2.prefab")
    return res.LoadRes(prefabPath)
end

function PlayerReplacer.replaceMesh(athlete, faceId, faceTextureId, isUseFaceHair, hairId, hairTextureId, beardId, hairColor, height, bodyTextureId, bodyHairTextureId, somatotype, faceHairTexID, forceHighQuality)
    faceId = faceId or "Face1"
    faceTextureId = faceTextureId or "FaceTexture1_B"
    hairColor = hairColor or PlayerModelConstructer.constHairColor.Black
    --hairColor = PlayerModelConstructer.constHairColor.Black
    height = height or 180
    bodyTextureId = bodyTextureId or "Body1"

    local facePrefab = loadFace(faceId, forceHighQuality)
    local faceTexture = loadFaceTexture(faceTextureId)
    local faceHairTexture = loadFaceHairTexture(isUseFaceHair,faceHairTexID)
    local hairPrefab = hairId and loadHair(hairId) or nil
    local hairTexture = hairTextureId and loadHairTexture(hairTextureId) or nil
    local beard = beardId and loadBeard(beardId) or nil
    local bodyTexture = loadBodyTexture(bodyTextureId)
    local bodyHairTexure = loadBodyHairTexture(bodyHairTextureId)
    local somatotypePrefab = loadSomatotype(somatotype and somatotype or "Normal", forceHighQuality)
    local isHairless = (hairId == "Hairless") and true or false
    local qualityLevel=QualitySetting.GetLevel() or "low"
    -- 调用 C# 的函数替换 mesh
    athlete:Replace(facePrefab, faceTexture, faceHairTexture, hairPrefab, hairTexture, Color(hairColor.r, hairColor.g, hairColor.b, hairColor.a), beard, somatotypePrefab, height, bodyTexture, bodyHairTexure, isHairless, qualityLevel)
end

function PlayerReplacer.removeHair(athlete, height)
    -- 调用 C# 的函数替换 mesh
    athlete:Replace(nil, nil, nil, nil, height, nil, false)
end

function PlayerReplacer.replaceKit(kitFontTexture, kitFont, kit, number, athlete, backNumColor, trouNumColor)
    local multiply = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/ClothMultiply/kit_shading_multiply.jpg')
    local normal = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/Cloth_n2.jpg')
    local specular = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/Cloth_s.jpg')
    local illuminColor = Color(WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[1], WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[2], WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[3], WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[4])
    athlete:ReplaceKitIllumin(kitFontTexture, kitFont, kit, tonumber(number), multiply, normal, specular, backNumColor, trouNumColor, illuminColor)
end

PlayerReplacer.PrintingStyle = {
    NormalStyle = "NormalStyle",
    BayernStyle = "BayernStyle",
    RealMadridStyle = "RealMadridStyle",
    BarcelonaStyle = "BarcelonaStyle"
}

PlayerReplacer.NameNumPos = {
    NormalStyle = {
        backNumPos = Vector3(0.215, 0.705, 0.273),
        trouNumPos = Vector3(0.84, 0.08, 0.05),
        numFramePos = Vector2(0, 0.73),
    },
    BayernStyle = {
        backNumPos = Vector3(0.215, 0.7665, 0.273),
        trouNumPos = Vector3(0.84, 0.08, 0),
        numFramePos = Vector2(0.0672, 0.73),
    },
    RealMadridStyle = {
        backNumPos = Vector3(0.215, 0.705, 0.273),
        trouNumPos = Vector3(0.84, 0.08, 0.05),
        numFramePos = Vector2(0, 0.73),
    },
    BarcelonaStyle = {
        backNumPos = Vector3(0.215, 0.705, 0.273),
        trouNumPos = Vector3(0.84, 0.08, 0.05),
        numFramePos = Vector2(0, 0.73)
    }
}

local saveIlluminColor = Color(1, 1, 1, 1)
function PlayerReplacer.replaceKitNew(athlete, kitTexure, nameNumTexture, nameUVwh, backNumColor, trouNumColor, printingStyle)
    printingStyle = printingStyle or PlayerReplacer.PrintingStyle.NormalStyle
    local nameNumPosTable = PlayerReplacer.NameNumPos[printingStyle]

    local multiply = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/ClothMultiply/kit_shading_multiply.jpg')
    local normal = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/Normalmap.tga')
    local illuminColor = Color(WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[1], WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[2], WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[3], WeatherConstParams[WeatherConstParams.currentWeather].IlluminColor[4])
    saveIlluminColor = illuminColor
    local detailmap = nil

    local qualityLevel = QualitySetting.GetLevel() or "low"
    if(qualityLevel == "high" or qualityLevel == "middle") then
        detailmap = res.LoadRes('Assets/CapstonesRes/Game/ClothMaker/Textures/Detailmap.jpg')
    end
    athlete:ReplaceKitNewIllumin(kitTexure, nameNumTexture, nameUVwh, multiply, normal, backNumColor, trouNumColor, illuminColor, nameNumPosTable.backNumPos, nameNumPosTable.trouNumPos, nameNumPosTable.numFramePos, detailmap, qualityLevel)
end

function PlayerReplacer.SwitchMaterialQuality(athlete, qualityLevel)
    athlete:SwitchMaterialQuality(qualityLevel, saveIlluminColor)
end

if ___CONFIG__TEST_RUNNER then
    PlayerReplacer.ExportFunc = {
        LoadFace = loadFace,
        LoadFaceTexture = loadFaceTexture,
        LoadBodyHairTexture = loadBodyHairTexture,
        LoadHair = loadHair,
        LoadHairTexture = loadHairTexture,
        LoadSomatotype = loadSomatotype,
    }
end

return PlayerReplacer
