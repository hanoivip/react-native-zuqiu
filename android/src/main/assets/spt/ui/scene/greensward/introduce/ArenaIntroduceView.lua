local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AdventureRegion = require("data.AdventureRegion")
local ArenaIntroduceView = class(unity.base)

function ArenaIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.contentMap = {}
    self.contentPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/ArenaContentItem.prefab"
end

function ArenaIntroduceView:InitView()
    local contentRes = res.LoadRes(self.contentPath)
    local regionData = {}
    for i, v in pairs(AdventureRegion) do
        v.regionID = tonumber(i)
        table.insert(regionData, v)
    end
    table.sort(regionData, function(a, b) return a.regionID < b.regionID end)

    for i, v in ipairs(regionData) do
        local spt = self.contentMap[i]
        if not spt then
            local obj = Object.Instantiate(contentRes)
            obj.transform:SetParent(self.contentTrans, false)
            spt = obj:GetComponent("CapsUnityLuaBehav")
            self.contentMap[i] = spt
        end
        spt:InitView(v)
    end
end

return ArenaIntroduceView
