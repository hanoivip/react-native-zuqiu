local UnityEngine = clr.UnityEngine
local Vector2 = UnityEngine.Vector2
local Vector3 = UnityEngine.Vector3

local CourtLabelManager = class(unity.base)

local labelDeltaPos = Vector3(0, 10, 0)
local labelDeltaPixel = Vector2(-80, 0)

function CourtLabelManager:ctor()
    --3D点
    self.builds = self.___ex.builds
    self.pos = self.___ex.pos
    self.athleteLabelsComponent = self.___ex.athleteLabelsComponent
end

function CourtLabelManager:start()
--   local trans = self.titles:GetComponent(Transform)

--   for i = 0, self.transform.childrens do
--       local  trm = trans:GetChild(i)
--       trm:SetParent(self.transform,true)
--       local obj = GameObject.Find("3DPoint/"..trm.name)  --Lua assist checked flag
--       self:DisplayLabel(trm.gameObject,obj)
--   end

    for buildName, child in pairs(self.builds) do
        local followPosObj = self.pos[buildName]
        self:DisplayLabel(child, followPosObj)
    end
end


function CourtLabelManager:DisplayLabel(uiLabel, athleteObject)
    self.athleteLabelsComponent:AddLabel(uiLabel, athleteObject, labelDeltaPos, labelDeltaPixel, false, false, 0, nil)
end

function CourtLabelManager:RemoveLabel(athlete, athleteObject)
    self.athleteLabelsComponent:RemoveLabel(athlete, athleteObject)
end


return CourtLabelManager
