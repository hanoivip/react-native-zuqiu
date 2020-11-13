local UnityEngine = clr.UnityEngine
local Object = UnityEngine.Object
local AdventureFloor = require("data.AdventureFloor")
local PlayTipsIntroduceView = class(unity.base)

function PlayTipsIntroduceView:ctor()
--------Start_Auto_Generate--------
    self.contentTrans = self.___ex.contentTrans
--------End_Auto_Generate----------
    self.contentMap = {}
    self.contentPath = "Assets/CapstonesRes/Game/UI/Scene/Greensward/Prefab/Introduce/PlayTipsContentItem.prefab"
end

function PlayTipsIntroduceView:InitView()
    local contentRes = res.LoadRes(self.contentPath)

    local floorData = {}
    for i, v in pairs(AdventureFloor) do
        table.insert(floorData, v)
    end
    table.sort(floorData, function(a, b) return a.floorID < b.floorID end)

    for i, v in ipairs(floorData) do
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

return PlayTipsIntroduceView
