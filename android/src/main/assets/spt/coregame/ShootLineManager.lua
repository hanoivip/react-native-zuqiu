local ShootLineManager = {}
local ShootLine3D = clr.ShootLine3D
local UnityEngine = clr.UnityEngine
local Vector3 = UnityEngine.Vector3
local GameObject = UnityEngine.GameObject
local MeshRenderer = UnityEngine.MeshRenderer
local Time = UnityEngine.Time
local Color = UnityEngine.Color

local lineType = {"run", "pass", "skillPass"}
local lineMaterialPathMap = {
    run = "Assets/CapstonesRes/Game/Models/ShootLine/Materials/LineRun.mat",
    pass = "Assets/CapstonesRes/Game/Models/ShootLine/Materials/LinePass.mat",
    skillPass = "Assets/CapstonesRes/Game/Models/ShootLine/Materials/LineSkillPass.mat",
}
local lineWidthMap = {
    run = 4,
    pass = 4,
    skillPass = 16
}

function ShootLineManager.CreateLine(posA, posB, lineType, isArc)
    local segments = isArc and 500 or 1
    local material = res.LoadRes(lineMaterialPathMap[lineType])
    local line = ShootLine3D.CreateLine(posA, posB, segments, material, lineWidthMap[lineType])
    return line
end

function ShootLineManager.DestroyLine(line)
    ShootLine3D.DestoryLine(line)
end

local lineTemplatePrefabMap = {
    run = "Assets/CapstonesRes/Game/Models/ShootLine/Prefabs/LineRun.prefab",
    pass = "Assets/CapstonesRes/Game/Models/ShootLine/Prefabs/LinePass.prefab",
    skillPass = "Assets/CapstonesRes/Game/Models/ShootLine/Prefabs/LineSkillPass.prefab"
}

local uvAnimationIgnoreTimeScaleMap = {
    run = false,
    pass = true,
    skillPass = true,
}

local alphaSegmentsMap = {
    run = {1, 1},
    pass = {0, 0.5, 1, 1},
    skillPass = {0, 1},
}

local colorSegmentsMap = {
    run = {
        Color(1, 1, 1, 0),
        Color(1, 1, 160/255, 0.5),
        Color(1, 1, 80/255, 1),
        Color(246/255, 255/255, 0, 1)
    },
    pass = {
        Color(1, 1, 1, 0),
        Color(1, 1, 160/255, 0.5),
        Color(1, 1, 80/255, 1),
        Color(246/255, 255/255, 0, 1)
    },
    skillPass = {
        Color(91/255, 254/255, 221/255, 0),
        Color(116/255, 250/255, 230/255, 0.5),
        Color(141/255, 250/255, 240/255, 1),
        Color(164/255, 243/255, 255/255, 1)
    }
}

function ShootLineManager.CreateLineMesh(posA, posB, posC, posD, lineType, isArc)
    assert(posA and posD and lineType)
    local isArcPass = false
    local resolution = 30
    local lineObj = res.Instantiate(lineTemplatePrefabMap[lineType])
    if posB == nil and posC == nil then
        local centerPos = Vector3.Lerp(posA, posD, 0.67)
        -- 低平传球线贴地
        if (lineType == "pass" or lineType == "skillPass") and not isArc then
            resolution = 30
            centerPos.y = 0
            -- 稍微缩短点距离防止箭头被遮挡住
            posD = posD - (posD - posA).normalized * 0.3
        elseif lineType == "run" then
            centerPos.y = 0
        else
            centerPos.y = math.max(Vector3.Distance(posA, posD) / 8, 3)
            isArcPass = true
        end
        posA = posA + Vector3.up * 0.05
        posB = centerPos + Vector3.up * 0.05
    end
    local posTable = {posA, posB, posB, posD}
    ShootLine3D.CreateLineMesh(lineObj.transform, clr.array(posTable, Vector3), resolution, clr.array(colorSegmentsMap[lineType], Color), isArcPass)

    if uvAnimationIgnoreTimeScaleMap[lineType] then
        local mat = lineObj:GetComponent(MeshRenderer).material
        mat:SetFloat("_IsTimeScale", 1)
    end

    return lineObj
end

return ShootLineManager
