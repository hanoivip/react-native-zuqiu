local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local GameObject = UnityEngine.GameObject
local Transform = UnityEngine.Transform
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
local Animator = UnityEngine.Animator
local WaitForSeconds = UnityEngine.WaitForSeconds
local Vector3 = UnityEngine.Vector3
local MeshRenderer = UnityEngine.MeshRenderer
local Color = UnityEngine.Color
local GameObjectHelper = require("ui.common.GameObjectHelper")
local CourtBuildType = require("ui.scene.court.CourtBuildType")
local CourtBuildModel = require("ui.models.court.CourtBuildModel")

local prefabRootPath = "Assets/CapstonesRes/Game/Models/PitchBuild/Prefab/"

local Court3DManager = class()

function Court3DManager:ctor()
    self._3DResRootTrm = self.___ex._3DResRootTrm
    self.stadiumAnimClip = self.___ex.scoutAnimClip
    self.scoutAnimClip = self.___ex.scoutAnimClip
    self.parkAnimClip = self.___ex.parkAnimClip
    self.stadiumNode = self.___ex.stadiumNode
    self.scoutNode = self.___ex.scoutNode
    self.parkNode = self.___ex.parkNode
    
    self.effectFinishNode = {
        Stadium = self.stadiumNode,
        Scout = self.scoutNode,
        Parking = self.parkNode
    }
end

local buildResCache = nil
local effectFinishCache =nil
local smallObjCache = nil
local borderEffectCache = nil
local currUpgradeBuildType = nil

local borderEffectConfig = 
{
    Scout = "QJ_JianSheZhong_01_QTS",
    Stadium = "QJ_JianSheZhong_01_QC",
    Parking = "QJ_JianSheZhong_01_TCC"
}

function Court3DManager:InitView(courtBuildModel)
    self.courtBuildModel = courtBuildModel
    buildResCache = {}
end

function Court3DManager:onDestroy()
    if buildResCache then
        for k, v in pairs(buildResCache) do
            Object.Destroy(v)
        end
        buildResCache = nil
    end
    
    if borderEffectCache then
        Object.Destroy(borderEffectCache)
        borderEffectCache = nil
    end
    
    if smallObjCache then
        Object.Destroy(smallObjCache)
        smallObjCache = nil
    end
    
    if effectFinishCache then
        Object.Destroy(effectFinishCache)
        effectFinishCache = nil
    end
    
    currUpgradeBuildType = nil
end

--显示3D资源根据BuildType和等级
function Court3DManager:Show3DResByType(buildType,level)
    print(buildType, level)
    if buildResCache[buildType] then
        Object.Destroy(buildResCache[buildType])
    end    

    local buildResName = self.courtBuildModel:Get3DBuildResName(buildType, level)
    if buildResName and buildResName ~= "" then
        local resObj = self:Load3DRes(buildResName)
        if resObj then
            buildResCache[buildType] = resObj
        end
    end
end

--加载3D资源
function Court3DManager:Load3DRes(preabName)
    local resPath = prefabRootPath..preabName..".prefab"
    local prefab = res.LoadRes(resPath)
    if prefab then
        local obj = Object.Instantiate(prefab)
        local trm = obj:GetComponent(Transform)
        trm:SetParent(self._3DResRootTrm, false)
        return obj
    end
    return nil
end

--建造中特效
function Court3DManager:BuildUpgrading(buildType, level)
    self:ShowBorderEffect(buildType)
    self:ShowSmallObjEffect(buildType, level)
    self:HideEffectFinish()
    self:ChangeGrey(buildType, level, Color(0.6, 0.6, 0.6, 1.0))
end

--建造完成特效
function Court3DManager:BuildUpgradComplete(buildType)
    --TODO 围栏反向动画
    self:HideBorderEffect(buildType)
    self:HideSmallObjEffect()
    self:ShowEffectFinish(buildType)
end

--暂停特效
function Court3DManager:StopAnim(animNode, isReverse)
    local anim = animNode:GetComponent(Animator)
    if anim then
        anim.speed = 1
    end
end

--正向或反向播放特效
function Court3DManager:PlayAnim(animNode, isReverse, buildType)
    local anim = animNode:GetComponent(Animator)
    if anim then
        local animName = borderEffectConfig[buildType]
        if animName then
            if not isReverse then
                anim:Play(animName)
            else
                anim:Play(animName.."_R")
            end
            
        end
    end
end

--加载建造升级中的围栏特效
function Court3DManager:ShowBorderEffect(buildType)
    if buildType == currUpgradeBuildType and borderEffectCache then
       GameObjectHelper.FastSetActive(borderEffectCache, true) 
       self:PlayAnim(borderEffectCache, false, buildType)
    else
        local borderEffName = self.courtBuildModel:GetBuildBorderEffectName(buildType)
        if borderEffName and borderEffName ~= "" then
            local borderEffObj = self:Load3DRes(borderEffName)
            if borderEffObj then
                borderEffectCache = borderEffObj
                currUpgradeBuildType = buildType
                borderEffObj.transform:SetParent(self._3DResRootTrm, false)
                self:PlayAnim(borderEffObj, false, buildType)
            end
        end
    end

end

--反向播放建造升级中的围栏特效
function Court3DManager:HideBorderEffect(buildType)
    if borderEffectCache then
       self:PlayAnim(borderEffectCache, true, buildType)  
       local length = 3
       if buildType == CourtBuildType.StadiumBuild then
          length = self.stadiumAnimClip.length
       elseif buildType == CourtBuildType.ScoutBuild then  
          length = self.scoutAnimClip.length
       elseif buildType == CourtBuildType.ParkingBuild then
          length = self.parkAnimClip.length
       end
       Object.Destroy(borderEffectCache, length)
       borderEffectCache = nil
    end
end

--显示建造升级中的其他小物件特效
function Court3DManager:ShowSmallObjEffect(buildType, level)
    local smallObjName = self.courtBuildModel:GetEffectResName(buildType, level)
    if smallObjName and smallObjName ~= "" then
        local smallEffObj = self:Load3DRes(smallObjName)
        if smallEffObj then
            smallObjCache = smallEffObj
            smallEffObj.transform:SetParent(self._3DResRootTrm, false)
        end
    end
end

--隐藏建造升级中的其他小物件特效
function Court3DManager:HideSmallObjEffect()
    if smallObjCache then
        Object.Destroy(smallObjCache) 
        smallObjCache = nil
    end
end

--加载建造完成特效
function Court3DManager:ShowEffectFinish(buildType)
    --Park由于从1级开始，先将CenterPos保存下来  
    if effectFinishCache then
       GameObjectHelper.FastSetActive(effectFinishCache, true)
    else
        local obj = self:Load3DRes("EffectFinish")
        if obj then
            effectFinishCache = obj
        end
    end
    
    if self.effectFinishNode[buildType] then
        effectFinishCache.transform:SetParent(self.effectFinishNode[buildType], false)
    end
end

--隐藏建造完成特效
function Court3DManager:HideEffectFinish()
    if effectFinishCache then
       GameObjectHelper.FastSetActive(effectFinishCache, false)
    end
end

function Court3DManager:ResetTransform(trans)
    if trans then
       trans.localPosition = UnityEngine.Vector3(0, 0, 0)
       trans.localScale = UnityEngine.Vector3(1, 1, 1)
       trans.localRotation = UnityEngine.Quaternion.identity
    end
end

function Court3DManager:ChangeGrey(buildType, level, color)
    local resObj = buildResCache[buildType]
    if resObj then
        local buildingNode = self.courtBuildModel:GetBuildingNodeName(buildType, level)
        if buildingNode and buildingNode ~= "" then
            local tb = string.split(buildingNode, "|")
            for i, node in ipairs(tb) do
                local trans = resObj.transform:Find(node)
                if trans then
                    local mr = trans:GetComponent(MeshRenderer)
                    if mr then
                        mr.material:SetColor("_Color",color)
                    end
                end
            end
        end
    end
end

return Court3DManager
