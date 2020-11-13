-- 球员模型构造器
-- 用来构造球员模型需要的数据
local PlayerModelConstructer = {}

local CardModel = require("data.CardModel")

local RaceColorType = {
    ["1"] = "White",
    ["A"] = "White",
    ["2"] = "AsiaLight",
    ["B"] = "AsiaLight",
    ["3"] = "AsiaDark",
    ["C"] = "AsiaDark",
    ["4"] = "LatinLight",
    ["D"] = "LatinLight",
    ["5"] = "LatinDark",
    ["E"] = "LatinDark",
    ["6"] = "Black",
}
local RaceBodyFaceMap = {
    White = {"BodyA",
        {"FaceTexture9_A"}
    },
    AsiaLight = {"BodyB", 
        {"FaceTexture1_B", "FaceTexture3_B", "FaceTexture4_B", "FaceTexture5_B", "FaceTexture6_B", "FaceTexture7_B", "FaceTexture8_B", "FaceTexture10_B", "FaceTexture17_B", "FaceTexture23_B", "FaceTexture26_B", "FaceTexture27_B",
     -- "FaceTextureBenzema_B", "FaceTextureCRonaldo_B", "FaceTextureMessi_B", "FaceTextureNeymar_B", "FaceTextureReus_B"
        }
    },
    AsiaDark = {"BodyC",
        {"FaceTexture13_C", "FaceTexture14_C", "FaceTexture18_C"}
    },
    LatinLight = {"BodyD",
        {"FaceTexture21_D", "FaceTexture22_D", "FaceTexture24_D", "FaceTexture25_D", "FaceTexture28_D"}
    },
    LatinDark = {"Body5",
        {"FaceTexture12_E", "FaceTexture15_E", "FaceTexture16_E"}
    },
    Black = {"Body6",
        {"FaceTexture2_F", "FaceTexture11_F", "FaceTexture19_F", "FaceTexture20_F"}
    },
}

local HairMeshList = {
    "Hair", "Hair1", "Hair2", "Hair3", "Hair4", "Hair5", "Hair6", "Hair7", "Hair8", "Hair9"
}
local HairTextureMap = {
    Hair = "HairTexture",
    Hair1 = "HairTexture1",
    Hair2 = "HairTexture",
    Hair3 = "HairTexture",
    Hair4 = "HairTexture2",
    Hair5 = "HairTexture2",
    Hair6 = "HairTexture2",
    Hair7 = "HairTexture2",
    Hair8 = "HairTexture3",
    Hair9 = "HairTexture4",
}

local FaceMeshList = {
    "Face1", "Face2", "FaceBenzema", "FaceCRonaldo"
}

-- 胖瘦体型
local Somatotype = {"Thin", "Normal", "Strong"}

local function randomSomatotype()
    return Somatotype[math.random(#Somatotype)]
end
local function randomFace()
    return FaceMeshList[math.random(#FaceMeshList)]
end
local function randomFaceTexture(race)
    local faceList = RaceBodyFaceMap[race][2]
    return faceList[math.random(#faceList)]
end
local function randomHair()
    local hairMesh = HairMeshList[math.random(#HairMeshList + 1)]
    return hairMesh
end
local function randomBeard()
    local beards = {"Beard1"}
    return beards[math.random(#beards + 1)]
end
local function randomHeight()
    return math.random(170, 190)
end

PlayerModelConstructer.constHairColor = {
    Black = {r = 18/255, g = 8/255, b = 3/255, a = 1},
}

local modleDataMap = {}

-- @param cid the card ModelID
function PlayerModelConstructer.CreatePlayerData(modelID)
    assert(type(modelID) == "string")

    if modleDataMap[modelID] == nil then
        modelID = CardModel[modelID] and modelID or "MArsenal01"
        local bodyTextureID = CardModel[modelID].bodyTextureID
        local faceID = CardModel[modelID].faceID
        local faceTextureID = CardModel[modelID].faceTextureID
        local isUseFaceHair = CardModel[modelID].isUseFaceHair
        local faceHairTexID = CardModel[modelID].faceHairTexID
        local bodyHair = CardModel[modelID].bodyHair
        local hairID = CardModel[modelID].hairID
        local hairTextureID = CardModel[modelID].hairTextureID
        local beardID = CardModel[modelID].beardID or ""
        local hairColor = CardModel[modelID].hairColor
        local height = math.clamp(CardModel[modelID].height, 160, 210)
        local somatotype = math.clamp(CardModel[modelID].somatotype, 1, 3)
        local kitName = CardModel[modelID].kitName

        local athleteData = {}
        athleteData.hairMesh = string.len(hairID) > 0 and hairID or randomHair()
        athleteData.hairTextrue = string.len(hairTextureID) > 0 and hairTextureID or HairTextureMap[athleteData.hairMesh]
        athleteData.faceMesh = string.len(faceID) > 0 and faceID or randomFace()
        local race = RaceColorType[bodyTextureID]
        athleteData.bodyTexture = "Body" .. bodyTextureID -- RaceBodyFaceMap[race][1]
        if string.len(faceTextureID) > 0 then
            athleteData.faceTexture = faceTextureID
        else 
            athleteData.faceTexture = randomFaceTexture(race)
        end
        
        athleteData.isUseFaceHair = (isUseFaceHair == 1)
        athleteData.bodyHairTexture = string.len(bodyHair) > 0 and bodyHair or nil
        athleteData.beardTexture = string.len(beardID) > 0 and beardID or nil
        athleteData.height = height
        local hairColorArray = string.split(hairColor, ",")
        athleteData.hairColor = table.nums(hairColorArray) == 4 and {r = tonumber(hairColorArray[1]), g = tonumber(hairColorArray[2]), b = tonumber(hairColorArray[3]), a = tonumber(hairColorArray[4])} or PlayerModelConstructer.constHairColor.Black
        athleteData.somato = Somatotype[somatotype]
        athleteData.faceHairTexID = (faceHairTexID and string.len(faceHairTexID) > 0) and faceHairTexID or nil

        -- PlayerModelConstructer.DealWithSomeSpecial(athleteData)

        -- dump(athleteData)

        modleDataMap[modelID] = athleteData
    end

    return modleDataMap[modelID]
end

-- TODO fix in the future
function PlayerModelConstructer.DealWithSomeSpecial(athleteData)
    if athleteData.faceMesh == "FaceCRonaldo" and athleteData.faceTexture == "FaceTextureCRonaldo_B" then
        athleteData.hairTextrue = "HairCRonaldo"
        athleteData.hairColor = {r = 1, g = 1, b = 1, a = 1}
        athleteData.bodyHairTexture = "BodyHairCRonaldo"
        athleteData.beardTexture = nil
        athleteData.isUseFaceHair = true
    end
end

function PlayerModelConstructer.GetRandomModelData()
    local athleteData = {}
    athleteData.hairMesh = randomHair()
    athleteData.hairTextrue = HairTextureMap[athleteData.hairMesh]
    athleteData.faceMesh = randomFace()
    local race = RaceColorType["3"]
    athleteData.bodyTexture = RaceBodyFaceMap[race][1]
    athleteData.faceTexture = randomFaceTexture(race)
    athleteData.isUseFaceHair = false
    athleteData.beardTexture = randomBeard()
    athleteData.height = randomHeight()
    athleteData.hairColor = PlayerModelConstructer.constHairColor.Black
    athleteData.somato = randomSomatotype()

    return athleteData
end

return PlayerModelConstructer
