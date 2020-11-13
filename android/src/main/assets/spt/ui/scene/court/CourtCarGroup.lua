local UnityEngine = clr.UnityEngine
local CourtCarGroup = class(unity.base)
local Object = UnityEngine.Object
local Vector3 = UnityEngine.Vector3
local Quaternion = UnityEngine.Quaternion
local CarSpecialPosition = require("ui.scene.court.CarSpecialPosition")
local CapsUnityLuaBehav = clr.CapsUnityLuaBehav
CourtCarGroup.renderCarPrefabPath = "Assets/CapstonesRes/Game/Models/CourtBuild/RenderCars.prefab"

function CourtCarGroup:ctor()
    
end

function CourtCarGroup:Init()
    self.renderCar = res.Instantiate(CourtCarGroup.renderCarPrefabPath)
    self.positions = CarSpecialPosition.InitPosition()

    local staticTransform = {}
    staticTransform[1] = {position = Vector3Lua(-2.51, 4.92, 3.03), rotation = QuaternionLua(0.13088545203209, 0.86816281080246, -0.35960480570793, 0.31598547101021), position_static = Vector3(-2.51, 4.92, 3.03), rotation_static = Quaternion(0.13088545203209, 0.86816281080246, -0.35960480570793, 0.31598547101021)}
    staticTransform[2] = {position = Vector3Lua(-2.51, 4.92, -3.03), rotation = QuaternionLua(0.35960480570793, 0.31598538160324, -0.13088542222977, 0.8681628704071), position_static = Vector3(-2.51, 4.92, -3.03), rotation_static = Quaternion(0.35960480570793, 0.31598538160324, -0.13088542222977, 0.8681628704071)}
    staticTransform[3] = {position = Vector3Lua(2.51, 4.92, -3.03), rotation = QuaternionLua(0.35960480570793, -0.31598538160324, 0.13088542222977, 0.8681628704071), position_static = Vector3(2.51, 4.92, -3.03), rotation_static = Quaternion(0.35960480570793, -0.31598538160324, 0.13088542222977, 0.8681628704071)}
    staticTransform[4] = {position = Vector3Lua(2.51, 4.92, 3.03), rotation = QuaternionLua(0.13088545203209, -0.86816281080246, 0.35960477590561, 0.31598547101021), position_static = Vector3(2.51, 4.92, 3.03), rotation_static = Quaternion(0.13088545203209, -0.86816281080246, 0.35960477590561, 0.31598547101021)}
    for i = 1, self.transform.childCount do
        local cameraTransform = self.renderCar.transform:GetComponent(CapsUnityLuaBehav).___ex["transform" .. i]
        self.transform:GetChild(i - 1):GetComponent(CapsUnityLuaBehav):Run(self.positions, cameraTransform, staticTransform, self.renderCar.transform:GetComponent(CapsUnityLuaBehav).___ex["car" .. i])
    end
end

function CourtCarGroup:DestroyRenderCar()
    Object.Destroy(self.renderCar)
end

return CourtCarGroup
