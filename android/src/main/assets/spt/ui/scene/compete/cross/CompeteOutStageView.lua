local UnityEngine = clr.UnityEngine

local Vector3 = UnityEngine.Vector3
local Vector2 = UnityEngine.Vector2

local CompeteOutStageView = class(unity.base)

function CompeteOutStageView:ctor()
end

function CompeteOutStageView:Init(stageIndex, stageCount, space)
    self.stageIndex = stageIndex
    self.stageCount = stageCount

    -- 1: 32
    -- 2: 16
    -- 3: 8
    -- 4: 4
	-- 5: 2
    -- 6: cup

    if stageIndex == stageCount then
        self.isCup = true
        -- load cup prefab
        local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteOutCup.prefab"
        local obj, spt = res.Instantiate(prefab)
        obj.transform.localPosition = Vector3(-30, 0, 0)
        obj.transform:SetParent(self.gameObject.transform, false)
        self.cupScript = spt
        self.cup = obj
    else
        self.isCup = false
        -- load n teams
        self.teamCount = math.pow(2, stageCount - stageIndex) / 2


        self.teams = {}
        for i = 1, self.teamCount do
            local prefab = "Assets/CapstonesRes/Game/UI/Scene/Compete/Cross/Prefab/CompeteOutTeam.prefab"
            local obj, spt = res.Instantiate(prefab)

            if i == 1 then
                self.transform.sizeDelta = Vector2(self.transform.sizeDelta.x, self.teamCount * obj.transform.rect.height + (self.teamCount - 1) * space)
			end

            local y = obj.transform.rect.height * (self.teamCount / 2 - i + 0.5) + (self.teamCount - 1) * space / 2 - (i - 1) * space 
            obj.transform.localPosition = Vector3(0, y, 0)
            obj.transform:SetParent(self.gameObject.transform, false)

            if stageIndex ~= 1 then
                delta = self.transform.sizeDelta.x - spt.lineX.sizeDelta.x
                spt.lineX.localPosition = Vector3(spt.lineX.localPosition.x - delta, spt.lineX.localPosition.y, 0)
                spt.lineX.sizeDelta = Vector2(spt.lineX.sizeDelta.x + delta, spt.lineX.sizeDelta.y)
            end

            if stageIndex == stageCount - 1 then
                -- make line to the center of cup
                spt.lineX.sizeDelta = Vector2(self.transform.sizeDelta.x * 1.2, spt.lineX.sizeDelta.y)
            end

            if self.teamCount == 1 or math.fmod(i, 2) == 0 then
                spt.lineY.gameObject:SetActive(false)
            else
                spt.lineY.gameObject:SetActive(true)
            end

            self.teams[i] = spt
        end
    end

end

return CompeteOutStageView